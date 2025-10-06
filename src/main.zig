const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    // Check if help is requested or no arguments
    if (args.len < 2) {
        try printHelp();
        return;
    }

    if (std.mem.eql(u8, args[1], "--help") or std.mem.eql(u8, args[1], "-h")) {
        try printHelp();
        return;
    }

    const flag = args[1];

    // Check for valid flags
    if (std.mem.eql(u8, flag, "-f")) {
        if (args.len < 3) {
            std.debug.print("Error: -f flag requires at least one number argument\n", .{});
            std.debug.print("Usage: zli-factor -f <numbers...>\n", .{});
            std.process.exit(1);
        }

        var numbers: std.ArrayList(u32) = .empty;
        defer numbers.deinit(allocator);

        // Parse all number arguments (can be single, comma-separated, or ranges)
        var i: usize = 2;
        while (i < args.len) : (i += 1) {
            try parseNumberArg(allocator, args[i], &numbers);
        }

        // Process each number
        for (numbers.items, 0..) |num, idx| {
            if (idx > 0) std.debug.print("\n", .{});
            try findFactors(allocator, num);
        }
    } else if (std.mem.eql(u8, flag, "-p")) {
        if (args.len < 3) {
            std.debug.print("Error: -p flag requires a number argument\n", .{});
            std.debug.print("Usage: zli-factor -p <number>\n", .{});
            std.process.exit(1);
        }

        const limit = std.fmt.parseInt(u32, args[2], 10) catch {
            std.debug.print("Error: '{s}' is not a valid integer\n", .{args[2]});
            std.process.exit(1);
        };

        if (limit > 999999999) {
            std.debug.print("Error: number too large (max: 999,999,999)\n", .{});
            std.process.exit(1);
        }

        if (limit > 10000000) {
            std.debug.print("⚠️  Warning: Finding primes up to {d} may take some time and memory...\n", .{limit});
        }

        try listPrimes(allocator, limit);
    } else if (std.mem.eql(u8, flag, "-pf")) {
        if (args.len < 3) {
            std.debug.print("Error: -pf flag requires at least one number argument\n", .{});
            std.debug.print("Usage: zli-factor -pf <numbers...>\n", .{});
            std.process.exit(1);
        }

        var numbers: std.ArrayList(u32) = .empty;
        defer numbers.deinit(allocator);

        var i: usize = 2;
        while (i < args.len) : (i += 1) {
            try parseNumberArg(allocator, args[i], &numbers);
        }

        for (numbers.items, 0..) |num, idx| {
            if (idx > 0) std.debug.print("\n", .{});
            try primeFactorize(allocator, num);
        }
    } else {
        std.debug.print("Error: Unknown flag '{s}'\n", .{flag});
        std.debug.print("Run 'zli-factor -h' for usage information\n", .{});
        std.process.exit(1);
    }
}

fn parseNumberArg(allocator: std.mem.Allocator, arg: []const u8, numbers: *std.ArrayList(u32)) !void {
    // Check if it's a range (e.g., "1-22")
    if (std.mem.indexOf(u8, arg, "-")) |dash_pos| {
        if (dash_pos > 0 and dash_pos < arg.len - 1) {
            const start_str = arg[0..dash_pos];
            const end_str = arg[dash_pos + 1 ..];

            const start = std.fmt.parseInt(u32, start_str, 10) catch {
                std.debug.print("Error: '{s}' is not a valid range\n", .{arg});
                std.process.exit(1);
            };

            const end = std.fmt.parseInt(u32, end_str, 10) catch {
                std.debug.print("Error: '{s}' is not a valid range\n", .{arg});
                std.process.exit(1);
            };

            if (start > end) {
                std.debug.print("Error: Invalid range {d}-{d} (start > end)\n", .{ start, end });
                std.process.exit(1);
            }

            if (end > 999999999) {
                std.debug.print("Error: number too large in range (max: 999,999,999)\n", .{});
                std.process.exit(1);
            }

            if (end - start > 100000) {
                std.debug.print("⚠️  Warning: Processing {d} numbers may take some time...\n", .{end - start + 1});
            }

            var i: u32 = start;
            while (i <= end) : (i += 1) {
                try numbers.*.append(allocator, i);
            }
            return;
        }
    }

    // Check if it's comma-separated (e.g., "33,100,222")
    var iter = std.mem.splitScalar(u8, arg, ',');
    while (iter.next()) |num_str| {
        const trimmed = std.mem.trim(u8, num_str, " \t");
        if (trimmed.len == 0) continue;

        const num = std.fmt.parseInt(u32, trimmed, 10) catch {
            std.debug.print("Error: '{s}' is not a valid integer\n", .{trimmed});
            std.process.exit(1);
        };

        if (num > 999999999) {
            std.debug.print("Error: number {d} too large (max: 999,999,999)\n", .{num});
            std.process.exit(1);
        }

        try numbers.*.append(allocator, num);
    }
}

fn findFactors(allocator: std.mem.Allocator, num: u32) !void {
    if (num == 0 or num == 1) {
        std.debug.print("Number {d} has no factors (excluding 1 and itself)\n", .{num});
        return;
    }

    // Find all factors (excluding 1 and the number itself)
    var factors: std.ArrayList(u32) = .empty;
    defer factors.deinit(allocator);

    var i: u32 = 2;
    while (i * i <= num) : (i += 1) {
        if (num % i == 0) {
            try factors.append(allocator, i);
            const other = num / i;
            if (other != i and other != num) {
                try factors.append(allocator, other);
            }
        }
    }

    // Sort factors
    std.mem.sort(u32, factors.items, {}, comptime std.sort.asc(u32));

    // Check if prime
    if (factors.items.len == 0) {
        std.debug.print("✨ {d} is PRIME! ✨\n", .{num});
        std.debug.print("A prime number is only divisible by 1 and itself - how special!\n", .{});
        return;
    }

    // Calculate sum of factors for perfect number check
    var sum: u32 = 1; // Start with 1
    for (factors.items) |factor| {
        sum += factor;
    }

    const is_perfect = (sum == num);

    // Print factors
    std.debug.print("Factors of {d} (excluding 1 and {d}):\n", .{ num, num });
    for (factors.items) |factor| {
        std.debug.print("  {d}\n", .{factor});
    }

    if (is_perfect) {
        std.debug.print("💎 PERFECT NUMBER! Sum of all factors (including 1) = {d} 💎\n", .{num});
    }
}

