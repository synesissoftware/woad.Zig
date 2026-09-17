//! Minimal ANSI terminal colour codes, for Zig.
//!
//! **woad** provides the smallest useful set of fixed SGR sequences for
//! library authors. It is not a console or TUI framework.

/// Package version.
pub const VERSION = "0.0.1";

// Reset

/// Reset all attributes.
pub const RESET = "\x1b[0m";

// Foreground (standard)

/// Foreground black.
pub const FG_BLACK = "\x1b[30m";
/// Foreground red.
pub const FG_RED = "\x1b[31m";
/// Foreground green.
pub const FG_GREEN = "\x1b[32m";
/// Foreground yellow.
pub const FG_YELLOW = "\x1b[33m";
/// Foreground blue.
pub const FG_BLUE = "\x1b[34m";
/// Foreground magenta.
pub const FG_MAGENTA = "\x1b[35m";
/// Foreground cyan.
pub const FG_CYAN = "\x1b[36m";
/// Foreground white.
pub const FG_WHITE = "\x1b[37m";

// Foreground (bright)

/// Foreground bright black.
pub const FG_BRIGHT_BLACK = "\x1b[90m";
/// Foreground bright red.
pub const FG_BRIGHT_RED = "\x1b[91m";
/// Foreground bright green.
pub const FG_BRIGHT_GREEN = "\x1b[92m";
/// Foreground bright yellow.
pub const FG_BRIGHT_YELLOW = "\x1b[93m";
/// Foreground bright blue.
pub const FG_BRIGHT_BLUE = "\x1b[94m";
/// Foreground bright magenta.
pub const FG_BRIGHT_MAGENTA = "\x1b[95m";
/// Foreground bright cyan.
pub const FG_BRIGHT_CYAN = "\x1b[96m";
/// Foreground bright white.
pub const FG_BRIGHT_WHITE = "\x1b[97m";

// Background (standard)

/// Background black.
pub const BG_BLACK = "\x1b[40m";
/// Background red.
pub const BG_RED = "\x1b[41m";
/// Background green.
pub const BG_GREEN = "\x1b[42m";
/// Background yellow.
pub const BG_YELLOW = "\x1b[43m";
/// Background blue.
pub const BG_BLUE = "\x1b[44m";
/// Background magenta.
pub const BG_MAGENTA = "\x1b[45m";
/// Background cyan.
pub const BG_CYAN = "\x1b[46m";
/// Background white.
pub const BG_WHITE = "\x1b[47m";

// Background (bright)

/// Background bright black.
pub const BG_BRIGHT_BLACK = "\x1b[100m";
/// Background bright red.
pub const BG_BRIGHT_RED = "\x1b[101m";
/// Background bright green.
pub const BG_BRIGHT_GREEN = "\x1b[102m";
/// Background bright yellow.
pub const BG_BRIGHT_YELLOW = "\x1b[103m";
/// Background bright blue.
pub const BG_BRIGHT_BLUE = "\x1b[104m";
/// Background bright magenta.
pub const BG_BRIGHT_MAGENTA = "\x1b[105m";
/// Background bright cyan.
pub const BG_BRIGHT_CYAN = "\x1b[106m";
/// Background bright white.
pub const BG_BRIGHT_WHITE = "\x1b[107m";

const std = @import("std");
const testing = std.testing;

test "version" {
    try testing.expectEqualStrings("0.0.1", VERSION);
}

test "reset code" {
    try testing.expectEqualStrings("\x1b[0m", RESET);
}

test "foreground standard codes" {
    try testing.expectEqualStrings("\x1b[30m", FG_BLACK);
    try testing.expectEqualStrings("\x1b[31m", FG_RED);
    try testing.expectEqualStrings("\x1b[32m", FG_GREEN);
    try testing.expectEqualStrings("\x1b[33m", FG_YELLOW);
    try testing.expectEqualStrings("\x1b[34m", FG_BLUE);
    try testing.expectEqualStrings("\x1b[35m", FG_MAGENTA);
    try testing.expectEqualStrings("\x1b[36m", FG_CYAN);
    try testing.expectEqualStrings("\x1b[37m", FG_WHITE);
}

