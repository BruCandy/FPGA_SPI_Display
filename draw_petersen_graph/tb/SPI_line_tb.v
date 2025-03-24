module SPI_line_tb();
    reg i_clk = 1'b1;
    reg i_rst = 0;
    reg i_start = 0;
    wire o_mosi;
    wire o_dc;
    wire o_cs;
    wire o_done;


    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, SPI_line_tb);
    end

    SPI_line # (
        .DELAY  (20)
    ) spi_line(
        .i_rst      (i_rst),
        .i_clk      (i_clk),
        .i_start    (i_start),
        .i_x1 (9'd15),
        .i_x2 (9'd120),
        .i_y1 (9'd122),
        .i_y2 (9'd46),
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
        
        wait (o_done == 1'b1);   

        // #10000000;

        // i_rst <= 1'b1; #10;
        // i_rst <= 1'b0; #30;

        // i_start <= 1; #10;
        // i_start <= 0; #10;
        
        // wait (o_done == 1'b1);  

        #100000;


        $finish;
    end
endmodule