
`timescale 1ns / 1ps

module register_file_tb;

    reg         clk;
    reg         rst;
    reg         reg_write;
    reg  [4:0]  rs1_addr;
    reg  [4:0]  rs2_addr;
    reg  [4:0]  rd_addr;
    reg  [31:0] rd_data;
    wire [31:0] rs1_data;
    wire [31:0] rs2_data;

    integer errors;

    register_file dut (
        .clk       (clk),
        .rst       (rst),
        .reg_write (reg_write),
        .rs1_addr  (rs1_addr),
        .rs2_addr  (rs2_addr),
        .rd_addr   (rd_addr),
        .rd_data   (rd_data),
        .rs1_data  (rs1_data),
        .rs2_data  (rs2_data)
    );

    always #5 clk = ~clk;

    initial begin
   
        $dumpfile("register_file.vcd");
        $dumpvars(0, register_file_tb);

        clk       = 0;
        rst       = 1;
        reg_write = 0;
        rs1_addr  = 5'd0;
        rs2_addr  = 5'd0;
        rd_addr   = 5'd0;
        rd_data   = 32'h0000_0000;
        errors    = 0;

        $display("------------------------------------------------------------");
        $display("Starting Testbench: Register File (register_file_tb)");
        $display("------------------------------------------------------------");

        #12;
        @(negedge clk);
        rst = 0;
        rs1_addr = 5'd1;
        rs2_addr = 5'd2;
        #2;
        if (rs1_data !== 32'd0 || rs2_data !== 32'd0) begin
            $display("[FAIL] Test 1: Reset failed, registers not zero!");
            errors = errors + 1;
        end else begin
            $display("[PASS] Test 1: Reset verified, registers cleared to 0");
        end

        @(negedge clk);
        reg_write = 1;
        rd_addr   = 5'd1;
        rd_data   = 32'h1234_5678;
        @(posedge clk); #1; 
        reg_write = 0;

        @(negedge clk);
        reg_write = 1;
        rd_addr   = 5'd2;
        rd_data   = 32'h8765_4321;
        @(posedge clk); #1;
        reg_write = 0;

        rs1_addr = 5'd1;
        rs2_addr = 5'd2;
        #2;
        if (rs1_data !== 32'h1234_5678 || rs2_data !== 32'h8765_4321) begin
            $display("[FAIL] Test 2: Readback failed! rs1=0x%08h, rs2=0x%08h", rs1_data, rs2_data);
            errors = errors + 1;
        end else begin
            $display("[PASS] Test 2: Standard write and readback verified for x1 and x2");
        end

        @(negedge clk);
        reg_write = 1;
        rd_addr   = 5'd0;
        rd_data   = 32'hFFFF_FFFF;
        @(posedge clk); #1;
        reg_write = 0;

        rs1_addr = 5'd0;
        #2;
        if (rs1_data !== 32'h0000_0000) begin
            $display("[FAIL] Test 3: x0 is not hardwired to zero! Got 0x%08h", rs1_data);
            errors = errors + 1;
        end else begin
            $display("[PASS] Test 3: x0 successfully remained 0 after write attempt");
        end

        @(negedge clk);
        reg_write = 0;
        rd_addr   = 5'd3;
        rd_data   = 32'hDEAD_BEEF;
        @(posedge clk); #1;

        rs1_addr = 5'd3;
        #2;
        if (rs1_data !== 32'h0000_0000) begin
            $display("[FAIL] Test 4: Register modified when reg_write=0! Got 0x%08h", rs1_data);
            errors = errors + 1;
        end else begin
            $display("[PASS] Test 4: reg_write=0 prevented unauthorized write to x3");
        end

        @(negedge clk);
        reg_write = 1;
        rd_addr   = 5'd5;
        rd_data   = 32'hCAFE_BABE;
        rs1_addr  = 5'd5; 
        #2; 
        if (rs1_data !== 32'hCAFE_BABE) begin
            $display("[FAIL] Test 5: Same-cycle bypass failed! Expected 0xCAFEBABE, got 0x%08h", rs1_data);
            errors = errors + 1;
        end else begin
            $display("[PASS] Test 5: Same-cycle write-through forwarding verified");
        end
        @(posedge clk); #1;
        reg_write = 0;

        $display("------------------------------------------------------------");
        if (errors == 0) begin
            $display("register_file_tb RESULT: ALL TESTS PASSED!");
        end else begin
            $display("register_file_tb RESULT: %0d TESTS FAILED!", errors);
        end
        $display("------------------------------------------------------------");

        #10;
        $finish;
    end

endmodule
