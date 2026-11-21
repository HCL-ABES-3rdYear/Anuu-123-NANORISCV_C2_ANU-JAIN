
`timescale 1ns / 1ps

module control_unit (
    input  wire [6:0]  opcode,
    input  wire [2:0]  funct3,
    input  wire [6:0]  funct7,
    input  wire [31:0] rs1_data,
    input  wire [31:0] rs2_data,
    output reg         reg_write,
    output reg         mem_read,
    output reg         mem_write,
    output reg  [1:0]  alu_src_a,  
    output reg         alu_src_b,   
    output reg  [3:0]  alu_ctrl,    
    output reg  [1:0]  wb_sel,     
    output reg         branch,    
    output reg         jump,       
    output reg         is_jalr,     
    output wire        branch_taken,
    output wire        flush       
);

 
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

  
    localparam OPC_R_TYPE = 7'b0110011;
    localparam OPC_OP_IMM = 7'b0010011;
    localparam OPC_LOAD   = 7'b0000011; 
    localparam OPC_STORE  = 7'b0100011; 
    localparam OPC_BRANCH = 7'b1100011; 
    localparam OPC_LUI    = 7'b0110111; 
    localparam OPC_AUIPC  = 7'b0010111; 
    localparam OPC_JAL    = 7'b1101111; 
    localparam OPC_JALR   = 7'b1100111; 
    reg branch_cond;

  
    always @(*) begin
   
        reg_write = 1'b0;
        mem_read  = 1'b0;
        mem_write = 1'b0;
        alu_src_a = 2'b00; 
        alu_src_b = 1'b0; 
        alu_ctrl  = ALU_ADD;
        wb_sel    = 2'b00; 
        branch    = 1'b0;
        jump      = 1'b0;
        is_jalr   = 1'b0;

        case (opcode)
          
            OPC_R_TYPE: begin
                reg_write = 1'b1;
                alu_src_a = 2'b00;
                alu_src_b = 1'b0;
                wb_sel    = 2'b00;
                case (funct3)
                    3'b000: alu_ctrl = (funct7[5]) ? ALU_SUB : ALU_ADD; 
                    3'b001: alu_ctrl = ALU_SLL;                         
                    3'b010: alu_ctrl = ALU_SLT;                         
                    3'b011: alu_ctrl = ALU_SLTU;                       
                    3'b100: alu_ctrl = ALU_XOR;                         
                    3'b101: alu_ctrl = (funct7[5]) ? ALU_SRA : ALU_SRL; 
                    3'b110: alu_ctrl = ALU_OR;                          
                    3'b111: alu_ctrl = ALU_AND;                         
                    default: alu_ctrl = ALU_ADD;
                endcase
            end

            OPC_OP_IMM: begin
                reg_write = 1'b1;
                alu_src_a = 2'b00;
                alu_src_b = 1'b1; 
                wb_sel    = 2'b00;
                case (funct3)
                    3'b000: alu_ctrl = ALU_ADD;                        
                    3'b001: alu_ctrl = ALU_SLL;                         
                    3'b010: alu_ctrl = ALU_SLT;                         
                    3'b011: alu_ctrl = ALU_SLTU;                        
                    3'b100: alu_ctrl = ALU_XOR;                         
                    3'b101: alu_ctrl = (funct7[5]) ? ALU_SRA : ALU_SRL; 
                    3'b110: alu_ctrl = ALU_OR;                         
                    3'b111: alu_ctrl = ALU_AND;                        
                    default: alu_ctrl = ALU_ADD;
                endcase
            end

           
            OPC_LOAD: begin
                reg_write = 1'b1;
                mem_read  = 1'b1;
                alu_src_a = 2'b00; 
                alu_src_b = 1'b1;  
                alu_ctrl  = ALU_ADD;
                wb_sel    = 2'b01; 
            end

          
            OPC_STORE: begin
                mem_write = 1'b1;
                alu_src_a = 2'b00; 
                alu_src_b = 1'b1;  
                alu_ctrl  = ALU_ADD;
            end

            OPC_BRANCH: begin
                branch    = 1'b1;
                alu_src_a = 2'b00;
                alu_src_b = 1'b0;
                alu_ctrl  = ALU_SUB;
            end

            OPC_LUI: begin
                reg_write = 1'b1;
                alu_src_a = 2'b10; 
                alu_src_b = 1'b1;  
                alu_ctrl  = ALU_PASSB;
                wb_sel    = 2'b00;
            end

            OPC_AUIPC: begin
                reg_write = 1'b1;
                alu_src_a = 2'b01;
                alu_src_b = 1'b1;
                alu_ctrl  = ALU_ADD;
                wb_sel    = 2'b00;
            end

            OPC_JAL: begin
                reg_write = 1'b1;
                jump      = 1'b1;
                wb_sel    = 2'b10;
            end

      
            OPC_JALR: begin
                reg_write = 1'b1;
                jump      = 1'b1;
                is_jalr   = 1'b1;
                wb_sel    = 2'b10; 
            end

            default: begin
                reg_write = 1'b0;
                mem_read  = 1'b0;
                mem_write = 1'b0;
                alu_src_a = 2'b00;
                alu_src_b = 1'b0;
                alu_ctrl  = ALU_ADD;
                wb_sel    = 2'b00;
                branch    = 1'b0;
                jump      = 1'b0;
                is_jalr   = 1'b0;
            end
        endcase
    end


    always @(*) begin
        case (funct3)
            3'b000: branch_cond = (rs1_data == rs2_data);                 
            3'b001: branch_cond = (rs1_data != rs2_data);                  
            3'b100: branch_cond = ($signed(rs1_data) <  $signed(rs2_data)); 
            3'b101: branch_cond = ($signed(rs1_data) >= $signed(rs2_data)); 
            3'b110: branch_cond = (rs1_data <  rs2_data);                
            3'b111: branch_cond = (rs1_data >= rs2_data);                
            default: branch_cond = 1'b0;
        endcase
    end


    assign branch_taken = branch & branch_cond;
    assign flush        = branch_taken | jump;

endmodule