test "foreground bright codes" {
    try testing.expectEqualStrings("\x1b[90m", FG_BRIGHT_BLACK);
    try testing.expectEqualStrings("\x1b[91m", FG_BRIGHT_RED);
    try testing.expectEqualStrings("\x1b[92m", FG_BRIGHT_GREEN);
    try testing.expectEqualStrings("\x1b[93m", FG_BRIGHT_YELLOW);
    try testing.expectEqualStrings("\x1b[94m", FG_BRIGHT_BLUE);
    try testing.expectEqualStrings("\x1b[95m", FG_BRIGHT_MAGENTA);
    try testing.expectEqualStrings("\x1b[96m", FG_BRIGHT_CYAN);
    try testing.expectEqualStrings("\x1b[97m", FG_BRIGHT_WHITE);
}

test "background standard codes" {
    try testing.expectEqualStrings("\x1b[40m", BG_BLACK);
    try testing.expectEqualStrings("\x1b[41m", BG_RED);
    try testing.expectEqualStrings("\x1b[42m", BG_GREEN);
    try testing.expectEqualStrings("\x1b[43m", BG_YELLOW);
    try testing.expectEqualStrings("\x1b[44m", BG_BLUE);
    try testing.expectEqualStrings("\x1b[45m", BG_MAGENTA);
    try testing.expectEqualStrings("\x1b[46m", BG_CYAN);
    try testing.expectEqualStrings("\x1b[47m", BG_WHITE);
}

test "background bright codes" {
    try testing.expectEqualStrings("\x1b[100m", BG_BRIGHT_BLACK);
    try testing.expectEqualStrings("\x1b[101m", BG_BRIGHT_RED);
    try testing.expectEqualStrings("\x1b[102m", BG_BRIGHT_GREEN);
    try testing.expectEqualStrings("\x1b[103m", BG_BRIGHT_YELLOW);
    try testing.expectEqualStrings("\x1b[104m", BG_BRIGHT_BLUE);
    try testing.expectEqualStrings("\x1b[105m", BG_BRIGHT_MAGENTA);
    try testing.expectEqualStrings("\x1b[106m", BG_BRIGHT_CYAN);
    try testing.expectEqualStrings("\x1b[107m", BG_BRIGHT_WHITE);
}

test "all codes are CSI SGR" {
    const codes = [_][]const u8{
        RESET,
        FG_BLACK,
        FG_RED,
        FG_GREEN,
        FG_YELLOW,
        FG_BLUE,
        FG_MAGENTA,
        FG_CYAN,
        FG_WHITE,
        FG_BRIGHT_BLACK,
        FG_BRIGHT_RED,
        FG_BRIGHT_GREEN,
        FG_BRIGHT_YELLOW,
        FG_BRIGHT_BLUE,
        FG_BRIGHT_MAGENTA,
        FG_BRIGHT_CYAN,
        FG_BRIGHT_WHITE,
        BG_BLACK,
        BG_RED,
        BG_GREEN,
        BG_YELLOW,
        BG_BLUE,
        BG_MAGENTA,
        BG_CYAN,
        BG_WHITE,
        BG_BRIGHT_BLACK,
        BG_BRIGHT_RED,
        BG_BRIGHT_GREEN,
        BG_BRIGHT_YELLOW,
        BG_BRIGHT_BLUE,
        BG_BRIGHT_MAGENTA,
        BG_BRIGHT_CYAN,
        BG_BRIGHT_WHITE,
    };

    for (codes) |code| {
        try testing.expect(std.mem.startsWith(u8, code, "\x1b["));
        try testing.expect(std.mem.endsWith(u8, code, "m"));
    }
}
