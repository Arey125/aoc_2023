const std = @import("std");
const expect = std.testing.expect;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

fn getLine(buffer: []u8) !?[]u8 {
    const stdin = std.io.getStdIn().reader();
    return try stdin.readUntilDelimiterOrEof(buffer, '\n');
}

fn parseNumbers(str: []const u8) !std.ArrayList(u32) {
    var res = std.ArrayList(u32).init(allocator);

    var tokens = std.mem.tokenizeAny(u8, str, " ");
    while (tokens.next()) |token| {
        const num = try std.fmt.parseInt(u32, token, 10);
        try res.append(num);
    }

    return res;
}

fn solve(line: []const u8) !u32 {
    const semicolonPos = std.mem.indexOf(u8, line, ": ").?;
    const pipePos = std.mem.indexOf(u8, line, " | ").?;

    const winningNumberString = line[semicolonPos + 2 .. pipePos];
    const cardNumberString = line[pipePos + 3 ..];

    const winningNumbers = try parseNumbers(winningNumberString);
    const cardNumbers = try parseNumbers(cardNumberString);

    var winningNumberSet = std.AutoHashMap(u32, void).init(allocator);
    for (winningNumbers.items) |number| {
        try winningNumberSet.put(number, {});
    }
    defer winningNumberSet.deinit();

    var res: u32 = 0;
    for (cardNumbers.items) |number| {
        if (!winningNumberSet.remove(number)) {
            continue;
        }
        res += 1;
    }

    return res;
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var results = std.ArrayList(u32).init(allocator);
    var buffer: [1024]u8 = undefined;
    while (try getLine(&buffer)) |line| {
        try results.append(try solve(line));
    }
    var values = try allocator.alloc(u32, results.items.len);
    allocator.free(values);
    for (values) |*value| {
        value.* = 1;
    }

    var res: u32 = 0;
    for (0..results.items.len) |i| {
        const result = results.items[i];
        const value = values[i];

        res += value;
        for (i + 1..@min(i + result + 1, results.items.len)) |j| {
            values[j] += value;
        }
    }

    try stdout.print("{}\n", .{res});
}

test "solve" {
    try expect(try solve("Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53") == 8);
}
