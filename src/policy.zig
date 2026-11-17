//! Portable colour policy.
//!
//! Cached environment inspection for the Unix half of the **woad** 0.3.0
//! colour contract. Windows virtual-terminal gating is not in this alpha.

const std = @import("std");
const builtin = @import("builtin");

// /////////////////////////////////////////////////////////////////////////
// types

/// Prevailing colour policy. Discriminants are the **woad** 0.3.0 values.
pub const ColourPolicy = enum(i32) {
    /// Colour depends on the writer. `TERM=dumb` suppresses colour on this
    /// path only.
    auto = 0,

    /// Colour for every writer, including a non-terminal and `TERM=dumb`.
    force = 1,

    /// Colour for no writer, including a terminal.
    inhibit = 2,
};

// /////////////////////////////////////////////////////////////////////////
// constants

const truey = [_][]const u8{
    "1",
    "always",
    "force",
    "on",
    "true",
    "yes",
};

const falsey = [_][]const u8{
    "0",
    "false",
    "never",
    "no",
    "none",
    "off",
};

// /////////////////////////////////////////////////////////////////////////
// globals

const Environment = struct {
    determined: bool = false,
    policy: ColourPolicy = .auto,
    term_is_dumb: bool = false,
};

var cache: Environment = .{};
var cache_lock: std.atomic.Mutex = .unlocked;

extern "c" fn getenv(name: [*:0]const u8) ?[*:0]const u8;

// /////////////////////////////////////////////////////////////////////////
// helper functions

fn ensure(env: *Environment) void {
    if (!env.determined) {
        env.policy = policyFromEnvironment();
        env.term_is_dumb = termIsDumbFromEnvironment();
        env.determined = true;
    }
}

fn listed(value: []const u8, candidates: []const []const u8) bool {
    for (candidates) |candidate| {
        if (std.ascii.eqlIgnoreCase(value, candidate)) return true;
    }
    return false;
}

fn lock(mutex: *std.atomic.Mutex) void {
    while (!mutex.tryLock()) std.atomic.spinLoopHint();
}

fn nonempty(name: [:0]const u8) ?[]const u8 {
    const value = getenv(name) orelse return null;
    const text = std.mem.span(value);
    if (text.len == 0) return null;
    return text;
}

fn policyFromEnvironment() ColourPolicy {
    if (nonempty("WOAD_COLOUR") orelse nonempty("WOAD_COLOR")) |value| {
        if (listed(value, &truey)) return .force;
        if (listed(value, &falsey)) return .inhibit;
        return .auto;
    }

    if (nonempty("NO_COLOR") != null) return .inhibit;

    if (nonempty("CLICOLOR_FORCE")) |value| {
        if (!std.mem.eql(u8, value, "0")) return .force;
    }

    if (nonempty("FORCE_COLOR")) |value| {
        if (!std.mem.eql(u8, value, "0") and !std.ascii.eqlIgnoreCase(value, "false")) {
            return .force;
        }
    }

    if (nonempty("CLICOLOR")) |value| {
        if (std.mem.eql(u8, value, "0")) return .inhibit;
    }

    return .auto;
}

fn supportsFor(env: *Environment, is_terminal: bool) bool {
    ensure(env);
    return switch (env.policy) {
        .auto => is_terminal and !env.term_is_dumb,
        .force => true,
        .inhibit => false,
    };
}

fn termIsDumbFromEnvironment() bool {
    const value = nonempty("TERM") orelse return false;
    return std.ascii.eqlIgnoreCase(value, "dumb");
}

// /////////////////////////////////////////////////////////////////////////
// API functions

/// Whether `writer` is a `std.Io.File` writer whose descriptor the standard
/// library reports as a terminal.
///
/// Any other writer is not a terminal. This does not apply the colour policy.
pub fn isTty(writer: *std.Io.Writer) bool {
    const FileWriter = std.Io.File.Writer;
    if (writer.vtable.drain != FileWriter.drain) return false;

    const file_writer: *FileWriter = @alignCast(@fieldParentPtr("interface", writer));
    return file_writer.file.isTty(file_writer.io) catch false;
}

