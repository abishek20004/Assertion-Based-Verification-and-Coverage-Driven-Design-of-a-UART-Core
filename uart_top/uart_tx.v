module uart_tx #(
    parameter CLK_FREQ = 50000000,
    parameter BAUD_RATE = 115200
)(
    input  wire       clk,
    input  wire       rst_n,
    input  wire [7:0] tx_data,
    input  wire       tx_start,
    output reg        tx_serial,
    output reg        tx_busy,
    output reg        tx_done
);
    localparam BIT_PERIOD = CLK_FREQ / BAUD_RATE;
    localparam IDLE=0, START=1, DATA=2, PARITY=3, STOP=4;

    reg [2:0]  state;
    reg [15:0] clk_count;
    reg [2:0]  bit_index;
    reg [7:0]  tx_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE; tx_serial <= 1'b1; tx_busy <= 0; tx_done <= 0;
        end else begin
            tx_done <= 0;
            case (state)
                IDLE: begin
                    tx_serial <= 1'b1;
                    if (tx_start) begin
                        tx_reg <= tx_data;
                        tx_busy <= 1'b1;
                        state <= START;
                        clk_count <= 0;
                    end
                end
                START: begin
                    tx_serial <= 1'b0;
                    if (clk_count < BIT_PERIOD - 1) clk_count <= clk_count + 1;
                    else begin clk_count <= 0; state <= DATA; bit_index <= 0; end
                end
                DATA: begin
                    tx_serial <= tx_reg[bit_index];
                    if (clk_count < BIT_PERIOD - 1) clk_count <= clk_count + 1;
                    else begin
                        clk_count <= 0;
                        if (bit_index == 7) state <= STOP;
                        else bit_index <= bit_index + 1;
                    end
                end
                STOP: begin
                    tx_serial <= 1'b1;
                    if (clk_count < BIT_PERIOD - 1) clk_count <= clk_count + 1;
                    else begin tx_busy <= 0; tx_done <= 1; state <= IDLE; end
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule