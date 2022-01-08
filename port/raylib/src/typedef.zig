pub const tile_info = extern struct {
    numtiles: c_int,
    tiles: [*c][*c]u8,
    tiles16: [*c][*c]u16,
};

pub const map_info = extern struct {
    width: c_int,
    height: c_int,
    tiles: [*c]c_int,
};

pub const bg_info = extern struct {
    mi: *map_info,
    ti: *tile_info,
    scrollx: c_int,
    scrolly: c_int,
};
// pub extern var ham_bg: [*c]struct_bg_info;
pub const FAKE_BUTTONS = enum(c_int) {
    UP = 0,
    DOWN = 1,
    LEFT = 2,
    RIGHT = 3,
    A = 4,
    B = 5,
    START = 6,
    SELECT = 7,
    R = 8,
    L = 9,
    X = 10,
    Y = 11,
    TOUCH = 12,
    LID = 13,
};

// TODO export FAKE_BUTTONS_{BUTTON} and 
// NUM_FAKE_BUTTONS