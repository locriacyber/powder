const std = @import("std");

fn getPathOfThisFile() []const u8 {
    return std.fs.path.dirname(@src().file).?;
}

const root = getPathOfThisFile();

/// make absolute path from path relative to this file
fn resolvePath(allocator: std.mem.Allocator, path: []const u8) []const u8 {
    return std.fs.path.resolve(allocator, &.{root, path}) catch unreachable;
}

pub fn addTo(b: *std.build.Builder, exe: *std.build.LibExeObjStep) void {
    const lib = b.addObject("hamfake", resolvePath(b.allocator, "src/main.zig"));
    lib.setBuildMode(exe.build_mode);
    lib.setTarget(exe.target);
    exe.addObject(lib);
    exe.addIncludeDir(resolvePath(b.allocator, "src"));
    //exe.target
    //exe.build_mode
}
