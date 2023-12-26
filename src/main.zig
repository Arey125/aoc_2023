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
    x: i64,
    y: i64,
};

fn getNextPosition(pos: Pos, dir: Direction) Pos {
    const new_x = switch (dir) {
        Direction.Down => pos.x + 1,
        Direction.Up => pos.x - 1,
        else => pos.x,
    };

    const new_y = switch (dir) {
        Direction.Right => pos.y + 1,
        Direction.Left => pos.y - 1,
        else => pos.y,
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
    if (start_pos.x < 0 or start_pos.x >= n) {
        return null;
    }
    if (start_pos.y < 0 or start_pos.y >= m) {
        return null;
    }
    const start_dir = getNextDirection(dir, map[@intCast(start_pos.x)][@intCast(start_pos.y)]) orelse return null;

    var res: u64 = 0;
    var cur_pos = start_pos;
    var cur_dir = start_dir;
    while (true) {
        cur_pos = getNextPosition(cur_pos, cur_dir);
        std.log.debug("{}", .{cur_pos});
        if (cur_pos.x < 0 or cur_pos.x >= n) {
            return null;
        }
        if (cur_pos.y < 0 or cur_pos.y >= m) {
            return null;
        }
        if (map[@intCast(cur_pos.x)][@intCast(cur_pos.y)] == 'S') {
            std.log.debug("S", .{});
            break;
        }
        cur_dir = getNextDirection(cur_dir, map[@intCast(cur_pos.x)][@intCast(cur_pos.y)]) orelse return null;
        res += 1;
    }
    return res;
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var map_buffers = std.SegmentedList([256]u8, 1024){};
    defer map_buffers.deinit(gpa);
    var map = ArrayList([]u8).init(gpa);
    defer map.deinit();

    while (true) {
        try map_buffers.append(gpa, undefined);
        var last = map_buffers.at(map_buffers.len - 1);
        if (try getLine(last)) |line| {
            try map.append(line);
            continue;
        }
        _ = map_buffers.pop();
        break;
    }

    const n = map.items.len;
    const m = map.items[0].len;
    const animal_pos = outer: for (0..n) |i| {
        for (0..m) |j| {
            std.log.debug("{} {}", .{ i, j });
            if (map.items[i][j] == 'S')
                break :outer Pos{ .x = @intCast(i), .y = @intCast(j) };
        }
    } else unreachable;

    var result: ?u64 = null;
    const directions = [_]Direction{ .Down, .Right, .Up, .Left };
    for (directions) |direction| {
        std.log.debug("", .{});
        const len = getCycleLen(animal_pos, direction, map.items) orelse continue;
        std.log.debug("{}", .{len});
        result = if (result) |non_null_res|
            @max(non_null_res, len)
        else
            len;
    }

    if (result) |res|
        try stdout.print("{}\n", .{res / 2 + 1});
}
