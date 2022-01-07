const std = @import("std");
const builtin = @import("builtin");
const Builder = std.build.Builder;
const LibExeObjStep = std.build.LibExeObjStep;
const CrossTarget = std.zig.CrossTarget;
const ReleaseMode = std.builtin.Mode;
const Step = std.build.Step;
const RunStep = std.build.RunStep;

pub fn build(b: *Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    
    // target platform of Powder, set with -target arch-os-abi
    const target = b.standardTargetOptions(.{});

    // target platform of intermediate build tools, which is always native
    const nativeTarget = CrossTarget.fromTarget(builtin.target);

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    // build enummaker    
    const enummaker = buildSupportScript(b, "support/enummaker/enummaker.cpp", nativeTarget, mode);
    registerCommand(b, enummaker, "enummaker", "Run enummaker");
    
    // Build glbdef.h and glbdef.cpp
    const generate_glbdef = run(b, enummaker, &.{"source.txt"});
    generate_glbdef.cwd = "src";

    const encyclopedia2c = buildSupportScript(b, "support/encyclopedia2c/encyclopedia2c.cpp", nativeTarget, mode);
    registerCommand(b, encyclopedia2c, "encyclopedia2c", "Run encyclopedia2c");

    const generate_encyclopedia = run(b, enummaker, &.{"encyclopedia.txt"});
    generate_encyclopedia.cwd = "src";

    // TODO add those build tools
    // powder.step.dependOn(&generate_all_bitmaps.step);
    // powder.step.dependOn(&generate_allrooms.step);

    const powder = buildPowder(b, target, mode);
    powder.step.dependOn(&generate_glbdef.step);
    // TODO blocked by zig compiler regression
    // powder.step.dependOn(&generate_encyclopedia.step);

    // const powder = buildPowder(b);
    
    registerCommand(b, powder, "run", "Run Powder");

    // add test step
    // const exe_tests = b.addTest("src/main.zig");
    // exe_tests.setTarget(target);
    // exe_tests.setBuildMode(mode);

    // const test_step = b.step("test", "Run unit tests");
    // test_step.dependOn(&exe_tests.step)
}

fn buildPowder(b: *Builder, target: CrossTarget, mode: ReleaseMode) *LibExeObjStep {
    const exe = b.addExecutable("powder", "src/main.cpp");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.linkLibCpp();
    exe.addCSourceFiles(&.{
        "src/action.cpp",
        "src/ai.cpp",
        "src/artifact.cpp",
        "src/assert.cpp",
        "src/bmp.cpp",
        "src/buf.cpp",
        "src/build.cpp",
        "src/control.cpp",
        "src/creature.cpp",
        "src/dpdf_table.cpp",
        "src/encyc_support.cpp",
        "src/gfxengine.cpp",
        "src/glbdef.cpp",
        "src/grammar.cpp",
        "src/hiscore.cpp",
        "src/input.cpp",
        "src/intrinsic.cpp",
        "src/item.cpp",
        "src/main.cpp",
        "src/map.cpp",
        "src/mobref.cpp",
        "src/msg.cpp",
        "src/name.cpp",
        "src/piety.cpp",
        "src/rand.cpp",
        "src/signpost.cpp",
        "src/smokestack.cpp",
        "src/speed.cpp",
        "src/sramstream.cpp",
        "src/stylus.cpp",
        // "src/thread.cpp",
        "src/victory.cpp",
    }, &.{});
    exe.addIncludeDir(".");
    exe.addIncludeDir("port/sdl");
    exe.install();
    return exe;
}

fn buildSupportScript(b: *Builder, comptime entry: []const u8, target: CrossTarget, mode: ReleaseMode) *LibExeObjStep {
    const exe = b.addExecutable("enummaker", entry);
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.linkLibCpp();
    return exe;
}

fn run(b: *Builder, exe: *LibExeObjStep, args: []const []const u8) *RunStep {
    const run_cmd = exe.run();
    run_cmd.addArgs(args);
    _ = b;
    return run_cmd;
}

// Register executable so it can be ran with `zig build <cmdName>`
fn registerCommand(b: *Builder, exe: *LibExeObjStep, comptime cmdName: []const u8, comptime cmdDesc: []const u8) void {
    const run_cmd = run(b, exe, args: {
        if (b.args) |args| break :args args;
        break :args &.{};
    });
    
    const run_step = b.step(cmdName, cmdDesc);
    run_step.dependOn(&run_cmd.step);
}