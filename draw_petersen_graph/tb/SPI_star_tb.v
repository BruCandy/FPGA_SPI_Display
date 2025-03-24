module SPI_star_tb();
    reg i_clk = 1'b1;
    reg i_rst = 0;
    reg i_start = 0;
    wire o_mosi;
    wire o_dc;
    wire o_cs;
    wire o_done;


    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, SPI_star_tb);
    end

    SPI_star # (
        .DELAY (20),
        .X1    (12),
        .Y1    (9 ),    
        .X2    (18),
        .Y2    (13),
        .X3    (16),
        .Y3    (20),
        .X4    (8 ),       
        .Y4    (20),
        .X5    (6 ),       
        .Y5    (13)
    ) spi_star(
        .i_rst      (i_rst),
        .i_clk      (i_clk),
        .i_start    (i_start),
        .o_mosi     (o_mosi),
        .o_dc       (o_dc),
        .o_cs       (o_cs),
        .o_done     (o_done)
    );

    always #10 begin
        i_clk <= ~i_clk;
    end

    initial begin
        i_rst <= 1'b1; #10;
        i_rst <= 1'b0; #30;

        i_start <= 1; #10;
        i_start <= 0; #10;
        
        // wait (o_done == 1'b1);        
        #1000000;
        $finish;
    end
endmodule