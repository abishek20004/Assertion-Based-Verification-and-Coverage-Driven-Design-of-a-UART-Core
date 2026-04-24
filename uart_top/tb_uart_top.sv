module tb_uart_top;

    // Parameters
    parameter CLK_FREQ = 50000000;
    parameter BAUD_RATE = 115200;
    localparam CLK_PERIOD = 20; // 50MHz

    // Interface Signals
    logic clk;
    logic rst_n;
    logic [7:0] tx_data_in;
    logic tx_start;
    logic tx_busy;
    logic tx_done;
    logic [7:0] rx_data_out;
    logic rx_done;
    logic rx_err;
    wire  serial_line; // The loopback wire

    // Mailbox for Scoreboarding
    mailbox #(logic [7:0]) scb_mbx;

    // 1. Instantiate the "Clean" UART Top
    uart_top #(CLK_FREQ, BAUD_RATE) dut (
        .clk(clk),
        .rst_n(rst_n),
        .tx_data(tx_data_in),
        .tx_start(tx_start),
        .tx_busy(tx_busy),
        .tx_done(tx_done),
        .rx_data(rx_data_out),
        .rx_done(rx_done),
        .rx_err(rx_err),
        .uart_tx_pin(serial_line), // Connect TX to serial_line
        .uart_rx_pin(serial_line)  // Connect RX to serial_line (External Loopback)
    );

    // 2. Clock Generation
    always #(CLK_PERIOD/2) clk = ~clk;

    // 3. Functional Coverage (CDV)
    covergroup cg_uart_top @(posedge clk);
        option.per_instance = 1;
        
        // Coverage for the 100 random values
        cp_tx_data: coverpoint tx_data_in {
            bins low    = {[8'h00:8'h3F]};
            bins mid    = {[8'h40:8'hBF]};
            bins high   = {[8'hC0:8'hFF]};
            bins toggle = (8'hAA => 8'h55), (8'h55 => 8'hAA);
        }
        
        // Ensure we see simultaneous TX and RX activity
        cp_full_duplex: coverpoint (tx_busy && !rx_done) {
            bins active = {1};
        }
    endgroup

    // 4. Assertions (ABV)
    // Property: Data Integrity Check
    property p_data_match;
        logic [7:0] sent_val;
        (tx_start, sent_val = tx_data_in) |->  ##[1:200000] (rx_done && rx_data_out == sent_val);
    endproperty
    assert_data_match: assert property (@(posedge clk) p_data_match) 
        else $error("DATA MISMATCH: Sent %h, but RX received %h", tx_data_in, rx_data_out);

    // Property: No errors allowed during loopback
    assert_no_rx_err: assert property (@(posedge clk) rx_done |-> !rx_err);

    // 5. Stimulus & Verification Loop
    cg_uart_top cov_inst = new();
    
    initial begin
        // Initialization
        clk = 0;
        rst_n = 0;
        tx_start = 0;
        tx_data_in = 0;
        scb_mbx = new();
        
        repeat(5) @(posedge clk);
        rst_n = 1;
        repeat(5) @(posedge clk);

        $display("--- Starting 100 Random Transmissions ---");

        for (int i = 0; i < 100; i++) begin
            // Randomization
            std::randomize(tx_data_in);
            
            wait(!tx_busy);
            @(posedge clk);
            tx_start = 1;
            scb_mbx.put(tx_data_in); // Store for checking
            
            @(posedge clk);
            tx_start = 0;
            
            // Wait for reception to finish
            wait(rx_done);
            begin
                logic [7:0] exp_data;
                scb_mbx.get(exp_data);
                if (rx_data_out === exp_data)
                    $display("[%0d] Success: Data %h received correctly", i, rx_data_out);
                else
                    $display("[%0d] ERROR: Expected %h, Got %h", i, exp_data, rx_data_out);
            end
            
            repeat(10) @(posedge clk); // Gap between transfers
        end

        $display("Final Coverage: %.2f%%", cov_inst.get_inst_coverage());
        $finish;
    end

endmodule