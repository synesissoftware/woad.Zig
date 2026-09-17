# woad.Zig <!-- omit in toc -->

Minimal ANSI terminal colour codes, for Zig

![Language](https://img.shields.io/badge/Zig-F7A41D?style=flat&logo=zig&logoColor=white)
[![License](https://img.shields.io/badge/License-BSD_3--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)
[![GitHub release](https://img.shields.io/github/v/release/synesissoftware/woad.Zig.svg)](https://github.com/synesissoftware/woad.Zig/releases/latest)
[![Last Commit](https://img.shields.io/github/last-commit/synesissoftware/woad.Zig)](https://github.com/synesissoftware/woad.Zig/commits/master)
[![CI](https://github.com/synesissoftware/woad.Zig/actions/workflows/ci.yml/badge.svg)](https://github.com/synesissoftware/woad.Zig/actions/workflows/ci.yml)


## Table of Contents <!-- omit in toc -->

- [Introduction](#introduction)
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


## Installation

Add **woad.Zig** to your `build.zig.zon`:

```zig
.{
    .name = "my-project",
    .version = "0.1.0",
    .dependencies = .{
        .woad = .{
            .url = "https://github.com/synesissoftware/woad.Zig/archive/refs/tags/0.0.1.tar.gz",
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

**woad.Zig** ships SGR string constants (`RESET`, `FG_*`, `BG_*`, including bright variants) and `VERSION`. TTY/stream gating and Windows virtual-terminal opt-in are not implemented yet.

```zig
const std = @import("std");
const woad = @import("woad");

pub fn main(init: std.process.Init) !void {
    var buffer: [256]u8 = undefined;
    var stdout_impl = std.Io.File.stdout().writer(init.io, &buffer);
    const stdout = &stdout_impl.interface;

    try stdout.print("{s}ok{s}\n", .{ woad.FG_GREEN, woad.RESET });
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
