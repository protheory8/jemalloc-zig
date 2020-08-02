const testing = @import("std").testing;
const jemalloc_allocator = @import("main.zig").jemalloc_allocator;

test "allocate memory and free" {
    const TestStruct = struct {
        title: []const u8,
        width: i32,
        height: i32,
        index: usize,
    };
    
    const memory: []TestStruct = jemalloc_allocator.alloc(TestStruct, 1) catch @panic("test failure");
    jemalloc_allocator.free(memory);
}

test "allocate memory, use it and free" {
    const TestStruct = struct {
        width: i32,
        height: i32,
        title: []const u8,
        index: usize,
    };
    
    const memory: []TestStruct = jemalloc_allocator.alloc(TestStruct, 1) catch @panic("test failure");

    memory[0] = TestStruct{
        .width = 1280,
        .height = 720,
        .title = "Should work fine!",
        .index = 12,
    };

    testing.expect(memory[0].width == 1280);
    testing.expect(memory[0].height == 720);
    testing.expect(memory[0].index == 12);

    jemalloc_allocator.free(memory);
}

test "allocate memory, use it, reallocate memory, use it and free" {
    const TestStruct = struct {
        width: i32,
        height: i32,
        title: []const u8,
        index: usize,
    };

    var memory: []TestStruct = jemalloc_allocator.alloc(TestStruct, 2) catch @panic("test failure");

    memory[0] = TestStruct{
        .width = 1280,
        .height = 720,
        .title = "Should work fine!",
        .index = 12,
    };

    memory[1] = TestStruct{
        .width = 1230,
        .height = 820,
        .title = "Cool game",
        .index = 120,
    };

    memory = jemalloc_allocator.realloc(memory, 4) catch @panic("test failure");

    memory[2] = TestStruct{
        .width = 12612,
        .height = 45,
        .title = "Window title",
        .index = 31,
    };

    memory[3] = TestStruct{
        .width = 125,
        .height = 1,
        .title = "Game title",
        .index = 21,
    };

    testing.expect(memory[0].width == 1280);
    testing.expect(memory[0].height == 720);
    testing.expect(memory[0].index == 12);

    testing.expect(memory[1].width == 1230);
    testing.expect(memory[1].height == 820);
    testing.expect(memory[1].index == 120);

    testing.expect(memory[2].width == 12612);
    testing.expect(memory[2].height == 45);
    testing.expect(memory[2].index == 31);

    testing.expect(memory[3].width == 125);
    testing.expect(memory[3].height == 1);
    testing.expect(memory[3].index == 21);

    jemalloc_allocator.free(memory);
}
