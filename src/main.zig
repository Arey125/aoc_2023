const std = @import("std");
const ArenaAllocator = std.heap.ArenaAllocator;
var gpa_struct = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = gpa_struct.allocator();

fn getLine(buffer: []u8) !?[]u8 {
    const stdin = std.io.getStdIn().reader();
    return try stdin.readUntilDelimiterOrEof(buffer, '\n');
}

const Hand = struct {
    hand: []const u8,
    bid: u32,
};

fn parseHand(line: []const u8) !Hand {
    const spacePos = std.mem.indexOf(u8, line, " ").?;
    return Hand{
        .hand = line[0..spacePos],
        .bid = try std.fmt.parseInt(u32, line[spacePos + 1 ..], 10),
    };
}

const Card = struct {
    value: u8,
    count: u32,
};

fn cardComparator(_: void, a: Card, b: Card) bool {
    return a.count > b.count;
}

fn handType(hand: Hand) u32 {
    var handStr: [5]u8 = undefined;

    for (0..5) |i| {
        handStr[i] = hand.hand[i];
    }

    std.mem.sort(u8, &handStr, {}, std.sort.asc(u8));

    var cards = std.ArrayList(Card).init(gpa);
    for (handStr) |card| {
        if (cards.items.len == 0) {
            cards.append(Card{ .value = card, .count = 1 }) catch unreachable;
            continue;
        }

        if (cards.items[cards.items.len - 1].value == card) {
            cards.items[cards.items.len - 1].count += 1;
            continue;
        }

        cards.append(Card{ .value = card, .count = 1 }) catch unreachable;
    }

    std.mem.sort(Card, cards.items, {}, cardComparator);

    const firstCardCount = cards.items[0].count;

    if (firstCardCount == 5)
        return 6;

    const secondCardCount = cards.items[1].count;

    if (firstCardCount == 4)
        return 5;

    if (firstCardCount == 1)
        return 0;

    if (firstCardCount == 3) {
        if (secondCardCount == 2)
            return 4;
        return 3;
    }

    if (secondCardCount == 2)
        return 2;

    return 1;
}

fn getCardValue(card: u8) u8 {
    return switch (card) {
        '2' => 2 + '0',
        '3' => 3 + '0',
        '4' => 4 + '0',
        '5' => 5 + '0',
        '6' => 6 + '0',
        '7' => 7 + '0',
        '8' => 8 + '0',
        '9' => 9 + '0',
        'T' => 10 + '0',
        'J' => 11 + '0',
        'Q' => 12 + '0',
        'K' => 13 + '0',
        'A' => 14 + '0',
        else => unreachable,
    };
}

fn handComparator(_: void, a: Hand, b: Hand) bool {
    const a_type = handType(a);
    const b_type = handType(b);
    if (a_type != b_type)
        return a_type < b_type;

    var aStr: [5]u8 = undefined;
    var bStr: [5]u8 = undefined;

    for (0..5) |i| {
        aStr[i] = getCardValue(a.hand[i]);
        bStr[i] = getCardValue(b.hand[i]);
    }

    return std.mem.order(u8, &aStr, &bStr).compare(std.math.CompareOperator.lte);
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var hands = std.ArrayList(Hand).init(gpa);

    var arena = ArenaAllocator.init(gpa);
    var allocator = arena.allocator();
    arena.deinit();

    while (true) {
        var buffer = try allocator.alloc(u8, 1024);
        const opt_line = try getLine(buffer);
        if (opt_line) |line| {
            try hands.append(try parseHand(line));
        } else {
            break;
        }
    }

    std.mem.sort(Hand, hands.items, {}, handComparator);
    var res: u64 = 0;
    for (hands.items, 1..) |hand, rank| {
        std.debug.print("{} {}\n", .{ hand, rank });
        res += @as(u64, hand.bid) * rank;
    }
    try stdout.print("{}\n", .{res});
}
