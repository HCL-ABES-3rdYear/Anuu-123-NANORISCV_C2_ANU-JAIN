
`timescale 1ns / 1ps

module data_memory #(
    parameter MEM_DEPTH = 1024 
)(
    input  wire        clk,
    input  wire        rst,
    input  wire        mem_read,
    input  wire        mem_write,
    input  wire [2:0]  funct3,     
    input  wire [31:0] addr,      
    input  wire [31:0] write_data, 
    output reg  [31:0] read_data   
);

    reg [7:0] memory [0:MEM_DEPTH-1];

    integer i;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < MEM_DEPTH; i = i + 1) begin
                memory[i] <= 8'h00;
            end
        end else if (mem_write && (addr < MEM_DEPTH)) begin
            case (funct3)
      
                3'b000: begin
                    memory[addr] <= write_data[7:0];
                end

                3'b001: begin
                    if (addr + 1 < MEM_DEPTH) begin
                        memory[addr]     <= write_data[7:0];
                        memory[addr + 1] <= write_data[15:8];
                    end
                end

                3'b010: begin
                    if (addr + 3 < MEM_DEPTH) begin
                        memory[addr]     <= write_data[7:0];
                        memory[addr + 1] <= write_data[15:8];
                        memory[addr + 2] <= write_data[23:16];
                        memory[addr + 3] <= write_data[31:24];
                    end
                end

                default: ; 
            endcase
        end
    end

    always @(*) begin
        if (mem_read && (addr < MEM_DEPTH)) begin
            case (funct3)
         
                3'b000: begin
                    read_data = {{24{memory[addr][7]}}, memory[addr]};
                end

                3'b001: begin
                    if (addr + 1 < MEM_DEPTH) begin
                        read_data = {{16{memory[addr + 1][7]}}, memory[addr + 1], memory[addr]};
                    end else begin
                        read_data = 32'h0000_0000;
                    end
                end

                3'b010: begin
                    if (addr + 3 < MEM_DEPTH) begin
                        read_data = {memory[addr + 3], memory[addr + 2], memory[addr + 1], memory[addr]};
                    end else begin
                        read_data = 32'h0000_0000;
                    end
                end

                3'b100: begin
                    read_data = {24'h000000, memory[addr]};
                end

                3'b101: begin
                    if (addr + 1 < MEM_DEPTH) begin
                        read_data = {16'h0000, memory[addr + 1], memory[addr]};
                    end else begin
                        read_data = 32'h0000_0000;
                    end
                end

                default: begin
                    read_data = 32'h0000_0000;
                end
            endcase
        end else begin
            read_data = 32'h0000_0000;
        end
    end

endmodule
