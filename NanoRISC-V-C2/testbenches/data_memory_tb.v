
`timescale 1ns / 1ps

module data_memory_tb;

    reg         clk;
    reg         rst;
    reg         mem_read;
    reg         mem_write;
    reg  [2:0]  funct3;
    reg  [31:0] addr;
    reg  [31:0] write_data;
    wire [31:0] read_data;

    integer errors;

    data_memory #(.MEM_DEPTH(256)) dut (
        .clk        (clk),
        .rst        (rst),
        .mem_read   (mem_read),
        .mem_write  (mem_write),
        .funct3     (funct3),
        .addr       (addr),
        .write_data (write_data),
        .read_data  (read_data)
    );

    always #5 clk = ~clk;

    initial begin

        $dumpfile("data_memory.vcd");
        $dumpvars(0, data_memory_tb);

        clk        = 0;
        rst        = 1;
        mem_read   = 0;
        mem_write  = 0;
        funct3     = 3'b000;
        addr       = 32'd0;
        write_data = 32'd0;
        errors     = 0;

        $display("------------------------------------------------------------");
        $display("Starting Testbench: Data Memory (data_memory_tb)");
        $display("------------------------------------------------------------");

        #12;
        @(negedge clk);
        rst = 0;
        mem_read = 1;
        funct3   = 3'b010; 
        addr     = 32'd0;
        #2;
        if (read_data !== 32'h0000_0000) begin
            $display("[FAIL] Test 1: Reset failed, expected 0x0, got 0x%08h", read_data);
            errors = errors + 1;
        end else begin
            $display("[PASS] Test 1: Memory reset initialized to 0x0");
        end
        mem_read = 0;

        @(negedge clk);
        mem_write  = 1;
        funct3     = 3'b010; 
        addr       = 32'd16;
        write_data = 32'h1234_5678;
        @(posedge clk); #1;
        mem_write  = 0;

        mem_read   = 1;
        funct3     = 3'b010; 
        addr       = 32'd16;
        #2;
        if (read_data !== 32'h1234_5678) begin
            $display("[FAIL] Test 2: SW/LW failed! Expected 0x12345678, got 0x%08h", read_data);
            errors = errors + 1;
        end else begin
            $display("[PASS] Test 2: SW/LW successful at addr 16: 0x%08h", read_data);
        end
        mem_read = 0;

        @(negedge clk);
        mem_write  = 1;
        funct3     = 3'b001;
        addr       = 32'd32;
        write_data = 32'h0000_8ABC;
        @(posedge clk); #1;
        mem_write  = 0;

        mem_read   = 1;
        funct3     = 3'b001; 
        addr       = 32'd32;
        #2;
        if (read_data !== 32'hFFFF_8ABC) begin
            $display("[FAIL] Test 3a: LH sign-extension failed! Expected 0xFFFF8ABC, got 0x%08h", read_data);
            errors = errors + 1;
        end else begin
            $display("[PASS] Test 3a: LH sign-extension correct: 0x%08h", read_data);
        end

        funct3     = 3'b101;
        #2;
        if (read_data !== 32'h0000_8ABC) begin
            $display("[FAIL] Test 3b: LHU zero-extension failed! Expected 0x00008ABC, got 0x%08h", read_data);
            errors = errors + 1;
        end else begin
            $display("[PASS] Test 3b: LHU zero-extension correct: 0x%08h", read_data);
        end
        mem_read = 0;

        @(negedge clk);
        mem_write  = 1;
        funct3     = 3'b000; 
        addr       = 32'd64;
        write_data = 32'h0000_00FE;
        @(posedge clk); #1;
        mem_write  = 0;

        mem_read   = 1;
        funct3     = 3'b000;
        addr       = 32'd64;
        #2;
        if (read_data !== 32'hFFFF_FFFE) begin
            $display("[FAIL] Test 4a: LB sign-extension failed! Expected 0xFFFFFFFE, got 0x%08h", read_data);
            errors = errors + 1;
        end else begin
            $display("[PASS] Test 4a: LB sign-extension correct: 0x%08h", read_data);
        end

        funct3     = 3'b100;
        #2;
        if (read_data !== 32'h0000_00FE) begin
            $display("[FAIL] Test 4b: LBU zero-extension failed! Expected 0x000000FE, got 0x%08h", read_data);
            errors = errors + 1;
        end else begin
            $display("[PASS] Test 4b: LBU zero-extension correct: 0x%08h", read_data);
        end
        mem_read = 0;

        $display("------------------------------------------------------------");
        if (errors == 0) begin
            $display("data_memory_tb RESULT: ALL TESTS PASSED!");
        end else begin
            $display("data_memory_tb RESULT: %0d TESTS FAILED!", errors);
        end
        $display("------------------------------------------------------------");

        #10;
        $finish;
    end

endmodule
