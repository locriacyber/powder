const rl = @import("raylib.zig");

const TILE_SIZE = 8;
const HAM_SCRW = TILE_SIZE * 32;
const HAM_SCRH = TILE_SIZE * 24;

var glb_rawscreen: [HAM_SCRW*HAM_SCRH]u16 = undefined;

export fn hamfake_setFullScreen(val: bool) void {
    if (val != rl.IsWindowFullscreen())
        rl.ToggleFullscreen();
}

export fn hamfake_isFullScreen() bool {
    return rl.IsWindowFullscreen();
}

export fn hamfake_lockScreen() [*c]u16 {
    rl.BeginDrawing();
    return @ptrCast([*c]u16, &glb_rawscreen[TILE_SIZE + 2 * TILE_SIZE * HAM_SCRW]);
}

export fn hamfake_unlockScreen(screen: [*c]u16) void {
    _ = screen;
    rl.EndDrawing();
}

export fn hamfake_rebuildScreen() void {
    // TODO
}
