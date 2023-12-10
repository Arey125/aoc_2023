const std = @import("std");
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();
const stdout = std.io.getStdOut().writer();

fn getLine(buffer: []u8) !?[]u8 {
    const stdin = std.io.getStdIn().reader();
    return try stdin.readUntilDelimiterOrEof(buffer, '\n');
}

fn getNumber(line: []const u8) !u64 {
    const colonPos = std.mem.indexOf(u8, line, ":") orelse 0;
    const numberLine = line[colonPos + 1 ..];
    var numberIterator = std.mem.tokenizeAny(u8, numberLine, " ");
    var result = std.ArrayList(u8).init(allocator);

    while (numberIterator.next()) |token| {
        try result.appendSlice(token);
    }

    return std.fmt.parseInt(u64, result.items, 10);
}

fn solve(time: u64, distance: u64) u64 {
    var result: u64 = 0;
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

    const times = try getNumber(timeLine);
    const distances = try getNumber(distanceLine);

    const result = solve(times, distances);

    try stdout.print("{}\n", .{result});
}