/// Prevailing colour policy, cached until `refresh`.
///
/// Returns `auto` (0), `force` (1), or `inhibit` (2). An unset or empty
/// variable is absent. Values are not trimmed.
pub fn colourPolicy() ColourPolicy {
    lock(&cache_lock);
    defer cache_lock.unlock();

    ensure(&cache);
    return cache.policy;
}

/// Drops the cached policy and the cached `TERM=dumb` flag.
///
/// The next query reads the environment again. On Unix there is no console
/// cache to drop.
pub fn refresh() void {
    lock(&cache_lock);
    defer cache_lock.unlock();

    cache.determined = false;
}

/// Whether colour should be emitted for `writer`.
///
/// `force` is yes for every writer. `inhibit` is no for every writer.
/// `auto` is yes only when `writer` is a terminal and `TERM` is not `dumb`.
///
/// On Unix a terminal is ANSI-capable. Windows virtual-terminal gating and
/// mintty recognition are not implemented in this alpha.
pub fn supportsColour(writer: *std.Io.Writer) bool {
    const attached = isTty(writer);

    lock(&cache_lock);
    defer cache_lock.unlock();

    return supportsFor(&cache, attached);
}

/// `seq` when `supportsColour` is true for `writer`, otherwise `""`.
///
/// A null or empty `seq` yields `""`.
pub fn seqFor(seq: ?[]const u8, writer: *std.Io.Writer) []const u8 {
    const text = seq orelse return "";
    if (text.len == 0 or !supportsColour(writer)) return "";
    return text;
}

// /////////////////////////////////////////////////////////////////////////
// tests

const testing = std.testing;

const managed_names = [_][:0]const u8{
    "CLICOLOR",
    "CLICOLOR_FORCE",
    "FORCE_COLOR",
    "NO_COLOR",
    "TERM",
    "WOAD_COLOR",
    "WOAD_COLOUR",
};

const Assignment = struct {
    name: [:0]const u8,
    value: [:0]const u8,
};

extern "c" fn setenv(name: [*:0]const u8, value: [*:0]const u8, overwrite: c_int) c_int;
extern "c" fn unsetenv(name: [*:0]const u8) c_int;

var env_lock: std.atomic.Mutex = .unlocked;

const Endpoints = struct {
    terminal: std.Io.File.Writer = undefined,
    detached: std.Io.File.Writer = undefined,
    terminal_buf: [64]u8 = undefined,
    detached_buf: [64]u8 = undefined,
    terminal_file: std.Io.File = undefined,
    detached_file: std.Io.File = undefined,
    master: std.Io.File = undefined,
    ready: bool = false,
};

var endpoints_slot: Endpoints = .{};

fn assign(name: [:0]const u8, value: [:0]const u8) void {
    if (setenv(name.ptr, value.ptr, 1) != 0) @panic("setenv");
}

fn clearName(name: [:0]const u8) void {
    _ = unsetenv(name.ptr);
}

fn captureManaged(allocator: std.mem.Allocator) ![]?[]u8 {
    const saved = try allocator.alloc(?[]u8, managed_names.len);
    for (managed_names, 0..) |name, index| {
        if (getenv(name.ptr)) |value| {
            saved[index] = try allocator.dupe(u8, std.mem.span(value));
        } else {
            saved[index] = null;
        }
    }
    return saved;
}

fn applySaved(saved: []?[]u8) void {
    for (managed_names, saved) |name, value| {
        if (value) |text| {
            const terminated = testing.allocator.allocSentinel(u8, text.len, 0) catch @panic("allocSentinel");
            defer testing.allocator.free(terminated);
            @memcpy(terminated[0..text.len], text);
            assign(name, terminated);
        } else {
            clearName(name);
        }
    }
}

