const std = @import("std");
var gpa_s = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = gpa_s.allocator();

const expect = std.testing.expect;

fn getLine(buffer: []u8) !?[]u8 {
    const stdin = std.io.getStdIn().reader();
    return try stdin.readUntilDelimiterOrEof(buffer, '\n');
}

fn getValues(line: []const u8) !std.ArrayList(i64) {
    var res = std.ArrayList(i64).init(gpa);
    var token_it = std.mem.splitScalar(u8, line, ' ');
    while (token_it.next()) |token| {
        try res.append(try std.fmt.parseInt(i64, token, 10));
    }

    return res;
}

fn getNext(values: []const i64) !i64 {
    if (std.mem.count(i64, values, &[_]i64{0}) == values.len) {
        return 0;
    }
    var diffs = try gpa.alloc(i64, values.len - 1);
    for (diffs, 0..) |*diff, i| {
        diff.* = values[i + 1] - values[i];
    }
    return try getNext(diffs) + values[values.len - 1];
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var res: i64 = 0;

    var buffer: [1024]u8 = undefined;
    while (try getLine(&buffer)) |line| {
        var values = try getValues(line);
        defer values.deinit();

        res += try getNext(values.items);
    }

    try stdout.print("{}\n", .{res});
}

test "get values" {
    const values = try getValues("0 3 6 9 12 15");
    try expect(std.mem.eql(i64, values.items, &[_]i64{ 0, 3, 6, 9, 12, 15 }));
}

test "get next" {
    const values1 = [_]i64{ 0, 0, 0 };
    try expect(try getNext(&values1) == 0);

    const values2 = [_]i64{ 1, 1, 1 };
    try expect(try getNext(&values2) == 1);

    const values3 = [_]i64{ 0, 3, 6, 9, 12, 15 };
    try expect(try getNext(&values3) == 18);
}
