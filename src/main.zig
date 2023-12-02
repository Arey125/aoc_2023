const std = @import("std");
const expect = std.testing.expect;

fn getLine(buffer: []u8) !?[]u8 {
    const stdin = std.io.getStdIn().reader();
    return try stdin.readUntilDelimiterOrEof(buffer, '\n');
}

fn isSetPossible(line: []const u8) bool {
    var item_iterator = std.mem.split(u8, line, ", ");
    while (item_iterator.next()) |item_string| {
        const space_pos = std.mem.indexOf(u8, item_string, " ") orelse continue;
        const value = std.fmt.parseInt(u8, item_string[0..space_pos], 10) catch 0;
        const name = item_string[space_pos + 1 ..];

        if (std.mem.eql(u8, name, "red") and value > 12)
            return false;
        if (std.mem.eql(u8, name, "green") and value > 13)
            return false;
        if (std.mem.eql(u8, name, "blue") and value > 14)
            return false;
    }
    return true;
}

fn isGamePossible(game_line: []const u8) bool {
    const game_data_start = std.mem.indexOf(u8, game_line, ": ").? + 2;
    var set_iterator = std.mem.split(u8, game_line[game_data_start..], "; ");

    while (set_iterator.next()) |set_line| {
        if (!isSetPossible(set_line))
            return false;
    }
    return true;
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var result: u32 = 0;

    var buffer: [4096]u8 = undefined;
    var i: u32 = 1;
    while (try getLine(&buffer)) |line| : (i += 1) {
        if (isGamePossible(line))
            result += i;
    }

    try stdout.print("{}\n", .{result});
}

test "is set possible" {
    try expect(isSetPossible("3 blue, 4 red"));
    try expect(!isSetPossible("8 green, 6 blue, 20 red"));
}

test "is game possible" {
    try expect(isGamePossible("Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green"));
    try expect(!isGamePossible("Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red"));
}