fn clearManaged() void {
    for (managed_names) |name| clearName(name);
}

fn endpoints() *Endpoints {
    if (!endpoints_slot.ready) {
        openEndpoints(&endpoints_slot) catch @panic("open colour-policy endpoints");
        endpoints_slot.ready = true;
    }
    return &endpoints_slot;
}

fn openEndpoints(slot: *Endpoints) !void {
    const io = std.testing.io;
    slot.detached_file = try std.Io.Dir.openFileAbsolute(io, "/dev/null", .{ .mode = .write_only });
    errdefer slot.detached_file.close(io);

    const pty = try openPty(io);
    slot.master = pty.master;
    slot.terminal_file = pty.slave;

    slot.terminal = slot.terminal_file.writer(io, &slot.terminal_buf);
    slot.detached = slot.detached_file.writer(io, &slot.detached_buf);

    if (!isTty(&slot.terminal.interface)) return error.SlaveNotTerminal;
    if (isTty(&slot.detached.interface)) return error.NullIsTerminal;
}

const Pty = struct {
    master: std.Io.File,
    slave: std.Io.File,
};

fn openPty(io: std.Io) !Pty {
    const O_RDWR: c_int = 2;
    const O_NOCTTY: c_int = switch (builtin.os.tag) {
        .macos => 0x20000,
        .linux => 0x100,
        else => 0x8000,
    };

    const c = struct {
        extern "c" fn posix_openpt(flags: c_int) c_int;
        extern "c" fn grantpt(fd: c_int) c_int;
        extern "c" fn unlockpt(fd: c_int) c_int;
        extern "c" fn ptsname(fd: c_int) ?[*:0]u8;
    };

    const master_fd = c.posix_openpt(O_RDWR | O_NOCTTY);
    if (master_fd < 0) return error.OpenPt;
    errdefer _ = closeFd(master_fd);

    if (c.grantpt(master_fd) != 0 or c.unlockpt(master_fd) != 0) return error.UnlockPt;

    const name = c.ptsname(master_fd) orelse return error.PtsName;
    const slave = try std.Io.Dir.openFileAbsolute(io, std.mem.span(name), .{ .mode = .read_write });

    return .{
        .master = .{
            .handle = master_fd,
            .flags = .{ .nonblocking = false },
        },
        .slave = slave,
    };
}

extern "c" fn close(fd: c_int) c_int;

fn closeFd(fd: c_int) c_int {
    return close(fd);
}

fn writerFor(terminal: bool) *std.Io.Writer {
    const slot = endpoints();
    if (terminal) return &slot.terminal.interface;
    return &slot.detached.interface;
}

fn expectRow(
    row: u32,
    assignments: []const Assignment,
    terminal: bool,
    policy: ColourPolicy,
    colour: bool,
) !void {
    lock(&env_lock);
    defer env_lock.unlock();

    const saved = try captureManaged(testing.allocator);
    defer {
        for (saved) |value| {
            if (value) |text| testing.allocator.free(text);
        }
        testing.allocator.free(saved);
    }

    clearManaged();
    for (assignments) |item| assign(item.name, item.value);
    refresh();
    defer {
        applySaved(saved);
        refresh();
    }

    const attached = writerFor(terminal);
    try testing.expectEqual(terminal, isTty(attached));
    try expectPolicy(row, policy);
    try expectColour(row, colour, supportsColour(attached));

    const root = @import("root.zig");
    const seq = seqFor(root.FG_RED, attached);
    if (colour) {
        try testing.expectEqualStrings(root.FG_RED, seq);
    } else {
        try testing.expectEqualStrings("", seq);
    }
}

fn expectPolicy(row: u32, expected: ColourPolicy) !void {
    const actual = colourPolicy();
    if (actual != expected) {
        std.debug.print("row {d} policy: expected {t}, actual {t}\n", .{ row, expected, actual });
        return error.TestExpectedEqual;
    }
}

