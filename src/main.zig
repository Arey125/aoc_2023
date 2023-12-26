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
    x: u64,
    y: u64,
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

fn getNextDirection(dir: Direction, c: u8) ?Direction {
    return switch (c) {
        '|' => switch (dir) {
            .Up => .Up,
            .Down => .Down,
            else => null,
        },

        '-' => switch (dir) {
            .Left => .Left,
            .Right => .Right,
            else => null,
        },

        'L' => switch (dir) {
            .Down => .Right,
            .Left => .Up,
            else => null,
        },

        'J' => switch (dir) {
            .Down => .Left,
            .Right => .Up,
            else => null,
        },

        '7' => switch (dir) {
            .Up => .Left,
            .Right => .Down,
            else => null,
        },

        'F' => switch (dir) {
            .Up => .Right,
            .Left => .Down,
            else => null,
        },

        '.' => null,
        'S' => null,

        else => unreachable,
    };
}

fn getCycleLen(pos: Pos, dir: Direction, map: [][]const u8) ?u64 {
    const n = map.len;
    const m = map[0].len;

    const start_pos = getNextPosition(pos, dir);
    if (start_pos.x <= 0 or start_pos.x >= n) {
        return null;
    }
    if (start_pos.y <= 0 or start_pos.y >= m) {
        return null;
    }
    const start_dir = getNextDirection(dir, map[start_pos.x][start_pos.y]);

    var res: u64 = 0;
    var cur_pos = start_pos;
    var cur_dir = start_dir;
    while (cur_pos != pos) {
        cur_pos = getNextPosition(cur_pos, cur_dir);
        cur_dir = getNextDirection(cur_dir, map[cur_pos.x][cur_pos.y]);
        res += 1;
    }
    return res;
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var map_buffers = ArrayList([256]u8).init(gpa);
    defer map_buffers.deinit();
    var map = ArrayList([]u8).init(gpa);
    defer map.deinit();

    while (true) {
        try map.append(undefined);
        if (try getLine(map.getLast())) |line| {
            try map.append(line);
            continue;
        }
        _ = map.pop();
        break;
    }

    const n = map.items.len;
    const m = map.items[0].len;
    const animal_pos =
        outer: for (0..n) |i|
        for (0..m) |j| {
            if (map.items[i][j] == 'S')
                break :outer Pos{ .x = i, .y = j };
        };

    var result: ?u64 = null;
    const directions = [_]Direction{ .Down, .Right, .Up, .Left };
    for (&directions) |direction| {
        const len = getCycleLen(animal_pos, direction) orelse continue;
        result = if (result == null) len.? else @max(result, len.?);
    }

    stdout.print("{}\n", .{result});
}
