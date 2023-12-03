const std = @import("std");
const expect = std.testing.expect;

fn getLine(buffer: []u8) !?[]u8 {
    const stdin = std.io.getStdIn().reader();
    return try stdin.readUntilDelimiterOrEof(buffer, '\n');
}

const Set = struct {
    red: u32,
    green: u32,
    blue: u32,
};

fn parseSet(line: []const u8) Set {
    var result = Set{ .red = 0, .green = 0, .blue = 0 };

    var item_iterator = std.mem.split(u8, line, ", ");
    while (item_iterator.next()) |item_string| {
        const space_pos = std.mem.indexOf(u8, item_string, " ") orelse continue;
        const value = std.fmt.parseInt(u8, item_string[0..space_pos], 10) catch 0;
        const name = item_string[space_pos + 1 ..];

        if (std.mem.eql(u8, name, "red"))
            result.red = value;
        if (std.mem.eql(u8, name, "green"))
            result.green = value;
        if (std.mem.eql(u8, name, "blue"))
            result.blue = value;
    }
    return result;
}

fn gameResult(game_line: []const u8) u32 {
    const game_data_start = std.mem.indexOf(u8, game_line, ": ").? + 2;
    var set_iterator = std.mem.split(u8, game_line[game_data_start..], "; ");

    var result = Set{ .red = 0, .green = 0, .blue = 0 };

    while (set_iterator.next()) |set_line| {
        const set = parseSet(set_line);

        result.red = @max(result.red, set.red);
        result.green = @max(result.green, set.green);
        result.blue = @max(result.blue, set.blue);
    }
    return result.red * result.green * result.blue;
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var result: u32 = 0;

    var buffer: [4096]u8 = undefined;
    var i: u32 = 1;
    while (try getLine(&buffer)) |line| : (i += 1) {
        result += gameResult(line);
    }

    try stdout.print("{}\n", .{result});
}

test "parse set" {
    const set = parseSet("3 blue, 4 red");
    try expect(set.red == 4 and set.green == 0 and set.blue == 3);
}

test "game result" {
    try expect(gameResult("Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green") == 48);
}
