const builtin = @import("builtin");
const std = @import("std");
const CrossTarget = std.zig.CrossTarget;
const ReleaseMode = std.builtin.Mode;

// target platform of intermediate build tools, which is always native
pub const nativeTarget = CrossTarget.fromTarget(builtin.target);

pub const SimpleBuildTool = struct {
    comptime name: []const u8 = "unnamed-buildtool",
    entry: []const u8, // main.cpp, as you will
    args: []const []const u8,
    cwd: []const u8 = "src",
    target: CrossTarget = nativeTarget,
    mode: ReleaseMode = ReleaseMode.Debug,
};

pub const enummaker = SimpleBuildTool {
    .name = "enummaker",
    .entry = "support/enummaker/enummaker.cpp",
    .args = &.{"source.txt"},
};

pub const encyclopedia2c = SimpleBuildTool {
    .name = "encyclopedia2c",
    .entry = "support/encyclopedia2c/encyclopedia2c.cpp",
    .args = &.{"encyclopedia.txt"},
};

pub const allBuildTools = [_]SimpleBuildTool{
    enummaker,
    // TODO blocked by zig compiler regression
    // encyclopedia2c,
    // TODO add those build tools, then remove their results from git & add to .gitignore
    // generate_all_bitmaps
    // generate_allrooms
};
