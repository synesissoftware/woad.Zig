const std = @import("std");
const woad = @import("woad");

/// Prints `text` wrapped in `seq` only when `writer` supports colour.
fn paint(writer: *std.Io.Writer, seq: []const u8, text: []const u8) !void {
    try writer.print("  {s}{s}{s}\n", .{
        woad.seqFor(seq, writer),
        text,
        woad.seqFor(woad.RESET, writer),
    });
}

pub fn main(init: std.process.Init) !void {
    var buffer: [4096]u8 = undefined;
    var stdout_impl = std.Io.File.stdout().writer(init.io, &buffer);
    const stdout = &stdout_impl.interface;

    try stdout.print("woad.Zig version: {s}\n\n", .{woad.VERSION});

    try stdout.print("{s}ok{s}\n\n", .{
        woad.seqFor(woad.FG_GREEN, stdout),
        woad.seqFor(woad.RESET, stdout),
    });

    try stdout.print("Standard foreground colours:\n", .{});
    try paint(stdout, woad.FG_BLACK, "Black");
    try paint(stdout, woad.FG_RED, "Red");
    try paint(stdout, woad.FG_GREEN, "Green");
    try paint(stdout, woad.FG_YELLOW, "Yellow");
    try paint(stdout, woad.FG_BLUE, "Blue");
    try paint(stdout, woad.FG_MAGENTA, "Magenta");
    try paint(stdout, woad.FG_CYAN, "Cyan");
    try paint(stdout, woad.FG_WHITE, "White");
    try stdout.print("\n", .{});

    try stdout.print("Bright foreground colours:\n", .{});
    try paint(stdout, woad.FG_BRIGHT_BLACK, "Bright Black");
    try paint(stdout, woad.FG_BRIGHT_RED, "Bright Red");
    try paint(stdout, woad.FG_BRIGHT_GREEN, "Bright Green");
    try paint(stdout, woad.FG_BRIGHT_YELLOW, "Bright Yellow");
    try paint(stdout, woad.FG_BRIGHT_BLUE, "Bright Blue");
    try paint(stdout, woad.FG_BRIGHT_MAGENTA, "Bright Magenta");
    try paint(stdout, woad.FG_BRIGHT_CYAN, "Bright Cyan");
    try paint(stdout, woad.FG_BRIGHT_WHITE, "Bright White");
    try stdout.print("\n", .{});

    try stdout.print("Background colours:\n", .{});
    try paint(stdout, woad.BG_BLACK, " Black ");
    try paint(stdout, woad.BG_RED, " Red ");
    try paint(stdout, woad.BG_GREEN, " Green ");
    try paint(stdout, woad.BG_YELLOW, " Yellow ");
    try paint(stdout, woad.BG_BLUE, " Blue ");
    try paint(stdout, woad.BG_MAGENTA, " Magenta ");
    try paint(stdout, woad.BG_CYAN, " Cyan ");
    try paint(stdout, woad.BG_WHITE, " White ");

    try stdout.flush();
}