fn primeFactorize(allocator: std.mem.Allocator, num: u32) !void {
    if (num == 0 or num == 1) {
        std.debug.print("{d} has no prime factorization\n", .{num});
        return;
    }

    var n = num;
    var factors: std.ArrayList(u32) = .empty;
    defer factors.deinit(allocator);

    // Check for 2s
    while (n % 2 == 0) {
        try factors.append(allocator, 2);
        n /= 2;
    }

    // Check for odd factors
    var i: u32 = 3;
    while (i * i <= n) : (i += 2) {
        while (n % i == 0) {
            try factors.append(allocator, i);
            n /= i;
        }
    }

    // If n is still > 1, then it's a prime factor
    if (n > 1) {
        try factors.append(allocator, n);
    }

    // Count occurrences of each prime
    std.debug.print("Prime factorization of {d}:\n", .{num});

    if (factors.items.len == 1) {
        std.debug.print("  {d} is prime!\n", .{num});
        return;
    }

    std.debug.print("  {d} = ", .{num});

    var i_outer: usize = 0;
    while (i_outer < factors.items.len) {
        const prime = factors.items[i_outer];
        var count: u32 = 1;

        while (i_outer + count < factors.items.len and factors.items[i_outer + count] == prime) {
            count += 1;
        }

        if (i_outer > 0) std.debug.print(" * ", .{});

        if (count == 1) {
            std.debug.print("{d}", .{prime});
        } else {
            std.debug.print("{d}^{d}", .{ prime, count });
        }

        i_outer += count;
    }
    std.debug.print("\n", .{});
}

fn isPrime(n: u32) bool {
    if (n < 2) return false;
    if (n == 2) return true;
    if (n % 2 == 0) return false;

    var i: u32 = 3;
    while (i * i <= n) : (i += 2) {
        if (n % i == 0) return false;
    }
    return true;
}

fn listPrimes(allocator: std.mem.Allocator, limit: u32) !void {
    var primes: std.ArrayList(u32) = .empty;
    defer primes.deinit(allocator);

    var n: u32 = 2;
    while (n <= limit) : (n += 1) {
        if (isPrime(n)) {
            try primes.append(allocator, n);
        }
    }

    if (primes.items.len == 0) {
        std.debug.print("No prime numbers found between 1 and {d}\n", .{limit});
        return;
    }

    std.debug.print("✨ Found {d} prime number(s) between 1 and {d}:\n", .{ primes.items.len, limit });
    std.debug.print("\n", .{});

    var count: usize = 0;
    for (primes.items) |prime| {
        std.debug.print("{d:>6}  ", .{prime});
        count += 1;
        if (count % 10 == 0) {
            std.debug.print("\n", .{});
        }
    }
    if (count % 10 != 0) {
        std.debug.print("\n", .{});
    }
}

fn printHelp() !void {
    std.debug.print(
        \\zli-factor - A powerful integer factorization & prime number tool
        \\
        \\USAGE:
        \\  zli-factor -f <numbers...>     Find factors
        \\  zli-factor -p <number>         List primes up to number
        \\  zli-factor -pf <numbers...>    Prime factorization
        \\  zli-factor -h                  Show this help
        \\
        \\DESCRIPTION:
        \\  A versatile number analysis tool supporting:
        \\  • Factor finding with perfect number detection
        \\  • Prime number listing and detection
        \\  • Prime factorization
        \\  • Multiple number inputs and ranges
        \\  • Supports numbers up to 9 digits (999,999,999)
        \\
        \\FLAGS:
        \\  -f   Find all factors (excluding 1 and the number itself)
        \\       Detects prime and perfect numbers automatically
        \\
        \\  -p   List all prime numbers from 1 to the given number
        \\
        \\  -pf  Show prime factorization (e.g., 100 = 2^2 * 5^2)
        \\
        \\  -h, --help   Show this help message
        \\
        \\INPUT FORMATS:
        \\  Single:         -f 100
        \\  Multiple:       -f 33 100 222
        \\  Comma-sep:      -f 33,100,222
        \\  Range:          -f 1-22
        \\  Mixed:          -f 10 20-25 100
        \\
        \\EXAMPLES:
        \\  zli-factor -f 6         # Perfect number detection!
        \\  zli-factor -f 17        # Prime detection!
        \\  zli-factor -f 100       # Factors: 2, 4, 5, 10, 20, 25, 50
        \\  zli-factor -f 1-10      # Factor all numbers 1 through 10
        \\  zli-factor -f 28,496    # Multiple perfect numbers
        \\  zli-factor -p 700       # List 125 primes up to 700
        \\  zli-factor -pf 100      # Shows: 100 = 2^2 * 5^2
        \\  zli-factor -pf 1-20     # Prime factorization for range
        \\
        \\FUN FACTS:
        \\  • Perfect numbers: Sum of factors equals the number (6, 28, 496...)
        \\  • Twin primes: Primes that differ by 2 (3&5, 11&13, 17&19...)
        \\  • There are 25 primes up to 100, and 168 primes up to 1000!
        \\
    , .{});
}