fn expectColour(row: u32, expected: bool, actual: bool) !void {
    if (actual != expected) {
        std.debug.print("row {d} colour: expected {}, actual {}\n", .{ row, expected, actual });
        return error.TestExpectedEqual;
    }
}

fn pair(name: [:0]const u8, value: [:0]const u8) Assignment {
    return .{ .name = name, .value = value };
}

test "decision rows 1-22" {
    if (comptime builtin.os.tag == .windows) return error.SkipZigTest;

    try expectRow(1, &.{}, true, .auto, true);
    try expectRow(2, &.{}, false, .auto, false);
    try expectRow(3, &.{pair("TERM", "dumb")}, true, .auto, false);
    try expectRow(4, &.{pair("TERM", "DUMB")}, true, .auto, false);
    try expectRow(5, &.{pair("WOAD_COLOUR", "1")}, false, .force, true);
    try expectRow(6, &.{pair("WOAD_COLOR", "always")}, false, .force, true);
    try expectRow(7, &.{pair("WOAD_COLOUR", "never")}, true, .inhibit, false);
    try expectRow(8, &.{pair("WOAD_COLOUR", "auto")}, true, .auto, true);
    try expectRow(9, &.{pair("WOAD_COLOUR", "auto")}, false, .auto, false);
    try expectRow(10, &.{pair("WOAD_COLOUR", "purple")}, true, .auto, true);
    try expectRow(11, &.{ pair("CLICOLOR_FORCE", "1"), pair("NO_COLOR", "1") }, true, .inhibit, false);
    try expectRow(12, &.{pair("CLICOLOR_FORCE", "1")}, false, .force, true);
    try expectRow(13, &.{ pair("CLICOLOR", "0"), pair("CLICOLOR_FORCE", "0") }, true, .inhibit, false);
    try expectRow(14, &.{pair("FORCE_COLOR", "1")}, false, .force, true);
    try expectRow(15, &.{ pair("CLICOLOR", "0"), pair("FORCE_COLOR", "false") }, true, .inhibit, false);
    try expectRow(16, &.{pair("FORCE_COLOR", "FALSE")}, false, .auto, false);
    try expectRow(17, &.{pair("FORCE_COLOR", "0")}, true, .auto, true);
    try expectRow(18, &.{pair("CLICOLOR", "0")}, true, .inhibit, false);
    try expectRow(19, &.{pair("CLICOLOR", "1")}, true, .auto, true);
    try expectRow(20, &.{ pair("NO_COLOR", "1"), pair("WOAD_COLOUR", "") }, true, .inhibit, false);
    try expectRow(21, &.{pair("NO_COLOR", "")}, true, .auto, true);

    // Row 22 fails unless the second refresh drops the cached force policy.
    lock(&env_lock);
    defer env_lock.unlock();

    const saved = try captureManaged(testing.allocator);
    defer {
        for (saved) |value| {
            if (value) |text| testing.allocator.free(text);
        }
        testing.allocator.free(saved);
    }

    clearManaged();
    defer {
        applySaved(saved);
        refresh();
    }

    assign("WOAD_COLOUR", "1");
    refresh();

    const attached = writerFor(true);
    try expectPolicy(22, .force);
    try expectColour(22, true, supportsColour(attached));

    clearName("WOAD_COLOUR");
    assign("NO_COLOR", "1");
    refresh();

    try expectPolicy(22, .inhibit);
    try expectColour(22, false, supportsColour(attached));
    try testing.expectEqualStrings("", seqFor(@import("root.zig").BOLD, attached));
    try testing.expect(isTty(attached));

    clearManaged();
    assign("WOAD_COLOUR", "1");
    refresh();
    try testing.expectEqualStrings("", seqFor(null, writerFor(false)));
}

// ///////////////////////////// end of file ////////////////////////////
