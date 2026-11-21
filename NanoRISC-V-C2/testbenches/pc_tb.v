
`timescale 1ns / 1ps

module pc_tb;

    reg         clk;
    reg         rst;
    reg         pc_en;
    reg  [31:0] pc_next;
    wire [31:0] pc_out;

    integer errors;

    pc dut (
        .clk     (clk),
        .rst     (rst),
        .pc_en   (pc_en),
        .pc_next (pc_next),
        .pc_out  (pc_out)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("pc.vcd");
        $dumpvars(0, pc_tb);

        clk     = 0;
        rst     = 1;
        pc_en   = 1;
        pc_next = 32'h0000_0000;
        errors  = 0;

        $display("------------------------------------------------------------");
        $display("Starting Testbench: Program Counter (pc_tb)");
        $display("------------------------------------------------------------");

        #12;
        if (pc_out !== 32'h0000_0000) begin
            $display("[FAIL] Test 1: Reset failed, expected 0x00000000, got 0x%08h", pc_out);
            errors = errors + 1;
        end else begin
            $display("[PASS] Test 1: Reset successfully cleared PC to 0x00000000");
        end

        @(negedge clk);
        rst = 0;

        pc_next = 32'h0000_0004;
        @(posedge clk); #1;
        if (pc_out !== 32'h0000_0004) begin
            $display("[FAIL] Test 2: Sequential increment failed, expected 0x00000004, got 0x%08h", pc_out);
            errors = errors + 1;
        end else begin
            $display("[PASS] Test 2: Sequential step 1 correct: PC = 0x%08h", pc_out);
        end

        pc_next = 32'h0000_0008;
        @(posedge clk); #1;
        if (pc_out !== 32'h0000_0008) begin
            $display("[FAIL] Test 2: Sequential increment failed, expected 0x00000008, got 0x%08h", pc_out);
            errors = errors + 1;
        end else begin
            $display("[PASS] Test 2: Sequential step 2 correct: PC = 0x%08h", pc_out);
        end

        pc_next = 32'h0000_0080;
        @(posedge clk); #1;
        if (pc_out !== 32'h0000_0080) begin
            $display("[FAIL] Test 3: Jump target update failed, expected 0x00000080, got 0x%08h", pc_out);
            errors = errors + 1;
        end else begin
            $display("[PASS] Test 3: Branch/Jump target updated to 0x%08h", pc_out);
        end

        pc_en = 0;
        pc_next = 32'h0000_0090;
        @(posedge clk); #1;
        if (pc_out !== 32'h0000_0080) begin
            $display("[FAIL] Test 4: Stall failed, expected PC to hold 0x00000080, got 0x%08h", pc_out);
            errors = errors + 1;
        end else begin
            $display("[PASS] Test 4: PC held steady during stall: PC = 0x%08h", pc_out);
        end

        pc_en = 1;
        @(posedge clk); #1;
        if (pc_out !== 32'h0000_0090) begin
            $display("[FAIL] Test 4: Resume after stall failed, expected 0x00000090, got 0x%08h", pc_out);
            errors = errors + 1;
        end else begin
            $display("[PASS] Test 4: PC updated after releasing stall: PC = 0x%08h", pc_out);
        end

        $display("------------------------------------------------------------");
        if (errors == 0) begin
            $display("pc_tb RESULT: ALL TESTS PASSED!");
        end else begin
            $display("pc_tb RESULT: %0d TESTS FAILED!", errors);
        end
        $display("------------------------------------------------------------");

        #20;
        $finish;
    end

endmodule
