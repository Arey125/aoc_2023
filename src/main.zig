const std = @import("std");
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();
const stdout = std.io.getStdOut().writer();

fn getLine(buffer: []u8) !?[]u8 {
    const stdin = std.io.getStdIn().reader();
    return try stdin.readUntilDelimiterOrEof(buffer, '\n');
}

fn getNumbers(line: []const u8) !std.ArrayList(i32) {
    const colonPos = std.mem.indexOf(u8, line, ":") orelse 0;
    const numberLine = line[colonPos + 1 ..];
    var numberIterator = std.mem.tokenizeAny(u8, numberLine, " ");
    var result = std.ArrayList(i32).init(allocator);

    while (numberIterator.next()) |token| {
        try result.append(try std.fmt.parseInt(i32, token, 10));
    }

    return result;
}

fn solve(time: u32, distance: u32) u32 {
    var result: u32 = 0;
    for (0..time + 1) |hold| {
        const current_distance = (time - hold) * hold;
        if (current_distance > distance) {
            result += 1;
        }
    }
    return result;
}

pub fn main() !void {
    var timeBuffer: [1024]u8 = undefined;
    var distanceBuffer: [1024]u8 = undefined;
    const timeLine = try getLine(&timeBuffer) orelse "";
    const distanceLine = try getLine(&distanceBuffer) orelse "";

    const times = try getNumbers(timeLine);
    const distances = try getNumbers(distanceLine);
    const n = times.items.len;

    var result: u32 = 1;
    for (0..n) |i| {
        const time = times.items[i];
        const distance = distances.items[i];

        result *= solve(@intCast(time), @intCast(distance));
    }

    try stdout.print("{}\n", .{result});
}
