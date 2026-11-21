
`timescale 1ns / 1ps

module if_id_reg_tb;

    reg         clk;
    reg         rst;
    reg         flush;
    reg         stall;
    reg  [31:0] if_pc;
    reg  [31:0] if_instruction;
    wire [31:0] id_pc;
    wire [31:0] id_instruction;

    integer errors;
    localparam NOP = 32'h0000_0013;

    if_id_reg dut (
        .clk            (clk),
        .rst            (rst),
        .flush          (flush),
        .stall          (stall),
        .if_pc          (if_pc),
        .if_instruction (if_instruction),
        .id_pc          (id_pc),
        .id_instruction (id_instruction)
    );

    always #5 clk = ~clk;

    initial begin

        $dumpfile("if_id_reg.vcd");
        $dumpvars(0, if_id_reg_tb);

        clk            = 0;
        rst            = 1;
        flush          = 0;
        stall          = 0;
        if_pc          = 32'h0000_0000;
        if_instruction = NOP;
        errors         = 0;

        $display("------------------------------------------------------------");
        $display("Starting Testbench: IF/ID Pipeline Register (if_id_reg_tb)");
        $display("------------------------------------------------------------");


        #12;
        if (id_pc !== 32'h0000_0000 || id_instruction !== NOP) begin
            $display("[FAIL] Reset check failed! PC=0x%08h, Instr=0x%08h", id_pc, id_instruction);
            errors = errors + 1;
        end else begin
            $display("[PASS] Test 1: Reset initialized pipeline register to NOP");
        end

        @(negedge clk);
        rst = 0;

        if_pc          = 32'h0000_0010;
        if_instruction = 32'h00500093;
        @(posedge clk); #1;
        if (id_pc !== 32'h0000_0010 || id_instruction !== 32'h00500093) begin
            $display("[FAIL] Latching failed! Expected PC=0x10, Instr=0x00500093. Got PC=0x%08h, Instr=0x%08h", id_pc, id_instruction);
            errors = errors + 1;
        end else begin
            $display("[PASS] Test 2: Latching valid instruction 0x%08h at PC 0x%08h", id_instruction, id_pc);
        end

        if_pc          = 32'h0000_0014;
        if_instruction = 32'h00a00113; 
        flush          = 1;
        @(posedge clk); #1;
        flush          = 0;
        if (id_instruction !== NOP) begin
            $display("[FAIL] Flush failed! Expected NOP (0x00000013), got 0x%08h", id_instruction);
            errors = errors + 1;
        end else begin
            $display("[PASS] Test 3: Pipeline flush successfully inserted NOP bubble: 0x%08h", id_instruction);
        end

 
        if_pc          = 32'h0000_0020;
        if_instruction = 32'h002081b3;
        @(posedge clk); #1; 

        stall          = 1;
        if_pc          = 32'h0000_0024;
        if_instruction = 32'h0030a223;
        @(posedge clk); #1;
        if (id_pc !== 32'h0000_0020 || id_instruction !== 32'h002081b3) begin
            $display("[FAIL] Stall failed! Register changed during stall. PC=0x%08h, Instr=0x%08h", id_pc, id_instruction);
            errors = errors + 1;
        end else begin
            $display("[PASS] Test 4: Pipeline register held value correctly during stall: 0x%08h", id_instruction);
        end

        stall = 0;
        @(posedge clk); #1;
        if (id_pc !== 32'h0000_0024 || id_instruction !== 32'h0030a223) begin
            $display("[FAIL] Post-stall advance failed! Got PC=0x%08h, Instr=0x%08h", id_pc, id_instruction);
            errors = errors + 1;
        end else begin
            $display("[PASS] Pipeline resumed successfully after stall release: 0x%08h", id_instruction);
        end

        $display("------------------------------------------------------------");
        if (errors == 0) begin
            $display("if_id_reg_tb RESULT: ALL TESTS PASSED!");
        end else begin
            $display("if_id_reg_tb RESULT: %0d TESTS FAILED!", errors);
        end
        $display("------------------------------------------------------------");

        #10;
        $finish;
    end

endmodule
