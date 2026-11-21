
`timescale 1ns / 1ps

module control_unit_tb;

    reg  [6:0]  opcode;
    reg  [2:0]  funct3;
    reg  [6:0]  funct7;
    reg  [31:0] rs1_data;
    reg  [31:0] rs2_data;

    wire        reg_write;
    wire        mem_read;
    wire        mem_write;
    wire [1:0]  alu_src_a;
    wire        alu_src_b;
    wire [3:0]  alu_ctrl;
    wire [1:0]  wb_sel;
    wire        branch;
    wire        jump;
    wire        is_jalr;
    wire        branch_taken;
    wire        flush;

    integer errors;

    control_unit dut (
        .opcode       (opcode),
        .funct3       (funct3),
        .funct7       (funct7),
        .rs1_data     (rs1_data),
        .rs2_data     (rs2_data),
        .reg_write    (reg_write),
        .mem_read     (mem_read),
        .mem_write    (mem_write),
        .alu_src_a    (alu_src_a),
        .alu_src_b    (alu_src_b),
        .alu_ctrl     (alu_ctrl),
        .wb_sel       (wb_sel),
        .branch       (branch),
        .jump         (jump),
        .is_jalr      (is_jalr),
        .branch_taken (branch_taken),
        .flush        (flush)
    );

    initial begin
 
        $dumpfile("control_unit.vcd");
        $dumpvars(0, control_unit_tb);

        errors   = 0;
        opcode   = 7'd0;
        funct3   = 3'd0;
        funct7   = 7'd0;
        rs1_data = 32'd0;
        rs2_data = 32'd0;

        $display("------------------------------------------------------------");
        $display("Starting Testbench: Control Unit (control_unit_tb)");
        $display("------------------------------------------------------------");


        opcode = 7'b0110011; funct3 = 3'b000; funct7 = 7'b0000000; #5;
        if (reg_write !== 1'b1 || alu_src_b !== 1'b0 || alu_ctrl !== 4'b0000 || wb_sel !== 2'b00) begin
            $display("[FAIL] R-Type ADD failed: reg_write=%b, alu_ctrl=%b, wb_sel=%b", reg_write, alu_ctrl, wb_sel);
            errors = errors + 1;
        end else begin
            $display("[PASS] R-Type ADD decoded: reg_write=%b, alu_ctrl=ADD", reg_write);
        end


        funct7 = 7'b0100000; #5;
        if (alu_ctrl !== 4'b0001) begin
            $display("[FAIL] R-Type SUB failed: expected alu_ctrl=0001, got %b", alu_ctrl);
            errors = errors + 1;
        end else begin
            $display("[PASS] R-Type SUB decoded: alu_ctrl=SUB");
        end

        opcode = 7'b0010011; funct3 = 3'b000; funct7 = 7'b0000000; #5;
        if (reg_write !== 1'b1 || alu_src_b !== 1'b1 || alu_ctrl !== 4'b0000) begin
            $display("[FAIL] I-Type ADDI failed: reg_write=%b, alu_src_b=%b, alu_ctrl=%b", reg_write, alu_src_b, alu_ctrl);
            errors = errors + 1;
        end else begin
            $display("[PASS] I-Type ADDI decoded: alu_src_b=IMM, alu_ctrl=ADD");
        end

        opcode = 7'b0000011; funct3 = 3'b010; #5;
        if (reg_write !== 1'b1 || mem_read !== 1'b1 || wb_sel !== 2'b01) begin
            $display("[FAIL] Load (LW) failed: reg_write=%b, mem_read=%b, wb_sel=%b", reg_write, mem_read, wb_sel);
            errors = errors + 1;
        end else begin
            $display("[PASS] Load (LW) decoded: mem_read=%b, wb_sel=MEM_DATA", mem_read);
        end

 
        opcode = 7'b0100011; funct3 = 3'b010; #5;
        if (reg_write !== 1'b0 || mem_write !== 1'b1 || alu_src_b !== 1'b1) begin
            $display("[FAIL] Store (SW) failed: mem_write=%b, reg_write=%b", mem_write, reg_write);
            errors = errors + 1;
        end else begin
            $display("[PASS] Store (SW) decoded: mem_write=%b, reg_write=%b", mem_write, reg_write);
        end


        opcode = 7'b1100011; funct3 = 3'b000; rs1_data = 32'd55; rs2_data = 32'd55; #5;
        if (branch !== 1'b1 || branch_taken !== 1'b1 || flush !== 1'b1) begin
            $display("[FAIL] BEQ Taken failed: branch=%b, branch_taken=%b, flush=%b", branch, branch_taken, flush);
            errors = errors + 1;
        end else begin
            $display("[PASS] BEQ Taken verified: branch_taken=%b, flush=%b", branch_taken, flush);
        end

        rs2_data = 32'd99; #5;
        if (branch_taken !== 1'b0 || flush !== 1'b0) begin
            $display("[FAIL] BEQ Not Taken failed: branch_taken=%b, flush=%b", branch_taken, flush);
            errors = errors + 1;
        end else begin
            $display("[PASS] BEQ Not Taken verified: branch_taken=%b, flush=%b", branch_taken, flush);
        end

        funct3 = 3'b100; rs1_data = -32'd10; rs2_data = 32'd5; #5;
        if (branch_taken !== 1'b1 || flush !== 1'b1) begin
            $display("[FAIL] BLT Taken failed (-10 < 5): branch_taken=%b", branch_taken);
            errors = errors + 1;
        end else begin
            $display("[PASS] BLT Signed Taken verified: -10 < 5 -> branch_taken=%b", branch_taken);
        end

        opcode = 7'b1101111; #5;
        if (jump !== 1'b1 || flush !== 1'b1 || wb_sel !== 2'b10 || reg_write !== 1'b1) begin
            $display("[FAIL] JAL failed: jump=%b, flush=%b, wb_sel=%b", jump, flush, wb_sel);
            errors = errors + 1;
        end else begin
            $display("[PASS] JAL decoded: jump=%b, flush=%b, wb_sel=PC+4, reg_write=%b", jump, flush, reg_write);
        end

   
        opcode = 7'b1100111; #5;
        if (jump !== 1'b1 || is_jalr !== 1'b1 || flush !== 1'b1 || wb_sel !== 2'b10) begin
            $display("[FAIL] JALR failed: jump=%b, is_jalr=%b, flush=%b", jump, is_jalr, flush);
            errors = errors + 1;
        end else begin
            $display("[PASS] JALR decoded: jump=%b, is_jalr=%b, flush=%b", jump, is_jalr, flush);
        end

        opcode = 7'b0110111; #5;
        if (reg_write !== 1'b1 || alu_src_a !== 2'b10 || alu_src_b !== 1'b1 || alu_ctrl !== 4'b1010) begin
            $display("[FAIL] LUI failed: reg_write=%b, alu_src_a=%b, alu_ctrl=%b", reg_write, alu_src_a, alu_ctrl);
            errors = errors + 1;
        end else begin
            $display("[PASS] LUI decoded: reg_write=%b, alu_src_a=ZERO, alu_ctrl=PASSB", reg_write);
        end

        opcode = 7'b0010111; #5;
        if (reg_write !== 1'b1 || alu_src_a !== 2'b01 || alu_src_b !== 1'b1 || alu_ctrl !== 4'b0000) begin
            $display("[FAIL] AUIPC failed: reg_write=%b, alu_src_a=%b, alu_ctrl=%b", reg_write, alu_src_a, alu_ctrl);
            errors = errors + 1;
        end else begin
            $display("[PASS] AUIPC decoded: reg_write=%b, alu_src_a=PC, alu_ctrl=ADD", reg_write);
        end

        $display("------------------------------------------------------------");
        if (errors == 0) begin
            $display("control_unit_tb RESULT: ALL TESTS PASSED!");
        end else begin
            $display("control_unit_tb RESULT: %0d TESTS FAILED!", errors);
        end
        $display("------------------------------------------------------------");

        #10;
        $finish;
    end

endmodule
