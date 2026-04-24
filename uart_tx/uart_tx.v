module uart_tx #(
    parameter CLK_FREQ = 50000000, // 50MHz
    parameter BAUD_RATE = 9600
)(
    input wire clk,
    input wire rst_n,
    input wire [7:0] tx_data,
    input wire tx_start,
    output reg tx_serial,
    output reg tx_busy,
    output reg tx_done
);

    // State Encoding
    localparam IDLE   = 3'd0,
               START  = 3'd1,
               DATA   = 3'd2,
               PARITY = 3'd3,
               STOP   = 3'd4;

    localparam BIT_PERIOD = CLK_FREQ / BAUD_RATE;

    reg [2:0] state;
    reg [15:0] clk_count;
    reg [2:0] bit_index;
    reg [7:0] data_reg;
    reg parity_bit;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            tx_serial <= 1'b1; // UART idle high
            tx_busy <= 1'b0;
            tx_done <= 1'b0;
            clk_count <= 0;
        end else begin
            case (state)
                IDLE: begin
                    tx_done <= 1'b0;
                    tx_serial <= 1'b1;
                    if (tx_start) begin
                        data_reg <= tx_data;
                        parity_bit <= ^tx_data; // XOR reduction for even parity
                        tx_busy <= 1'b1;
                        state <= START;
                        clk_count <= 0;
                    end else begin
                        tx_busy <= 1'b0;
                    end
                end

                START: begin
                    tx_serial <= 1'b0; // Start bit
                    if (clk_count < BIT_PERIOD - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        state <= DATA;
                        bit_index <= 0;
                    end
                end

                DATA: begin
                    tx_serial <= data_reg[bit_index];
                    if (clk_count < BIT_PERIOD - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        if (bit_index < 7) begin
                            bit_index <= bit_index + 1;
                        end else begin
                            state <= PARITY;
                        end
                    end
                end

                PARITY: begin
                    tx_serial <= parity_bit;
                    if (clk_count < BIT_PERIOD - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        state <= STOP;
                    end
                end

                STOP: begin
                    tx_serial <= 1'b1; // Stop bit
                    if (clk_count < BIT_PERIOD - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        tx_done <= 1'b1;
                        tx_busy <= 1'b0;
                        state <= IDLE;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end
endmodule
