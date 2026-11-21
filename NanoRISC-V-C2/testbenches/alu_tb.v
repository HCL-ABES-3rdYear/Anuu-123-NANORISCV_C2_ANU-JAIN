
`timescale 1ns / 1ps

module alu_tb;

    reg  [31:0] alu_in_a;
    reg  [31:0] alu_in_b;
    reg  [3:0]  alu_ctrl;
    wire [31:0] alu_result;
    wire        zero;

    integer errors;

    localparam ALU_ADD   = 4'b0000;
    localparam ALU_SUB   = 4'b0001;
    localparam ALU_SLL   = 4'b0010;
    localparam ALU_SLT   = 4'b0011;
    localparam ALU_SLTU  = 4'b0100;
    localparam ALU_XOR   = 4'b0101;
    localparam ALU_SRL   = 4'b0110;
    localparam ALU_SRA   = 4'b0111;
    localparam ALU_OR    = 4'b1000;
    localparam ALU_AND   = 4'b1001;
    localparam ALU_PASSB = 4'b1010;

    alu dut (
        .alu_in_a   (alu_in_a),
        .alu_in_b   (alu_in_b),
        .alu_ctrl   (alu_ctrl),
        .alu_result (alu_result),
        .zero       (zero)
    );

    initial begin
        $dumpfile("alu.vcd");
        $dumpvars(0, alu_tb);

        errors   = 0;
        alu_in_a = 32'd0;
        alu_in_b = 32'd0;
        alu_ctrl = 4'd0;

        $display("------------------------------------------------------------");
        $display("Starting Testbench: Arithmetic Logic Unit (alu_tb)");
        $display("------------------------------------------------------------");

        alu_in_a = 32'd15; alu_in_b = 32'd27; alu_ctrl = ALU_ADD; #5;
        if (alu_result !== 32'd42 || zero !== 1'b0) begin
            $display("[FAIL] ADD failed! Expected 42, got %0d", alu_result);
            errors = errors + 1;
        end else begin
            $display("[PASS] ADD (15 + 27 = %0d), zero=%b", alu_result, zero);
        end

        alu_in_a = 32'd50; alu_in_b = 32'd50; alu_ctrl = ALU_SUB; #5;
        if (alu_result !== 32'd0 || zero !== 1'b1) begin
            $display("[FAIL] SUB/Zero flag failed! Expected 0 and zero=1. Got %0d, zero=%b", alu_result, zero);
            errors = errors + 1;
        end else begin
            $display("[PASS] SUB (50 - 50 = %0d), zero=%b", alu_result, zero);
        end

        alu_in_a = 32'd1; alu_in_b = 32'd4; alu_ctrl = ALU_SLL; #5;
        if (alu_result !== 32'd16) begin
            $display("[FAIL] SLL failed! Expected 16, got %0d", alu_result);
            errors = errors + 1;
        end else begin
            $display("[PASS] SLL (1 << 4 = %0d)", alu_result);
        end

        alu_in_a = -32'd10; alu_in_b = 32'd5; alu_ctrl = ALU_SLT; #5;
        if (alu_result !== 32'd1) begin
            $display("[FAIL] SLT failed! Expected 1, got %0d", alu_result);
            errors = errors + 1;
        end else begin
            $display("[PASS] SLT (-10 < 5 = %0d)", alu_result);
        end

        alu_in_a = 32'hFFFF_FFFF; alu_in_b = 32'd1; alu_ctrl = ALU_SLTU; #5;
        if (alu_result !== 32'd0) begin
            $display("[FAIL] SLTU failed! Expected 0, got %0d", alu_result);
            errors = errors + 1;
        end else begin
            $display("[PASS] SLTU (0xFFFFFFFF < 1 = %0d)", alu_result);
        end

        alu_in_a = 32'hF0F0_F0F0; alu_in_b = 32'hFF00_FF00; alu_ctrl = ALU_XOR; #5;
        if (alu_result !== (32'hF0F0_F0F0 ^ 32'hFF00_FF00)) begin
            $display("[FAIL] XOR failed! Got 0x%08h", alu_result);
            errors = errors + 1;
        end else begin
            $display("[PASS] XOR result: 0x%08h", alu_result);
        end

        alu_in_a = 32'h8000_0000; alu_in_b = 32'd2; alu_ctrl = ALU_SRL; #5;
        if (alu_result !== 32'h2000_0000) begin
            $display("[FAIL] SRL failed! Expected 0x20000000, got 0x%08h", alu_result);
            errors = errors + 1;
        end else begin
            $display("[PASS] SRL (0x80000000 >> 2 = 0x%08h)", alu_result);
        end

        alu_in_a = 32'h8000_0000; alu_in_b = 32'd2; alu_ctrl = ALU_SRA; #5;
        if (alu_result !== 32'hE000_0000) begin
            $display("[FAIL] SRA failed! Expected 0xE0000000, got 0x%08h", alu_result);
            errors = errors + 1;
        end else begin
            $display("[PASS] SRA (0x80000000 >>> 2 = 0x%08h)", alu_result);
        end

        alu_in_a = 32'h0F0F_0F0F; alu_in_b = 32'hF0F0_F0F0; alu_ctrl = ALU_OR; #5;
        if (alu_result !== 32'hFFFF_FFFF) begin
            $display("[FAIL] OR failed! Expected 0xFFFFFFFF, got 0x%08h", alu_result);
            errors = errors + 1;
        end else begin
            $display("[PASS] OR result: 0x%08h", alu_result);
        end

        alu_in_a = 32'h1234_5678; alu_in_b = 32'h0000_FFFF; alu_ctrl = ALU_AND; #5;
        if (alu_result !== 32'h0000_5678) begin
            $display("[FAIL] AND failed! Expected 0x00005678, got 0x%08h", alu_result);
            errors = errors + 1;
        end else begin
            $display("[PASS] AND result: 0x%08h", alu_result);
        end

        alu_in_a = 32'h1111_1111; alu_in_b = 32'hABCD_0000; alu_ctrl = ALU_PASSB; #5;
        if (alu_result !== 32'hABCD_0000) begin
            $display("[FAIL] PASS_B failed! Expected 0xABCD0000, got 0x%08h", alu_result);
            errors = errors + 1;
        end else begin
            $display("[PASS] PASS_B result: 0x%08h", alu_result);
        end

        $display("------------------------------------------------------------");
        if (errors == 0) begin
            $display("alu_tb RESULT: ALL TESTS PASSED!");
        end else begin
            $display("alu_tb RESULT: %0d TESTS FAILED!", errors);
        end
        $display("------------------------------------------------------------");

        #10;
        $finish;
    end

endmodule
