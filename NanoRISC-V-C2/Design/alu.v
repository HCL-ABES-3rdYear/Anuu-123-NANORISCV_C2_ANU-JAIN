
`timescale 1ns / 1ps

module alu (
    input  wire [31:0] alu_in_a,  
    input  wire [31:0] alu_in_b,   
    input  wire [3:0]  alu_ctrl,    
    output reg  [31:0] alu_result,  
    output wire        zero         
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

    always @(*) begin
        case (alu_ctrl)
            ALU_ADD:   alu_result = alu_in_a + alu_in_b;
            ALU_SUB:   alu_result = alu_in_a - alu_in_b;
            ALU_SLL:   alu_result = alu_in_a << alu_in_b[4:0];
            ALU_SLT:   alu_result = ($signed(alu_in_a) < $signed(alu_in_b)) ? 32'd1 : 32'd0;
            ALU_SLTU:  alu_result = (alu_in_a < alu_in_b) ? 32'd1 : 32'd0;
            ALU_XOR:   alu_result = alu_in_a ^ alu_in_b;
            ALU_SRL:   alu_result = alu_in_a >> alu_in_b[4:0];
            ALU_SRA:   alu_result = $signed(alu_in_a) >>> alu_in_b[4:0];
            ALU_OR:    alu_result = alu_in_a | alu_in_b;
            ALU_AND:   alu_result = alu_in_a & alu_in_b;
            ALU_PASSB: alu_result = alu_in_b;
            default:   alu_result = 32'h0000_0000;
        endcase
    end

    assign zero = (alu_result == 32'h0000_0000);

endmodule
