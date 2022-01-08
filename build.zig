const std = @import("std");
const buildtools = @import("build/tools.zig");

const CrossTarget = std.zig.CrossTarget;
const ReleaseMode = std.builtin.Mode;
const Builder = std.build.Builder;
const Step = std.build.Step;
const RunStep = std.build.RunStep;
const LibExeObjStep = std.build.LibExeObjStep;

pub fn build(b: *Builder) !void {
    // where the build tools and the game will be
    const installPath = try std.fmt.allocPrint(b.allocator, "{s}/bin", .{b.install_path});
    b.getInstallStep().dependOn(&b.addLog("Executables will be built at: {s}\n", .{installPath}).step);

    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    
    // target platform of Powder, set with -target arch-os-abi
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const powder = buildPowder(b, target, mode);

    buildtools.addDependenciesTo(b, installPath, &powder.step);
    
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
    exe.install();
    
    exe.linkLibCpp();
    exe.addIncludeDir("."); // for room/*.h and gfx/*.h
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
        "src/encyclopedia.cpp",
        "src/encyc_support.cpp",
        "src/gfxengine.cpp",
        "src/glbdef.cpp",
        "src/grammar.cpp",
        "src/hiscore.cpp",
        "src/input.cpp",
        "src/intrinsic.cpp",
        "src/item.cpp",
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
        "src/victory.cpp",
        "rooms/allrooms.cpp",
        "gfx/all_bitmaps.cpp",
    }, &.{});

    addHamFake(b, exe, HamBackend.Raylib);

    return exe;
}

const HamBackend = enum {
    SDL, // SDL 1.2
    Raylib,
};

// Add hamfake implementation
fn addHamFake(b: *Builder, exe: *LibExeObjStep, backend: HamBackend) void {
    switch (backend) {
        .SDL => {
            // TODO vender SDL
            // it is a mystery how this compiler even finds #include "SDL.h" by itself
            exe.linkSystemLibrary("SDL");
            exe.addIncludeDir("port/sdl");
            exe.addCSourceFiles(&.{
                "port/sdl/hamfake.cpp",
            }, &.{});
        },
        .Raylib => {
            exe.linkSystemLibrary("raylib");
            @import("port/raylib/build.zig").addTo(b, exe);
        },
    }
}

pub fn run(b: *Builder, exe: *LibExeObjStep, args: []const []const u8) *RunStep {
    const run_cmd = exe.run();
    run_cmd.addArgs(args);
    _ = b;
    return run_cmd;
}

// Register executable so it can be ran with `zig build <cmdName>`
pub fn registerCommand(b: *Builder, exe: *LibExeObjStep, cmdName: []const u8, cmdDesc: []const u8) void {
    const run_cmd = run(b, exe, args: {
        if (b.args) |args| break :args args;
        break :args &.{};
    });
    
    const run_step = b.step(cmdName, cmdDesc);
    run_step.dependOn(&run_cmd.step);
}
