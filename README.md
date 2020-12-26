# jemalloc-zig
![CI](https://github.com/protheory8/jemalloc-zig/workflows/CI/badge.svg)  
Implementation of `std.mem.Allocator` interface that wraps Jemalloc.
Works on master builds of Zig.

# Example usage

Use this library as a Zig library ([instructions here](https://github.com/ziglang/zig/wiki/Zig-Build-System#use-a-zig-library)) and then add something like this to your root source file:
```zig
const jemalloc_zig = @import("jemalloc-zig");
const gpa = jemalloc_zig.jemalloc_allocator;

pub fn main() !void {
    const memory = try gpa.alloc(i32, 1);
    memory[0] = 12;
    gpa.free(memory);
}
```
