# zli-factor 🔢

A powerful and versatile command-line integer factorization and prime number analysis tool written in Zig.

## Features ✨

- **Factor Finding**: Discover all factors of any number (excluding 1 and itself)
- **Prime Detection**: Automatically identifies prime numbers
- **Perfect Number Detection**: Recognizes perfect numbers (where sum of factors equals the number)
- **Prime Listing**: List all prime numbers up to a given limit
- **Prime Factorization**: Break down numbers into their prime factors with exponents
- **Batch Processing**: Process multiple numbers or ranges in one command
- **High Performance**: Written in Zig for maximum speed and efficiency
- **Large Number Support**: Handles integers up to 9 digits (999,999,999)

## Installation 🚀

### Prerequisites
- [Zig](https://ziglang.org/) v0.15.1 or later

### Build from Source
```bash
git clone https://github.com/yourusername/zli-factor.git
cd zli-factor
zig build
```

The executable will be located at `zig-out/bin/zig_factoring` (or `zig_factoring.exe` on Windows).

### Install to System
```bash
zig build install --prefix ~/.local
```

## Usage 📖

### Basic Commands

```bash
# Find factors of a number
zli-factor -f 100

# List all primes up to a number
zli-factor -p 700

# Show prime factorization
zli-factor -pf 100

# Show help
zli-factor -h
```

### Flags

| Flag | Description | Example |
|------|-------------|---------|
| `-f` | Find all factors (excluding 1 and the number) | `zli-factor -f 28` |
| `-p` | List all prime numbers from 1 to N | `zli-factor -p 100` |
| `-pf` | Show prime factorization | `zli-factor -pf 360` |
| `-h`, `--help` | Display help message | `zli-factor -h` |

### Input Formats

#### Single Number
```bash
zli-factor -f 100
```

#### Multiple Numbers (Space-separated)
```bash
zli-factor -f 15 25 35
```

#### Multiple Numbers (Comma-separated)
```bash
zli-factor -f 33,100,222
```

#### Range
```bash
zli-factor -f 1-10        # Factors all numbers from 1 to 10
zli-factor -pf 10-20      # Prime factorization for 10 through 20
```

#### Mixed Format
```bash
zli-factor -f 10 20-25 100 200,300
```

## Examples 💡

### Factor Finding
```bash
$ zli-factor -f 100
Factors of 100 (excluding 1 and 100):
  2
  4
  5
  10
  20
  25
  50
```

### Prime Detection
```bash
$ zli-factor -f 17
✨ 17 is PRIME! ✨
A prime number is only divisible by 1 and itself - how special!
```

### Perfect Number Detection
```bash
$ zli-factor -f 28
Factors of 28 (excluding 1 and 28):
  2
  4
  7
  14
💎 PERFECT NUMBER! Sum of all factors (including 1) = 28 💎
```

### Prime Listing
```bash
$ zli-factor -p 50
✨ Found 15 prime number(s) between 1 and 50:

     2       3       5       7      11      13      17      19      23      29  
    31      37      41      43      47  
```

### Prime Factorization
```bash
$ zli-factor -pf 360
Prime factorization of 360:
  360 = 2^3 * 3^2 * 5

$ zli-factor -pf 17
Prime factorization of 17:
  17 is prime!
```

### Batch Processing
```bash
$ zli-factor -f 6,28,496
Factors of 6 (excluding 1 and 6):
  2
  3
💎 PERFECT NUMBER! Sum of all factors (including 1) = 6 💎

Factors of 28 (excluding 1 and 28):
  2
  4
  7
  14
💎 PERFECT NUMBER! Sum of all factors (including 1) = 28 💎

Factors of 496 (excluding 1 and 496):
  2
  4
  8
  16
  31
  62
  124
  248
💎 PERFECT NUMBER! Sum of all factors (including 1) = 496 💎
```

### Range Processing
```bash
$ zli-factor -f 1-6
Number 1 has no factors (excluding 1 and itself)

✨ 2 is PRIME! ✨
A prime number is only divisible by 1 and itself - how special!

✨ 3 is PRIME! ✨
A prime number is only divisible by 1 and itself - how special!

Factors of 4 (excluding 1 and 4):
  2

✨ 5 is PRIME! ✨
A prime number is only divisible by 1 and itself - how special!

Factors of 6 (excluding 1 and 6):
  2
  3
💎 PERFECT NUMBER! Sum of all factors (including 1) = 6 💎
```

## Performance & Limits ⚡

### Maximum Values
- **Integer Limit**: Up to 9 digits (999,999,999)
- **Data Type**: 32-bit unsigned integer (u32)
- **Theoretical Maximum**: 4,294,967,295 (limited to 999,999,999 for practical use)

### Memory Considerations

The tool uses dynamic memory allocation and should handle most operations efficiently. However, be aware:

1. **Large Prime Listings** (e.g., `-p 100000000`):
   - Will store all primes in memory
   - May take significant time and memory
   - Warning displayed for limits > 10,000,000

2. **Large Ranges** (e.g., `-f 1-1000000`):
   - Processes each number sequentially
   - Warning displayed for ranges > 100,000 numbers
   - Output may be very long

3. **Single Large Numbers**:
   - Factor finding for large numbers is fast
   - Prime factorization is efficient even for 9-digit numbers
   - No memory concerns for individual number operations

### Memory Error Prevention

**Will NOT cause memory errors:**
- Single numbers, even very large: `zli-factor -f 999999999` ✅
- Small ranges: `zli-factor -f 1-1000` ✅
- Multiple discrete numbers: `zli-factor -f 100,200,300,...` ✅
- Prime factorization of any valid number ✅

**Use with caution (will warn you):**
- Very large ranges: `zli-factor -f 1-500000` ⚠️
- Large prime listings: `zli-factor -p 50000000` ⚠️

**Not recommended:**
- Extreme ranges: `zli-factor -f 1-100000000` ❌ (will take very long)
- Maximum prime listing: `zli-factor -p 999999999` ❌ (will exhaust memory)

### Performance Tips

- For analyzing many numbers, use comma-separated or space-separated format
- Use ranges wisely - they process every number in the range
- Prime factorization is faster than factor finding for large numbers
- Prime listing scales with the size of the limit (roughly O(n log log n))

## Fun Number Facts 🎓

### Perfect Numbers
Perfect numbers are positive integers equal to the sum of their proper divisors (excluding the number itself):
- **6** = 1 + 2 + 3
- **28** = 1 + 2 + 4 + 7 + 14
- **496** = 1 + 2 + 4 + 8 + 16 + 31 + 62 + 124 + 248
- **8128** = (try it yourself!)

### Prime Numbers
- There are **25** prime numbers up to 100
- There are **168** prime numbers up to 1,000
- There are **78,498** prime numbers up to 1,000,000

### Twin Primes
Pairs of primes that differ by 2:
- (3, 5), (5, 7), (11, 13), (17, 19), (29, 31), (41, 43)...

## Technical Details 🔧

### Algorithm Complexity

- **Factor Finding**: O(√n) - checks divisors up to square root
- **Prime Testing**: O(√n) - optimized to check only odd numbers
- **Prime Listing**: O(n√n) - checks each number for primality
- **Prime Factorization**: O(√n) - trial division with optimization

### Built With
- **Language**: Zig v0.15.1
- **Memory Management**: General Purpose Allocator with automatic cleanup
- **Data Structures**: ArrayList for dynamic storage

## Development 🛠️

### Running Tests
```bash
zig build test
```

### Running in Debug Mode
```bash
zig build run -- -f 100
```

### Building for Release
```bash
zig build -Doptimize=ReleaseFast
```

## Contributing 🤝

Contributions are welcome! Feel free to:
- Report bugs
- Suggest new features
- Submit pull requests
- Improve documentation

## License 📄

This project is open source and available under the MIT License.

## Acknowledgments 🙏

- Built with the amazing [Zig](https://ziglang.org/) programming language
- Inspired by classic number theory and computational mathematics

## Author ✍️

Created with ❤️ by a Zig enthusiast

---

**Happy Number Crunching!** 🎉

