const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Create a module for other packages to import
    const woad_module = b.addModule("woad", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Static library using the module
    const lib = b.addLibrary(.{
        .name = "woad",
        .linkage = .static,
        .root_module = woad_module,
    });
    b.installArtifact(lib);

    // Unit tests using the module
    const lib_unit_tests = b.addTest(.{
        .root_module = woad_module,
    });
    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);

    // Example: show_colours
    const example = b.addExecutable(.{
        .name = "show_colours",
        .root_module = b.createModule(.{
            .root_source_file = b.path("examples/show_colours.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    example.root_module.addImport("woad", woad_module);
    b.installArtifact(example);

    const run_example = b.addRunArtifact(example);
    if (b.args) |args| {
        run_example.addArgs(args);
    }

    const run_example_step = b.step("run-example", "Run the show_colours example");
    run_example_step.dependOn(&run_example.step);
}
