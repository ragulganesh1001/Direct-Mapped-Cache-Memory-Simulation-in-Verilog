`timescale 1ns / 1ps
module tb_direct_mapped_cache;

    reg clk, rst;
    reg read_en, write_en;
    reg [7:0] address;
    reg [7:0] write_data;
    wire [7:0] read_data;
    wire hit;

    // DUT instance
    direct_mapped_cache uut (
        .clk(clk),
        .rst(rst),
        .read_en(read_en),
        .write_en(write_en),
        .address(address),
        .write_data(write_data),
        .read_data(read_data),
        .hit(hit)
    );

    // Clock
    always #5 clk = ~clk;

    initial begin
        $monitor("T=%0t | Addr=0x%0h | WData=0x%0h | RData=0x%0h | Hit=%b | Read=%b | Write=%b", 
                  $time, address, write_data, read_data, hit, read_en, write_en);

        clk = 0;
        rst = 1;
        read_en = 0;
        write_en = 0;
        address = 8'h00;
        write_data = 8'h00;

        // Reset
        #10 rst = 0;

        // ---- WRITE to address 0x10 (index=2)
        #10 address = 8'h10; write_data = 8'hA5;
        write_en = 1;
        #10 write_en = 0;

        // ---- READ (HIT) from 0x10
        #10 address = 8'h10;
        read_en = 1;
        #10 read_en = 0;

        // ---- READ (MISS) from 0x50 (same index=2 but different tag)
        #10 address = 8'h50;
        read_en = 1;
        #10 read_en = 0;

        #20 $finish;
    end
endmodule
