var sram: [0x10000]u8 = undefined;

export fn hamfake_writeLockSRAM() [*c]u8 {
    return @ptrCast([*c]u8, &sram);
}

export fn hamfake_writeUnlockSRAM(_: [*c]u8) void {
    // noop
}

export fn hamfake_readLockSRAM() [*c]u8 {
    return @ptrCast([*c]u8, &sram);
}

export fn hamfake_readUnlockSRAM(_: [*c]u8) void {
    // noop
}
