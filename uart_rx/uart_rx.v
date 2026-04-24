module uart_rx #(
    parameter CLK_FREQ  = 50000000,
    parameter BAUD_RATE = 9600
)(
    input  wire       clk,
    input  wire       rst_n,
    input  wire       rx_serial,
    output reg [7:0]  rx_data,
    output reg        rx_done
);
    localparam BIT_PERIOD = CLK_FREQ / BAUD_RATE; // Matches TX bit timing [cite: 15]
    localparam IDLE=0, START=1, DATA=2, PARITY=3, STOP=4;

    reg [2:0]  state;
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
                START: if (clk_count < (BIT_PERIOD + BIT_PERIOD/2) - 1) clk_count <= clk_count + 1;
                       else begin state <= DATA; clk_count <= 0; bit_index <= 0; end
                DATA: if (clk_count < BIT_PERIOD - 1) clk_count <= clk_count + 1;
                      else begin
                          rx_reg[bit_index] <= rx_serial;
                          clk_count <= 0;
                          if (bit_index == 7) state <= PARITY;
                          else bit_index <= bit_index + 1;
                      end
                PARITY: if (clk_count < BIT_PERIOD - 1) clk_count <= clk_count + 1;
                        else begin state <= STOP; clk_count <= 0; end
                STOP: if (clk_count < BIT_PERIOD - 1) clk_count <= clk_count + 1;
                      else begin state <= IDLE; rx_done <= 1; rx_data <= rx_reg; end
                default: state <= IDLE;
            endcase
        end
    end
endmodule
