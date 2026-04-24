module uart_rx #(
    parameter CLK_FREQ = 50000000,
    parameter BAUD_RATE = 115200
)(
    input  wire       clk,
    input  wire       rst_n,
    input  wire       rx_serial,
    output reg [7:0]  rx_data,
    output reg        rx_done
);
    localparam BIT_PERIOD = CLK_FREQ / BAUD_RATE;
    localparam IDLE=0, START=1, DATA=2, STOP=3;

    reg [1:0]  state;
    reg [15:0] clk_count;
    reg [2:0]  bit_index;
    reg [7:0]  rx_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE; rx_done <= 0; rx_data <= 0; clk_count <= 0;
        end else begin
            rx_done <= 0;
            case (state)
                IDLE: if (!rx_serial) begin state <= START; clk_count <= 0; end
                
                START: // Center the sampling by waiting for half a bit period
                    if (clk_count < (BIT_PERIOD / 2) - 1) clk_count <= clk_count + 1;
                    else begin state <= DATA; clk_count <= 0; bit_index <= 0; end
                
                DATA: // Sample every full bit period (at the center)
                    if (clk_count < BIT_PERIOD - 1) clk_count <= clk_count + 1;
                    else begin
                        rx_reg[bit_index] <= rx_serial;
                        clk_count <= 0;
                        if (bit_index == 7) state <= STOP;
                        else bit_index <= bit_index + 1;
                    end
                
                STOP:
                    if (clk_count < BIT_PERIOD - 1) clk_count <= clk_count + 1;
                    else begin
                        rx_data <= rx_reg;
                        rx_done <= 1;
                        state <= IDLE;
                    end
                default: state <= IDLE;
            endcase
        end
    end
endmodule