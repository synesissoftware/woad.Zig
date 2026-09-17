const std = @import("std");
const woad = @import("woad");

pub fn main(init: std.process.Init) !void {
    var buffer: [4096]u8 = undefined;
    var stdout_impl = std.Io.File.stdout().writer(init.io, &buffer);
    const stdout = &stdout_impl.interface;

    try stdout.print("woad.Zig version: {s}\n\n", .{woad.VERSION});

    try stdout.print("Standard foreground colours:\n", .{});
    try stdout.print("  {s}Black{s}\n", .{ woad.FG_BLACK, woad.RESET });
    try stdout.print("  {s}Red{s}\n", .{ woad.FG_RED, woad.RESET });
    try stdout.print("  {s}Green{s}\n", .{ woad.FG_GREEN, woad.RESET });
    try stdout.print("  {s}Yellow{s}\n", .{ woad.FG_YELLOW, woad.RESET });
    try stdout.print("  {s}Blue{s}\n", .{ woad.FG_BLUE, woad.RESET });
    try stdout.print("  {s}Magenta{s}\n", .{ woad.FG_MAGENTA, woad.RESET });
    try stdout.print("  {s}Cyan{s}\n", .{ woad.FG_CYAN, woad.RESET });
    try stdout.print("  {s}White{s}\n\n", .{ woad.FG_WHITE, woad.RESET });

    try stdout.print("Bright foreground colours:\n", .{});
    try stdout.print("  {s}Bright Black{s}\n", .{ woad.FG_BRIGHT_BLACK, woad.RESET });
    try stdout.print("  {s}Bright Red{s}\n", .{ woad.FG_BRIGHT_RED, woad.RESET });
    try stdout.print("  {s}Bright Green{s}\n", .{ woad.FG_BRIGHT_GREEN, woad.RESET });
    try stdout.print("  {s}Bright Yellow{s}\n", .{ woad.FG_BRIGHT_YELLOW, woad.RESET });
    try stdout.print("  {s}Bright Blue{s}\n", .{ woad.FG_BRIGHT_BLUE, woad.RESET });
    try stdout.print("  {s}Bright Magenta{s}\n", .{ woad.FG_BRIGHT_MAGENTA, woad.RESET });
    try stdout.print("  {s}Bright Cyan{s}\n", .{ woad.FG_BRIGHT_CYAN, woad.RESET });
    try stdout.print("  {s}Bright White{s}\n\n", .{ woad.FG_BRIGHT_WHITE, woad.RESET });

    try stdout.print("Background colours:\n", .{});
    try stdout.print("  {s} Black {s}\n", .{ woad.BG_BLACK, woad.RESET });
    try stdout.print("  {s} Red {s}\n", .{ woad.BG_RED, woad.RESET });
    try stdout.print("  {s} Green {s}\n", .{ woad.BG_GREEN, woad.RESET });
    try stdout.print("  {s} Yellow {s}\n", .{ woad.BG_YELLOW, woad.RESET });
    try stdout.print("  {s} Blue {s}\n", .{ woad.BG_BLUE, woad.RESET });
    try stdout.print("  {s} Magenta {s}\n", .{ woad.BG_MAGENTA, woad.RESET });
    try stdout.print("  {s} Cyan {s}\n", .{ woad.BG_CYAN, woad.RESET });
    try stdout.print("  {s} White {s}\n", .{ woad.BG_WHITE, woad.RESET });

    try stdout.flush();
}
