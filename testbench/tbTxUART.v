`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/17/2025 12:46:05 PM
// Design Name: 
// Module Name: tbTxUART
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tbTxUART();

    parameter CLK_PER_BIT = 434;
    parameter CLK_PERIOD = 20;
    parameter BIT_PERIOD = 8680; // 1/115200(baudrate) = 8.68 microsec = 8680 nanosec
    
    reg clk = 0;
    reg tx_data_req = 0;
    reg [7:0] tx_data = 0;
    wire tx_finish;
    wire tx_active;
    wire tx_serial;
    
    uartTx #(.CLK_PER_BIT(CLK_PER_BIT)) uut (
    .clk(clk),
    .tx_data_request(tx_data_req),
    .tx_data(tx_data),
    .tx_finish(tx_finish),
    .tx_serial(tx_serial),
    .tx_active(tx_active)
    );
    
    
    
    always #10 clk <= !clk;
    
    initial begin
        
        repeat(2)@(posedge clk);
        
        tx_data <= 8'b10101010;
        tx_data_req <= 1'b1;
        @(posedge clk);
        @(posedge clk);
        tx_data_req <= 1'b0;
        @(posedge clk);
        
        #(CLK_PER_BIT*20*CLK_PERIOD);

        $finish;
    end
    

endmodule
