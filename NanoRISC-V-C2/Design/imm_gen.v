
`timescale 1ns / 1ps

module imm_gen (
    input  wire [31:0] instruction,
    output reg  [31:0] imm_out
);

    wire [6:0] opcode = instruction[6:0];

   
    localparam OPC_OP_IMM = 7'b0010011; 
    localparam OPC_LOAD   = 7'b0000011; 
    localparam OPC_JALR   = 7'b1100111; 
    localparam OPC_STORE  = 7'b0100011; 
    localparam OPC_BRANCH = 7'b1100011; 
    localparam OPC_LUI    = 7'b0110111; 
    localparam OPC_AUIPC  = 7'b0010111;
    localparam OPC_JAL    = 7'b1101111;

    always @(*) begin
        case (opcode)
           
            OPC_OP_IMM,
            OPC_LOAD,
            OPC_JALR: begin
                imm_out = {{20{instruction[31]}}, instruction[31:20]};
            end

      
            OPC_STORE: begin
                imm_out = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            end

            OPC_BRANCH: begin
                imm_out = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            end

            OPC_LUI,
            OPC_AUIPC: begin
                imm_out = {instruction[31:12], 12'b0};
            end

            OPC_JAL: begin
                imm_out = {{11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
            end

            default: begin
                imm_out = 32'h0000_0000;
            end
        endcase
    end

endmodule
