
`timescale 1ns / 1ps

module register_file (
    input  wire        clk,
    input  wire        rst,
    input  wire        reg_write, 
    input  wire [4:0]  rs1_addr,  
    input  wire [4:0]  rs2_addr, 
    input  wire [4:0]  rd_addr,  
    input  wire [31:0] rd_data,  
    output wire [31:0] rs1_data,  
    output wire [31:0] rs2_data  
);

    reg [31:0] registers [0:31];

    integer i;

  
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'h0000_0000;
            end
        end else if (reg_write && (rd_addr != 5'd0)) begin
            registers[rd_addr] <= rd_data;
        end
    end

    assign rs1_data = (rs1_addr == 5'd0) ? 32'h0000_0000 :
                      (reg_write && (rd_addr == rs1_addr)) ? rd_data :
                      registers[rs1_addr];

    assign rs2_data = (rs2_addr == 5'd0) ? 32'h0000_0000 :
                      (reg_write && (rd_addr == rs2_addr)) ? rd_data :
                      registers[rs2_addr];

endmodule
