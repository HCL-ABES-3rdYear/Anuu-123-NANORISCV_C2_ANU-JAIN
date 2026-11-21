
`timescale 1ns / 1ps

module pc (
    input  wire        clk,
    input  wire        rst,
    input  wire        pc_en,    
    input  wire [31:0] pc_next, 
    output reg  [31:0] pc_out 
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_out <= 32'h0000_0000;
        end else if (pc_en) begin
            pc_out <= pc_next;
        end
    end

endmodule
