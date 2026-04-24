module uart_tx_tb;

    parameter CLK_FREQ = 50000000;
    parameter BAUD_RATE = 9600;

    logic clk = 0;
    logic rst_n;
    logic [7:0] tx_data; // Fixed typo here
    logic tx_start;
    logic tx_serial;
    logic tx_busy;
    logic tx_done;

    // Instantiate DUT
    uart_tx #(CLK_FREQ, BAUD_RATE) dut (.*);

    // Clock Generation
    always #10 clk = ~clk; 

    // Randomization Class
    class uart_packet;
        rand bit [7:0] data;
    endclass

    // Functional Coverage
    covergroup cg_uart @(posedge tx_done);
        option.per_instance = 1;
        cp_data: coverpoint tx_data {
            bins zeros = {8'h00};
            bins ones  = {8'hFF};
            bins alternating = {8'hAA, 8'h55};
            bins misc = {[8'h01:8'hFE]};
        }
    endgroup

    cg_uart cov_inst = new();

    // Assertions
    property p_tx_busy;
        @(posedge clk) tx_start |=> tx_busy;
    endproperty
    assert property (p_tx_busy);

    property p_tx_done_pulse;
        @(posedge clk) tx_done |=> !tx_done;
    endproperty
    assert property (p_tx_done_pulse);

    // Stimulus
    initial begin
        uart_packet pkt = new();
        rst_n = 0;
        tx_start = 0;
        tx_data = 0;
        #100 rst_n = 1;
        
        // Increased iterations to hit 100% functional coverage
        repeat (100) begin
            wait(!tx_busy);
            
            // Explicitly cast to void to avoid warning/error in 10.7
            void'(pkt.randomize());
            
            @(posedge clk);
            tx_data = pkt.data;
            tx_start = 1;
            
            @(posedge clk);
            tx_start = 0;
            
            // Wait for completion (crucial for protocol timing)
            wait(tx_done);
            #500; 
        end

        $display("[TB] Final Coverage: %.2f%%", cov_inst.get_inst_coverage());
        $finish;
    end

endmodule