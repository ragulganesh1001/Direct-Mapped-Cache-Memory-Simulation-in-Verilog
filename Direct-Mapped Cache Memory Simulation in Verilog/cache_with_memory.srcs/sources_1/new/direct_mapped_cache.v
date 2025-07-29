module direct_mapped_cache (
    input clk,
    input rst,
    input read_en,
    input write_en,
    input [7:0] address,
    input [7:0] write_data,
    output reg [7:0] read_data,
    output reg hit
);

    // Cache: 4 lines
    reg [7:0] cache_data [0:3];
    reg [5:0] cache_tag [0:3];
    reg cache_valid [0:3];

    // Backing Memory: 256 locations
    reg [7:0] main_memory [0:255];

    wire [1:0] index = address[3:2];      // 2-bit index
    wire [5:0] tag = address[7:2];        // 6-bit tag
    
    integer i;

    // Split address for cache and memory access
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 4; i = i + 1) begin
                cache_valid[i] <= 0;
                cache_data[i] <= 0;
                cache_tag[i] <= 0;
            end

            for (i = 0; i < 256; i = i + 1)
                main_memory[i] <= i; // preload memory with dummy data (0,1,2,...)
            
            hit <= 0;
            read_data <= 0;
        end else begin
            hit <= 0;
            read_data <= 8'h00;

            if (read_en) begin
                if (cache_valid[index] && cache_tag[index] == tag) begin
                    // Cache hit
                    hit <= 1;
                    read_data <= cache_data[index];
                end else begin
                    // Cache miss → fetch from main memory and update cache
                    hit <= 0;
                    cache_data[index] <= main_memory[address];
                    cache_tag[index] <= tag;
                    cache_valid[index] <= 1;
                    read_data <= main_memory[address];
                end
            end

            if (write_en) begin
                // Write-through policy: write to both cache (if valid & tag match) and memory
                main_memory[address] <= write_data;
                if (cache_valid[index] && cache_tag[index] == tag) begin
                    cache_data[index] <= write_data;
                end else begin
                    // Optionally: update cache on write miss too
                    cache_data[index] <= write_data;
                    cache_tag[index] <= tag;
                    cache_valid[index] <= 1;
                end
            end
        end
    end
endmodule
