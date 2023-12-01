const std = @import("std");
const expect = std.testing.expect;

fn getLine(buffer: []u8) !?[]u8 {
    const stdin = std.io.getStdIn().reader();
    return try stdin.readUntilDelimiterOrEof(buffer, '\n');
}

const Digit = struct {
    name: []const u8,
    value: u32,
};

const digits = [_]Digit{
    Digit{ .name = "one", .value = 1 },
    Digit{ .name = "two", .value = 2 },
    Digit{ .name = "three", .value = 3 },
    Digit{ .name = "four", .value = 4 },
    Digit{ .name = "five", .value = 5 },
    Digit{ .name = "six", .value = 6 },
    Digit{ .name = "seven", .value = 7 },
    Digit{ .name = "eight", .value = 8 },
    Digit{ .name = "nine", .value = 9 },
};

fn getFirstValue(line: []const u8) u32 {
    var first_digit_pos: usize = for (line, 0..) |c, i| {
        if (std.ascii.isDigit(c))
            break i;
    } else line.len;
    var pos = first_digit_pos;

    var value: ?u32 = if (pos < line.len)
        line[pos] - '0'
    else
        null;

    for (digits) |digit| {
        const digit_pos = std.mem.indexOf(u8, line[0..first_digit_pos], digit.name) orelse continue;
        if (pos < digit_pos)
            continue;
        pos = digit_pos;
        value = digit.value;
    }

    return value orelse 0;
}

fn getLastValue(line: []const u8) u32 {
    var last_digit_pos: usize = 0;
    for (line, 0..) |c, i| {
        if (std.ascii.isDigit(c))
            last_digit_pos = @as(usize, i);
    }
    var pos = last_digit_pos;

    var value: ?u32 = if (pos < line.len)
        line[pos] - '0'
    else
        null;

    for (digits) |digit| {
        const digit_pos = std.mem.lastIndexOf(u8, line, digit.name) orelse continue;
        if (pos > digit_pos)
            continue;
        pos = digit_pos;
        value = digit.value;
    }

    return value orelse 0;
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var result: u32 = 0;

    var buffer: [1024]u8 = undefined;
    while (try getLine(&buffer)) |line| {
        result += getFirstValue(line) * 10;
        result += getLastValue(line);
    }

    try stdout.print("{}\n", .{result});
}

test "first digit" {
    try expect(getFirstValue("two1nine") == 2);
    try expect(getFirstValue("eightwothree") == 8);
    try expect(getFirstValue("abcone2threexyz") == 1);
}

test "last digit" {
    try expect(getLastValue("two1nine") == 9);
    try expect(getLastValue("eightwothree") == 3);
    try expect(getLastValue("abcone2threexyz") == 3);
}
