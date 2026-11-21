
`timescale 1ns / 1ps

module instruction_memory #(
    parameter MEM_WORDS = 256  
)(
    input  wire [31:0] addr,        
    output wire [31:0] instruction  
);

 
    reg [31:0] mem [0:MEM_WORDS-1];

    wire [29:0] word_addr = addr[31:2];

    localparam NOP = 32'h0000_0013;

    assign instruction = (word_addr < MEM_WORDS) ? mem[word_addr] : NOP;

    integer i;
    initial begin
        for (i = 0; i < MEM_WORDS; i = i + 1) begin
            mem[i] = NOP;
        end
    end

endmodule
