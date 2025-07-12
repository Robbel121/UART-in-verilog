`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/04/2025 05:33:36 PM
// Design Name: 
// Module Name: tbRxUART
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


module tbRxUART();

    parameter CLK_PER_BIT = 434;
    parameter CLK_PERIOD = 20;
    parameter BIT_PERIOD = 8680; // 1/115200(baudrate) = 8.68 microsec = 8680 nanosec
    
    reg clk = 0;
    reg rx_serial = 1'b1;
    wire [7:0] rx_data;
    wire rx_finish;
        
//    task UART_WRITE; 
//        input [7:0] data_reg;
//        integer i;    
//        begin
//        //Start bit activation
//        rx_serial <= 1'b0;
//        #(BIT_PERIOD);
       
//        for(i = 0; i < 8; i = i + 1)begin
//            rx_serial <= data_reg[i];
//            #(BIT_PERIOD);
//        end
        
//        //Stop bit
//        rx_serial <= 1'b1;
//        #(BIT_PERIOD);
//        end
//    endtask
    //        UART_WRITE(8'b01111110);
    uartRx #(.CLK_PER_BIT(CLK_PER_BIT)) uut(
       .clk(clk), 
       .rx_serial(rx_serial),
       .rx_data(rx_data), 
       .rx_finish(rx_finish)
    );
    
    always #10 clk <= !clk;

    initial begin
        repeat(2)@(posedge clk);
        //Start Bit
        rx_serial <= 1'b0;
        #(BIT_PERIOD);
        
        rx_serial <=1'b1;
        #(BIT_PERIOD);
        rx_serial <=1'b0;
        #(BIT_PERIOD);
        rx_serial <=1'b0;
        #(BIT_PERIOD);
        rx_serial <=1'b1;
        #(BIT_PERIOD);
        rx_serial <=1'b0;
        #(BIT_PERIOD);
        rx_serial <=1'b0;
        #(BIT_PERIOD);
        rx_serial <=1'b1;
        #(BIT_PERIOD);
        rx_serial <=1'b1;
        #(BIT_PERIOD);
        rx_serial <= 1'b1;
        #(BIT_PERIOD);
        
        //Stop bit
        rx_serial <= 1'b1;
        @(posedge clk);
        
        // Expected value check
        if(rx_data == 8'b10010011)
            $display("Test passed");
        else
            $display("Test failed");
    end
    
    
endmodule
