`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/04/2025 05:21:36 PM
// Design Name: 
// Module Name: uartRx
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


module uartRx
     #(CLK_PER_BIT = 9'd434) // 50 Mhz clock / baudrate(115200) = ~434
    (
    input clk,
    input rx_serial,
    output [7:0] rx_data,
    output rx_finish
    );
    
    localparam IDLE = 2'b00,
                START_BIT = 2'b01,
                DATA_BITS = 2'b10,
                STOP_BIT = 2'b11;
                
    reg r_rx_data = 1'b1;
    reg reg_rx_data = 1'b1;            
    
    reg [8:0] clock_counter;
    reg [7:0] data_reg;
    reg [2:0] index;
    reg [1:0] state;
    
    reg rx_finish_reg;
    
    assign rx_finish = rx_finish_reg;
    assign rx_data = data_reg;

    initial begin
        state = IDLE;
    end
    
    //Double register for input data to reduce/eliminate metastability issues
    always @(posedge clk)begin
        reg_rx_data <= rx_serial;
        r_rx_data <= reg_rx_data;
    end
    
    always @(posedge clk)begin
        case(state)
            IDLE: begin // Runs at the beginning
                clock_counter <= 0;
                index <= 0;
                 rx_finish_reg <= 1'b0;

                
                if(r_rx_data == 1'b0) // If data detected, carry on to next state
                    state <= START_BIT;
                else
                    state <= IDLE;
            end
            
            START_BIT : begin
                    if(clock_counter == (CLK_PER_BIT -1)/2)begin // Used to determine if this is start bit
                            if(r_rx_data == 1'b0)begin
                                clock_counter <= 0;
                                state <= DATA_BITS;
                            end
                            else
                                state <=  IDLE;
                    end
                    else begin
                        clock_counter <= clock_counter +1;
                        state <= START_BIT;
                    end
            end
            
            DATA_BITS : begin
                    if((clock_counter == CLK_PER_BIT - 1))begin // CLK_PER_BIT is used to find the value for each index in the vector.
                        clock_counter <= 0;
                        data_reg[index] <= rx_serial;
                        
                        if(index < 7)begin // Increment bits until index is larger than vector size
                            index <=  index + 1;
                            state <= DATA_BITS;
                        end
                        else begin
                            index <= 0;
                            state <= STOP_BIT;
                        end
                    end
                    else begin
                       clock_counter <=  clock_counter + 1;
                       state <= DATA_BITS; 
                    end
              end
              
              STOP_BIT : begin
                    if((clock_counter == CLK_PER_BIT - 1))begin 
                        // Last sample signal
                        if(r_rx_data == 1'b1)begin
                            rx_finish_reg <= 1'b1;
                            state <= IDLE; 
                        end
                        else 
                            state <= IDLE;
                            clock_counter <= 0;
                    end
                        
                    else begin
                        clock_counter <= clock_counter + 1;
                        state <= STOP_BIT;
                    end
              end
        endcase
    end
    
endmodule
