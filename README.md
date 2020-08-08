# jemalloc-zig
![CI](https://github.com/protheory8/jemalloc-zig/workflows/CI/badge.svg)  
Implementation of `std.mem.Allocator` that wraps Jemalloc.
Currently this doesn't work on Zig 0.6.0 and only works on master builds.

# Example usage

If you're using this library as a package ([link](https://github.com/ziglang/zig/wiki/Zig-Build-System#use-a-zig-library)):
```zig
const jemalloc_zig = @import("jemalloc-zig/src/main.zig");
const gpa = jemalloc_zig.jemalloc_allocator;

pub fn main() !void {
    const memory = try gpa.alloc(i32, 1);
    gpa.free(memory);
}
```
