module SPI_top_tb();
    reg i_clk = 1'b1;
    reg i_rst = 0;
    wire o_mosi;
    wire o_dc;
    wire o_cs;
    wire o_rst;
    wire o_clk;
    wire o_led;


    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, SPI_top_tb);
    end

    SPI_top # (
        .DELAY (20),
        .WIDTH (24),
        .HEIGHT(32)
    ) spi_top (
        .i_clk  (i_clk  ),
        .i_rst  (i_rst  ),
        .o_mosi (o_mosi ),
        .o_cs   (o_cs   ),
        .o_dc   (o_dc   ),
        .o_rst  (o_rst  ),
        .o_clk  (o_clk  ),
        .o_led  (o_led  )
    );

    always #10 begin
        i_clk <= ~i_clk;
    end

    initial begin
        #10000;
        i_rst <= 1'b1; #10;
        i_rst <= 1'b0; #10;
         
        #1000000;

        i_rst <= 1'b1; #10;
        i_rst <= 1'b0; #10;
         
        #1000000;

        $finish;
    end
endmodule