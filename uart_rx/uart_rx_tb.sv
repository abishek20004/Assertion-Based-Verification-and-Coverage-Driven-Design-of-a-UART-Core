`timescale 1ns / 1ps
module uart_rx_tb;
    parameter CLK_FREQ = 50000000, BAUD_RATE = 9600;
    localparam BIT_PERIOD_NS = 1000000000 / BAUD_RATE;

    logic clk = 0, rst_n, rx_serial = 1;
    wire [7:0] rx_data;
    wire rx_done;

    uart_rx #(CLK_FREQ, BAUD_RATE) dut (.*);
    always #10 clk = ~clk; // 50MHz [cite: 142]

    // 1. RANDOMIZATION (Matches TX class )
    class uart_packet;
        rand bit [7:0] data;
    endclass

    // 2. FUNCTIONAL COVERAGE (Matches TX bins [cite: 150])
    covergroup cg_uart @(posedge rx_done);
        cp_data: coverpoint rx_data {
            bins zeros = {8'h00};
            bins ones  = {8'hFF};
            bins alternating = {8'hAA, 8'h55};
            bins misc  = {[8'h01:8'hFE]};
        }
    endgroup

    // 3. ASSERTIONS (Matches TX logic [cite: 166])
    property p_rx_done_pulse;
        @(posedge clk) rx_done |=> !rx_done;
    endproperty
    assert property (p_rx_done_pulse);

    task send_byte(input [7:0] d);
        rx_serial = 0; #(BIT_PERIOD_NS); // Start
        for(int i=0; i<8; i++) begin rx_serial = d[i]; #(BIT_PERIOD_NS); end
        rx_serial = ^d; #(BIT_PERIOD_NS); // Parity bit
        rx_serial = 1;  #(BIT_PERIOD_NS); // Stop
    endtask

    initial begin
        uart_packet pkt = new();
        cg_uart cov_inst = new();
        rst_n = 0; #100 rst_n = 1; #100;

        repeat (100) begin
            pkt.randomize();
            $display("[TB] Sending: 0x%h", pkt.data);
            send_byte(pkt.data);
            wait(rx_done);
            #200;
        end
        $display("[TB] Coverage Score: %.2f%%", cov_inst.get_inst_coverage());
        $finish;
    end
endmodule