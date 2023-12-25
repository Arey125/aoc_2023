const std = @import("std");

const ArrayList = std.ArrayList;

var gpa_s = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = gpa_s.allocator();

fn getLine(buffer: []u8) !?[]u8 {
    const stdin = std.io.getStdIn().reader();
    return try stdin.readUntilDelimiterOrEof(buffer, '\n');
}

const Direction = enum {
    Down,
    Right,
    Up,
    Left,
};

const Pos = struct {
    x: u32,
    y: u32,
};

fn getNextPosition(pos: Pos, dir: Direction) Pos {
    const new_y = switch (dir) {
        Direction.Down => pos.x + 1,
        Direction.Up => pos.x - 1,
    };

   const new_x = switch (dir) {
        Direction.Right => pos.y + 1,
        Direction.Left => pos.y - 1,
    };

    return .{ .x = new_x, .y = new_y };
}

fn getNextDirection(dir: Direction, c: u8) Direction {
    return switch (c) {
        '|' => switch (dir) {
            .Up => .Up,
            .Down => .Down,
        },

        '-' => switch (dir) {
            .Left => .Left,
            .Right => .Right,
        },

        'L' => switch (dir) {
            .Down => .Right,
            .Left => .Up,
        },

        'J' => switch (dir) {
            .Down => .Left,
            .Right => .Up,
        },

        '7' => switch (dir) {
            .Up => .Left,
            .Right => .Down,
        },

        'F' => switch (dir) {
            .Up => .Right,
            .Left => .Down,
        },
        else => unreachable,
    };
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    _ = stdout;

    var map = ArrayList([256]u8).init(gpa);
    defer map.deinit();

    while (true) {
        try map.append(undefined);
        if (try getLine(map.getLast()) == null) {
            _ = map.pop();
            break;
        }
    }

    const n = map.items.len;
    const m = map.items.len;
    const animal_pos = outer: for (0..n) |i|
}
