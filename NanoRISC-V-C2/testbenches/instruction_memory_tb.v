
`timescale 1ns / 1ps

module instruction_memory_tb;

    reg  [31:0] addr;
    wire [31:0] instruction;

    integer errors;

    instruction_memory #(.MEM_WORDS(16)) dut (
        .addr        (addr),
        .instruction (instruction)
    );

    initial begin

        $dumpfile("instruction_memory.vcd");
        $dumpvars(0, instruction_memory_tb);

        errors = 0;
        addr   = 32'h0000_0000;

        $display("------------------------------------------------------------");
        $display("Starting Testbench: Instruction Memory (instruction_memory_tb)");
        $display("------------------------------------------------------------");


        dut.mem[0] = 32'h00500093; 
        dut.mem[1] = 32'h00a00113; 
        dut.mem[2] = 32'h002081b3;
        dut.mem[3] = 32'h0030a223; 
        dut.mem[4] = 32'h0040a283; 

        #10;
 
        addr = 32'h0000_0000; #5;
        if (instruction !== 32'h00500093) begin
            $display("[FAIL] Addr 0x00 expected 0x00500093, got 0x%08h", instruction);
            errors = errors + 1;
        end else begin
            $display("[PASS] Addr 0x00 correct: 0x%08h (addi x1, x0, 5)", instruction);
        end

        addr = 32'h0000_0004; #5;
        if (instruction !== 32'h00a00113) begin
            $display("[FAIL] Addr 0x04 expected 0x00a00113, got 0x%08h", instruction);
            errors = errors + 1;
        end else begin
            $display("[PASS] Addr 0x04 correct: 0x%08h (addi x2, x0, 10)", instruction);
        end

        addr = 32'h0000_0008; #5;
        if (instruction !== 32'h002081b3) begin
            $display("[FAIL] Addr 0x08 expected 0x002081b3, got 0x%08h", instruction);
            errors = errors + 1;
        end else begin
            $display("[PASS] Addr 0x08 correct: 0x%08h (add x3, x1, x2)", instruction);
        end

        addr = 32'h0000_000C; #5;
        if (instruction !== 32'h0030a223) begin
            $display("[FAIL] Addr 0x0C expected 0x0030a223, got 0x%08h", instruction);
            errors = errors + 1;
        end else begin
            $display("[PASS] Addr 0x0C correct: 0x%08h (sw x3, 4(x1))", instruction);
        end

        addr = 32'h0000_0100; #5;
        if (instruction !== 32'h0000_0013) begin
            $display("[FAIL] Out-of-bounds expected NOP (0x00000013), got 0x%08h", instruction);
            errors = errors + 1;
        end else begin
            $display("[PASS] Out-of-bounds returned default NOP: 0x%08h", instruction);
        end

        $display("------------------------------------------------------------");
        if (errors == 0) begin
            $display("instruction_memory_tb RESULT: ALL TESTS PASSED!");
        end else begin
            $display("instruction_memory_tb RESULT: %0d TESTS FAILED!", errors);
        end
        $display("------------------------------------------------------------");

        #10;
        $finish;
    end

endmodule
