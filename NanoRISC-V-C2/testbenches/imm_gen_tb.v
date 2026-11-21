
`timescale 1ns / 1ps

module imm_gen_tb;

    reg  [31:0] instruction;
    wire [31:0] imm_out;

    integer errors;


    imm_gen dut (
        .instruction (instruction),
        .imm_out     (imm_out)
    );

    initial begin

        $dumpfile("imm_gen.vcd");
        $dumpvars(0, imm_gen_tb);

        errors      = 0;
        instruction = 32'h0000_0000;

        $display("------------------------------------------------------------");
        $display("Starting Testbench: Immediate Generator (imm_gen_tb)");
        $display("------------------------------------------------------------");

    
        instruction = 32'h02A00093; #5;
        if (imm_out !== 32'h0000_002A) begin
            $display("[FAIL] I-Type Positive: Expected 0x0000002A, got 0x%08h", imm_out);
            errors = errors + 1;
        end else begin
            $display("[PASS] I-Type Positive Immediate decoded: %0d (0x%08h)", $signed(imm_out), imm_out);
        end

        instruction = 32'hFFF00093; #5;
        if (imm_out !== 32'hFFFF_FFFF) begin
            $display("[FAIL] I-Type Negative: Expected 0xFFFFFFFF, got 0x%08h", imm_out);
            errors = errors + 1;
        end else begin
            $display("[PASS] I-Type Negative Sign Extension decoded: %0d (0x%08h)", $signed(imm_out), imm_out);
        end

        instruction = 32'h0020A823; #5;
        if (imm_out !== 32'h0000_0010) begin
            $display("[FAIL] S-Type Positive: Expected 0x00000010, got 0x%08h", imm_out);
            errors = errors + 1;
        end else begin
            $display("[PASS] S-Type Positive Store Offset decoded: %0d (0x%08h)", $signed(imm_out), imm_out);
        end


        instruction = 32'hFE20AE23; #5;
        if (imm_out !== 32'hFFFF_FFFC) begin
            $display("[FAIL] S-Type Negative: Expected 0xFFFFFFFC (-4), got 0x%08h", imm_out);
            errors = errors + 1;
        end else begin
            $display("[PASS] S-Type Negative Store Offset decoded: %0d (0x%08h)", $signed(imm_out), imm_out);
        end

        instruction = 32'h00208863; #5;
        if (imm_out !== 32'h0000_0010) begin
            $display("[FAIL] B-Type Positive: Expected 0x00000010 (16), got 0x%08h", imm_out);
            errors = errors + 1;
        end else begin
            $display("[PASS] B-Type Positive Branch Offset decoded: %0d (0x%08h)", $signed(imm_out), imm_out);
        end

        instruction = 32'hFE2088E3; #5;
        if (imm_out !== 32'hFFFF_FFF0) begin
            $display("[FAIL] B-Type Negative: Expected 0xFFFFFFF0 (-16), got 0x%08h", imm_out);
            errors = errors + 1;
        end else begin
            $display("[PASS] B-Type Negative Branch Offset decoded: %0d (0x%08h)", $signed(imm_out), imm_out);
        end

        instruction = 32'h123450B7; #5;
        if (imm_out !== 32'h1234_5000) begin
            $display("[FAIL] U-Type LUI: Expected 0x12345000, got 0x%08h", imm_out);
            errors = errors + 1;
        end else begin
            $display("[PASS] U-Type LUI Upper Immediate decoded: 0x%08h", imm_out);
        end

        instruction = 32'h001000EF; #5;
        if (imm_out !== 32'h0000_0800) begin
            $display("[FAIL] J-Type Jump: Expected 0x00000800 (2048), got 0x%08h", imm_out);
            errors = errors + 1;
        end else begin
            $display("[PASS] J-Type JAL Jump Offset decoded: %0d (0x%08h)", $signed(imm_out), imm_out);
        end

        $display("------------------------------------------------------------");
        if (errors == 0) begin
            $display("imm_gen_tb RESULT: ALL TESTS PASSED!");
        end else begin
            $display("imm_gen_tb RESULT: %0d TESTS FAILED!", errors);
        end
        $display("------------------------------------------------------------");

        #10;
        $finish;
    end

endmodule
