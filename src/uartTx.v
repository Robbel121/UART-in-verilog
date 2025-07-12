`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/05/2025 02:58:16 PM
// Design Name: 
// Module Name: uartTx
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


module uartTx #(CLK_PER_BIT = 9'd434)(
    input clk,
    input tx_data_request,
    input [7:0] tx_data,
    output tx_finish,
    output tx_serial,
    output tx_active
    );
    
    localparam IDLE = 2'b00,
               START_BIT = 2'b01,
               DATA_BIT = 2'b10,
               STOP_BIT = 2'b11;   
               
    reg [7:0] data_reg; 
    reg [2:0] index;
    reg [8:0] clock_counter;
    reg [1:0] state;
    
    reg tx_finish_reg = 1'b0;
    reg tx_serial_reg = 1'b0;
    reg tx_active_reg = 1'b0;
    
    initial begin
        state = IDLE;
    end
    
    always @(posedge clk)begin
    case(state)
        IDLE : begin
            tx_serial_reg <= 1'b1;
            index <= 0;
            clock_counter <= 0;
            tx_active_reg <= 1'b0;
            tx_finish_reg <= 1'b0;
            
            if(tx_data_request ==  1'b1)begin
                tx_active_reg <= 1'b1;
                data_reg <= tx_data;
                state <= START_BIT;
            end
            else
                state <= IDLE;
        end
        
        START_BIT : begin
                tx_serial_reg <= 1'b0;
                            
                if(clock_counter < CLK_PER_BIT - 1)begin
                    clock_counter <= clock_counter + 1;
                    state <= START_BIT;
                end
                else begin
                     clock_counter <= 0;
                     state <= DATA_BIT;
                end
        end
        
        DATA_BIT : begin
            tx_serial_reg <= data_reg[index];
            
            if(clock_counter < CLK_PER_BIT - 1) begin
                clock_counter <= clock_counter + 1;
                state <= DATA_BIT;
            end
            else begin
                clock_counter <= 0;
              
                if(index < 7)begin
                    index <= index + 1;
                    state <= DATA_BIT;
                end
                else begin
                    index <= 0;
                    state <= STOP_BIT;
                end    
            end
        end
        
        STOP_BIT : begin
                tx_serial_reg <= 1'b1;
                if(clock_counter < CLK_PER_BIT - 1)begin
                    clock_counter <= clock_counter + 1;
                    state <= STOP_BIT;
                end
                else begin
                    clock_counter <= 0;
                    tx_finish_reg <= 1'b1;
                    tx_serial_reg <= 1'b1;
                    tx_active_reg <= 1'b0;
                    state <= IDLE;
                end
        end
    endcase
    $display("Time: %t, State: %b, clock_counter: %d, index: %d, tx_serial: %b", 
         $time, state, clock_counter, index, tx_serial_reg);
    end
    
    assign tx_finish = tx_finish_reg;
    assign tx_active = tx_active_reg;
    assign tx_serial = tx_serial_reg;
    
endmodule
