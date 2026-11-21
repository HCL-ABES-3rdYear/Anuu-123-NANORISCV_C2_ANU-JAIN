
`timescale 1ns / 1ps

module if_id_reg (
    input  wire        clk,
    input  wire        rst,
    input  wire        flush,          
    input  wire        stall,        
    input  wire [31:0] if_pc,         
    input  wire [31:0] if_instruction, 
    output reg  [31:0] id_pc,          
    output reg  [31:0] id_instruction  
);

  
    localparam NOP = 32'h0000_0013;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            id_pc          <= 32'h0000_0000;
            id_instruction <= NOP;
        end else if (flush) begin
        
            id_pc          <= 32'h0000_0000;
            id_instruction <= NOP;
        end else if (!stall) begin
    
            id_pc          <= if_pc;
            id_instruction <= if_instruction;
        end
       end

endmodule
