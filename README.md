# woad.Zig <!-- omit in toc -->

Minimal ANSI terminal colour codes, for Zig

![Language](https://img.shields.io/badge/Zig-F7A41D?style=flat&logo=zig&logoColor=white)
[![License](https://img.shields.io/badge/License-BSD_3--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)
[![GitHub release](https://img.shields.io/github/v/release/synesissoftware/woad.Zig.svg)](https://github.com/synesissoftware/woad.Zig/releases/latest)
[![Last Commit](https://img.shields.io/github/last-commit/synesissoftware/woad.Zig)](https://github.com/synesissoftware/woad.Zig/commits/master)
[![CI](https://github.com/synesissoftware/woad.Zig/actions/workflows/ci.yml/badge.svg)](https://github.com/synesissoftware/woad.Zig/actions/workflows/ci.yml)


## Table of Contents <!-- omit in toc -->

- [Introduction](#introduction)
- [Developer Experience](#developer-experience)
- [Installation](#installation)
- [Components](#components)
- [Examples](#examples)
- [Project Information](#project-information)
  - [Where to get help](#where-to-get-help)
  - [Contribution guidelines](#contribution-guidelines)
  - [Dependencies](#dependencies)
    - [Efferent (fan-out)](#efferent-fan-out)
    - [Development Dependencies](#development-dependencies)
    - [Afferent (fan-in)](#afferent-fan-in)
  - [Related projects](#related-projects)
  - [License](#license)


## Introduction

**woad** provides the smallest useful set of fixed ANSI SGR colour sequences for library authors. It is not a console or TUI framework.

**woad.Zig** is the **Zig** implementation.


## Developer Experience

**woad.Zig** builds with Zig **0.17.1**. It has no dependencies.

```bash
zig build test
zig build run-example
```

The smallest useful call emits a sequence only when the writer supports colour:

```zig
const std = @import("std");
const woad = @import("woad");

pub fn main(init: std.process.Init) !void {
    var buffer: [256]u8 = undefined;
    var stdout_impl = std.Io.File.stdout().writer(init.io, &buffer);
    const stdout = &stdout_impl.interface;

    try stdout.print("{s}ok{s}\n", .{
        woad.seqFor(woad.FG_GREEN, stdout),
        woad.seqFor(woad.RESET, stdout),
    });
    try stdout.flush();
}
```

That is the opening of [examples/show_colours.zig](./examples/show_colours.zig). Every swatch in that program goes through `seqFor` as well. Fixed sequences (`BOLD`, `BLINKING`, `FG_*`, `BG_*`) always contain the SGR bytes. `colourPolicy`, `supportsColour`, and `seqFor` apply the cached environment policy. `isTty` reports attachment only. `refresh` drops that cache.

On Unix a terminal supports colour when the policy is automatic and `TERM` is not `dumb`. Windows virtual-terminal mode and mintty recognition are not implemented.


## Installation

Add **woad.Zig** to your `build.zig.zon`:

```zig
.{
    .name = "my-project",
    .version = "0.1.0",
    .dependencies = .{
        .woad = .{
            .url = "https://github.com/synesissoftware/woad.Zig/archive/refs/tags/0.1.0-alpha1.tar.gz",
            // .hash = "...",
        },
    },
}
```

Then import and expose the module in your `build.zig`:

```zig
const woad_dep = b.dependency("woad", .{
    .target = target,
    .optimize = optimize,
});
exe.root_module.addImport("woad", woad_dep.module("woad"));
```


## Components

**woad.Zig** ships fixed SGR sequences (`BLINKING`, `BOLD`, `RESET`, `FG_*`, `BG_*`, including bright variants), `VERSION`, and the portable colour policy: `colourPolicy`, `refresh`, `isTty`, `supportsColour`, and `seqFor`. On Unix a terminal supports colour when the policy is automatic and `TERM` is not `dumb`. Windows virtual-terminal gating, `WOAD_SET_CONSOLE_MODE`, and mintty recognition are not implemented.

```zig
const std = @import("std");
const woad = @import("woad");

pub fn main(init: std.process.Init) !void {
    var buffer: [256]u8 = undefined;
    var stdout_impl = std.Io.File.stdout().writer(init.io, &buffer);
    const stdout = &stdout_impl.interface;

    try stdout.print("{s}ok{s}\n", .{
        woad.seqFor(woad.FG_GREEN, stdout),
        woad.seqFor(woad.RESET, stdout),
    });
    try stdout.flush();
}
```


## Examples

See [EXAMPLES.md](./EXAMPLES.md). Run the sample with:

```bash
zig build run-example
```


## Project Information


### Where to get help

[GitHub Page](https://github.com/synesissoftware/woad.Zig "GitHub Page")


### Contribution guidelines

Defect reports, feature requests, and pull requests are welcome on https://github.com/synesissoftware/woad.Zig.


### Dependencies


#### Efferent (fan-out)

None.


#### Development Dependencies

None.


#### Afferent (fan-in)

None (currently).


### Related projects

* [**woad**](https://github.com/synesissoftware/woad/)
* [**woad.Go**](https://github.com/synesissoftware/woad.Go/)
* [**woad.NET**](https://github.com/synesissoftware/woad.NET/)
* [**woad.Python**](https://github.com/synesissoftware/woad.Python/)
* [**woad.Ruby**](https://github.com/synesissoftware/woad.Ruby/)
* [**woad.Rust**](https://github.com/synesissoftware/woad.Rust/)


### License

**woad.Zig** is released under the 3-clause BSD license. See [LICENSE](./LICENSE) for details.


<!-- ########################### end of file ########################### -->
