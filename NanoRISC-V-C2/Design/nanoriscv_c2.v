//
`timescale 1ns / 1ps

module nanoriscv_c2 #(
    parameter IMEM_WORDS = 256,  
    parameter DMEM_DEPTH = 1024  
)(
    input  wire        clk,
    input  wire        rst,
    
    output wire [31:0] debug_pc,
    output wire [31:0] debug_instr,
    output wire [31:0] debug_alu_result,
    output wire [31:0] debug_wb_data,
    output wire        debug_reg_write,
    output wire [4:0]  debug_rd_addr,
    output wire        debug_flush
);

  
    wire [31:0] if_pc;
    wire [31:0] if_pc_plus_4;
    wire [31:0] pc_next;
    wire [31:0] if_instr;

  
    wire [31:0] id_pc;
    wire [31:0] id_instr;

   
    wire [6:0]  opcode = id_instr[6:0];
    wire [4:0]  rd     = id_instr[11:7];
    wire [2:0]  funct3 = id_instr[14:12];
    wire [4:0]  rs1    = id_instr[19:15];
    wire [4:0]  rs2    = id_instr[24:20];
    wire [6:0]  funct7 = id_instr[31:25];

 
    wire        reg_write;
    wire        mem_read;
    wire        mem_write;
    wire [1:0]  alu_src_a_sel;
    wire        alu_src_b_sel;
    wire [3:0]  alu_ctrl;
    wire [1:0]  wb_sel;
    wire        branch;
    wire        jump;
    wire        is_jalr;
    wire        branch_taken;
    wire        flush;

    wire [31:0] rs1_data;
    wire [31:0] rs2_data;

    wire [31:0] imm_out;

    reg  [31:0] alu_in_a;
    wire [31:0] alu_in_b;
    wire [31:0] alu_result;
    wire        alu_zero;

    wire [31:0] mem_read_data;

    reg  [31:0] wb_data;

    wire [31:0] jalr_target        = (rs1_data + imm_out) & ~32'h0000_0001;
    wire [31:0] branch_jump_target = id_pc + imm_out;
    wire [31:0] target_pc          = (is_jalr) ? jalr_target : branch_jump_target;

    assign if_pc_plus_4 = if_pc + 32'd4;
    assign pc_next      = (flush) ? target_pc : if_pc_plus_4;

    pc u_pc (
        .clk     (clk),
        .rst     (rst),
        .pc_en   (1'b1),
        .pc_next (pc_next),
        .pc_out  (if_pc)
    );


    instruction_memory #(.MEM_WORDS(IMEM_WORDS)) u_imem (
        .addr        (if_pc),
        .instruction (if_instr)
    );

    if_id_reg u_if_id_reg (
        .clk            (clk),
        .rst            (rst),
        .flush          (flush),
        .stall          (1'b0),
        .if_pc          (if_pc),
        .if_instruction (if_instr),
        .id_pc          (id_pc),
        .id_instruction (id_instr)
    );

    control_unit u_control_unit (
        .opcode       (opcode),
        .funct3       (funct3),
        .funct7       (funct7),
        .rs1_data     (rs1_data),
        .rs2_data     (rs2_data),
        .reg_write    (reg_write),
        .mem_read     (mem_read),
        .mem_write    (mem_write),
        .alu_src_a    (alu_src_a_sel),
        .alu_src_b    (alu_src_b_sel),
        .alu_ctrl     (alu_ctrl),
        .wb_sel       (wb_sel),
        .branch       (branch),
        .jump         (jump),
        .is_jalr      (is_jalr),
        .branch_taken (branch_taken),
        .flush        (flush)
    );


    imm_gen u_imm_gen (
        .instruction (id_instr),
        .imm_out     (imm_out)
    );

    register_file u_register_file (
        .clk       (clk),
        .rst       (rst),
        .reg_write (reg_write),
        .rs1_addr  (rs1),
        .rs2_addr  (rs2),
        .rd_addr   (rd),
        .rd_data   (wb_data),
        .rs1_data  (rs1_data),
        .rs2_data  (rs2_data)
    );


    always @(*) begin
        case (alu_src_a_sel)
            2'b00:   alu_in_a = rs1_data;
            2'b01:   alu_in_a = id_pc;
            2'b10:   alu_in_a = 32'h0000_0000;
            default: alu_in_a = rs1_data;
        endcase
    end

  
    assign alu_in_b = (alu_src_b_sel) ? imm_out : rs2_data;


    alu u_alu (
        .alu_in_a   (alu_in_a),
        .alu_in_b   (alu_in_b),
        .alu_ctrl   (alu_ctrl),
        .alu_result (alu_result),
        .zero       (alu_zero)
    );


    data_memory #(.MEM_DEPTH(DMEM_DEPTH)) u_dmem (
        .clk        (clk),
        .rst        (rst),
        .mem_read   (mem_read),
        .mem_write  (mem_write),
        .funct3     (funct3),
        .addr       (alu_result),
        .write_data (rs2_data),
        .read_data  (mem_read_data)
    );

    always @(*) begin
        case (wb_sel)
            2'b00:   wb_data = alu_result;
            2'b01:   wb_data = mem_read_data;
            2'b10:   wb_data = id_pc + 32'd4;
            default: wb_data = alu_result;
        endcase
    end

    assign debug_pc         = id_pc;
    assign debug_instr      = id_instr;
    assign debug_alu_result = alu_result;
    assign debug_wb_data    = wb_data;
    assign debug_reg_write  = reg_write;
    assign debug_rd_addr    = rd;
    assign debug_flush      = flush;

endmodule
