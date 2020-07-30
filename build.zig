const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();
    const lib = b.addStaticLibrary("jemalloc-zig", "src/main.zig");
    lib.addSystemIncludeDir("./src/c_include");
    lib.linkLibC();
    lib.linkSystemLibrary("jemalloc");
    lib.setBuildMode(mode);
    lib.install();

    var main_tests = b.addTest("src/main.zig");
    main_tests.addSystemIncludeDir("./src/c_include");
    main_tests.linkLibC();
    main_tests.linkSystemLibrary("jemalloc");
    main_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);
}
