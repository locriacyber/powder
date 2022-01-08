const builtin = @import("builtin");
const std = @import("std");
const CrossTarget = std.zig.CrossTarget;
const ReleaseMode = std.builtin.Mode;
const Builder = std.build.Builder;
const Step = std.build.Step;
const RunStep = std.build.RunStep;
const LibExeObjStep = std.build.LibExeObjStep;

const run = @import("build.zig").run;
const registerCommand = @import("build.zig").registerCommand;

// target platform of intermediate build tools, which is always native
pub const nativeTarget = CrossTarget.fromTarget(builtin.target);

pub const SimpleBuildTool = struct {
    name: []const u8,
    entry: []const u8, // main.cpp, as you will
    additional: []const []const u8 = &.{}, // more source files
    args: []const []const u8 = .{},
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

pub const bmp2c = SimpleBuildTool {
    .name = "bmp2c",
    .entry = "support/bmp2c/bmp2c.cpp",
    .cwd = "gfx",
};

pub const map2c = SimpleBuildTool {
    .name = "map2c",
    .entry = "support/map2c/map2c.cpp",
};

pub const tile2c = SimpleBuildTool {
    .name = "tile2c",
    .entry = "support/tile2c/tile2c.cpp",
    .additional = &.{"support/tile2c/bmp.cpp"},
};

// TODO add those build tools, then remove their results from git & add to .gitignore
// generate_allrooms

// build scripts that only run once
const onceBuildTools = [_]SimpleBuildTool{
    enummaker,
    
    // TODO enable the following stuff, blocked by zig compiler bug https://github.com/ziglang/zig/issues/10386
    // encyclopedia2c,
};

pub fn addDependenciesTo(b: *Builder, installPath: []const u8, step: *Step) void {
    for (onceBuildTools) |tool| {
        const toolStep = buildAndRunToolStep(b, tool);
        step.dependOn(&toolStep.runStep.step);
    }
    
    // TODO the following tools are blocked by zig compiler bug
    _ = installPath;
    // // generate rooms
    // // allrooms.h & allrooms.cpp
    // {
    //     const map2c = try buildAndRunToolStep(b, buildtools.map2c);
        
    //     const buildrooms = b.addSystemCommand(&.{b.pathFromRoot("rooms/buildrooms.bash")});
    //     buildrooms.cwd = "rooms";
    //     buildrooms.addPathDir(installPath);
    //     buildrooms.step.dependOn(&map2c.exe.install_step.?.step);
    //     step.dependOn(&buildrooms.step);
    // }
    
    // // generate tiles
    // {
    //     const tile2c = try buildAndRunToolStep(b, buildtools.tile2c);
    //     const bmp2c = try buildAndRunToolStep(b, buildtools.bmp2c);
        
    //     const buildtiles = b.addSystemCommand(&.{b.pathFromRoot("gfx/rebuild.sh")});
    //     buildtiles.cwd = "gfx";
    //     buildtiles.addPathDir(installPath);
    //     buildtiles.step.dependOn(&tile2c.exe.install_step.?.step);
    //     buildtiles.step.dependOn(&bmp2c.exe.install_step.?.step);
    //     step.dependOn(&buildtiles.step);
    // }

}

const BuildToolStep = struct {
    exe: *LibExeObjStep,
    runStep: *RunStep,
};

// returns a Step of running a certain build tool with given arguments
fn buildAndRunToolStep(b: *Builder, tool: SimpleBuildTool) BuildToolStep {
    const exe = b.addExecutable(tool.name, tool.entry);
    exe.setTarget(tool.target);
    exe.setBuildMode(tool.mode);
    exe.install();
    
    exe.linkLibCpp();
    exe.addCSourceFiles(tool.additional, &.{});

    registerCommand(b, exe, tool.name, std.fmt.allocPrint(b.allocator, "Run {s}", .{tool.name}) catch unreachable);
        
    const generateFileStep = run(b, exe, tool.args);
    generateFileStep.cwd = tool.cwd;
    return BuildToolStep{
        .exe = exe,
        .runStep = generateFileStep,
    };
}
