
`timescale 1ns / 1ps

module nanoriscv_c2_tb;

    reg         clk;
    reg         rst;

    wire [31:0] debug_pc;
    wire [31:0] debug_instr;
    wire [31:0] debug_alu_result;
    wire [31:0] debug_wb_data;
    wire        debug_reg_write;
    wire [4:0]  debug_rd_addr;
    wire        debug_flush;

    integer cycle_count;
    integer errors;

    nanoriscv_c2 #(
        .IMEM_WORDS (256),
        .DMEM_DEPTH (1024)
    ) dut (
        .clk             (clk),
        .rst             (rst),
        .debug_pc        (debug_pc),
        .debug_instr     (debug_instr),
        .debug_alu_result(debug_alu_result),
        .debug_wb_data   (debug_wb_data),
        .debug_reg_write (debug_reg_write),
        .debug_rd_addr   (debug_rd_addr),
        .debug_flush     (debug_flush)
    );

    always #5 clk = ~clk;

    task load_program;
        begin
     
            dut.u_imem.mem[0]  = 32'h00F00093;
            dut.u_imem.mem[1]  = 32'h01B00113;
            dut.u_imem.mem[2]  = 32'h002081B3;
            dut.u_imem.mem[3]  = 32'h40118233;
            dut.u_imem.mem[4]  = 32'h00209293;
            dut.u_imem.mem[5]  = 32'h00302223;
            dut.u_imem.mem[6]  = 32'h00402303;
            dut.u_imem.mem[7]  = 32'h00618463;
            dut.u_imem.mem[8]  = 32'h06300393;
            dut.u_imem.mem[9]  = 32'h06400393;
            dut.u_imem.mem[10] = 32'h0080046F;
            dut.u_imem.mem[11] = 32'h05800493;
            dut.u_imem.mem[12] = 32'h04D00493;
            dut.u_imem.mem[13] = 32'h12345537;
            dut.u_imem.mem[14] = 32'h00010597;
            dut.u_imem.mem[15] = 32'h0000006F;
        end
    endtask

    initial begin
        $dumpfile("nanoriscv_c2.vcd");
        $dumpvars(0, nanoriscv_c2_tb);

        clk         = 0;
        rst         = 1;
        cycle_count = 0;
        errors      = 0;

        $display("============================================================");
        $display("  NanoRISC-V-C2: 2-Stage RV32I Processor Core Simulation    ");
        $display("============================================================");

        load_program();

        #20;
        @(negedge clk);
        rst = 0;
        $display("[TIME: %0t ns] Reset released. Processor running...", $time);

        while (cycle_count < 35) begin
            @(posedge clk);
            cycle_count = cycle_count + 1;
            #1;
            $display("[Cycle %2d] PC: 0x%08h | Instr: 0x%08h | WB: %b -> x%02d = 0x%08h | Flush: %b",
                     cycle_count, debug_pc, debug_instr, debug_reg_write, debug_rd_addr, debug_wb_data, debug_flush);
        end

        $display("\n============================================================");
        $display("              FINAL ARCHITECTURAL VERIFICATION              ");
        $display("============================================================");

        if (dut.u_register_file.registers[1] !== 32'd15) begin
            $display("[FAIL] x1 expected 15, got %0d", dut.u_register_file.registers[1]);
            errors = errors + 1;
        end else begin
            $display("[PASS] x1 = %0d (ADDI x1, x0, 15)", dut.u_register_file.registers[1]);
        end

        if (dut.u_register_file.registers[2] !== 32'd27) begin
            $display("[FAIL] x2 expected 27, got %0d", dut.u_register_file.registers[2]);
            errors = errors + 1;
        end else begin
            $display("[PASS] x2 = %0d (ADDI x2, x0, 27)", dut.u_register_file.registers[2]);
        end

        if (dut.u_register_file.registers[3] !== 32'd42) begin
            $display("[FAIL] x3 expected 42, got %0d", dut.u_register_file.registers[3]);
            errors = errors + 1;
        end else begin
            $display("[PASS] x3 = %0d (ADD x3, x1, x2)", dut.u_register_file.registers[3]);
        end

        if (dut.u_register_file.registers[4] !== 32'd27) begin
            $display("[FAIL] x4 expected 27, got %0d", dut.u_register_file.registers[4]);
            errors = errors + 1;
        end else begin
            $display("[PASS] x4 = %0d (SUB x4, x3, x1)", dut.u_register_file.registers[4]);
        end

        if (dut.u_register_file.registers[5] !== 32'd60) begin
            $display("[FAIL] x5 expected 60, got %0d", dut.u_register_file.registers[5]);
            errors = errors + 1;
        end else begin
            $display("[PASS] x5 = %0d (SLLI x5, x1, 2)", dut.u_register_file.registers[5]);
        end

        if (dut.u_register_file.registers[6] !== 32'd42) begin
            $display("[FAIL] x6 expected 42 (SW/LW), got %0d", dut.u_register_file.registers[6]);
            errors = errors + 1;
        end else begin
            $display("[PASS] x6 = %0d (SW x3, 4(x0) & LW x6, 4(x0))", dut.u_register_file.registers[6]);
        end

        if (dut.u_register_file.registers[7] !== 32'd100) begin
            $display("[FAIL] Branch / Pipeline Flush failed! x7 expected 100, got %0d", dut.u_register_file.registers[7]);
            errors = errors + 1;
        end else begin
            $display("[PASS] x7 = %0d (BEQ taken & speculative wrong-path instruction flushed)", dut.u_register_file.registers[7]);
        end

        if (dut.u_register_file.registers[8] !== 32'h0000_002C) begin
            $display("[FAIL] JAL Link Register failed! x8 expected 0x0000002C (44), got 0x%08h", dut.u_register_file.registers[8]);
            errors = errors + 1;
        end else begin
            $display("[PASS] x8 = 0x%08h (JAL Link Address PC+4)", dut.u_register_file.registers[8]);
        end

        if (dut.u_register_file.registers[9] !== 32'd77) begin
            $display("[FAIL] JAL Target / Flush failed! x9 expected 77, got %0d", dut.u_register_file.registers[9]);
            errors = errors + 1;
        end else begin
            $display("[PASS] x9 = %0d (JAL target reached & speculative wrong-path flushed)", dut.u_register_file.registers[9]);
        end

        if (dut.u_register_file.registers[10] !== 32'h1234_5000) begin
            $display("[FAIL] LUI failed! x10 expected 0x12345000, got 0x%08h", dut.u_register_file.registers[10]);
            errors = errors + 1;
        end else begin
            $display("[PASS] x10 = 0x%08h (LUI x10, 0x12345)", dut.u_register_file.registers[10]);
        end

        if (dut.u_register_file.registers[11] !== 32'h0001_0038) begin
            $display("[FAIL] AUIPC failed! x11 expected 0x00010038, got 0x%08h", dut.u_register_file.registers[11]);
            errors = errors + 1;
        end else begin
            $display("[PASS] x11 = 0x%08h (AUIPC x11, 0x00010)", dut.u_register_file.registers[11]);
        end

        $display("============================================================");
        if (errors == 0) begin
            $display(">>>>> OVERALL RESULT: ALL PROCESSOR TESTS PASSED! <<<<<");
        end else begin
            $display(">>>>> OVERALL RESULT: %0d TESTS FAILED! <<<<<", errors);
        end
        $display("============================================================\n");

        #20;
        $finish;
    end

endmodule
