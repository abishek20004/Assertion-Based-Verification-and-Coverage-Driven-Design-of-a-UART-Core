module uart_top #(
    parameter CLK_FREQ = 50000000,
    parameter BAUD_RATE = 115200
)(
    input  wire        clk,
    input  wire        rst_n,
    input  wire [7:0]  tx_data,
    input  wire        tx_start,
    output wire        tx_busy,
    output wire        tx_done,
    output wire [7:0]  rx_data,
    output wire        rx_done,
    output wire        rx_err,
    input  wire        uart_rx_pin,
    output wire        uart_tx_pin
);

    uart_tx #(.CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE)) tx_inst (
        .clk(clk), .rst_n(rst_n), .tx_data(tx_data), .tx_start(tx_start),
        .tx_serial(uart_tx_pin), .tx_busy(tx_busy), .tx_done(tx_done)
    );

    uart_rx #(.CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE)) rx_inst (
        .clk(clk), .rst_n(rst_n), .rx_serial(uart_rx_pin),
        .rx_data(rx_data), .rx_done(rx_done)
    );

    assign rx_err = 1'b0;
endmodule