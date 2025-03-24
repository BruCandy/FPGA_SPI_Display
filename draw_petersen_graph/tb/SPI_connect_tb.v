module SPI_connect_tb();
    reg i_clk = 1'b1;
    reg i_rst = 0;
    reg i_start = 0;
    wire o_mosi;
    wire o_dc;
    wire o_cs;
    wire o_done;


    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, SPI_connect_tb);
    end

    SPI_connect # (
        .DELAY (20),
        .X1    (12),
        .Y1    (5 ), 
        .X1_2  (12),
        .Y1_2  (9 ),   
        .X2    (23),
        .Y2    (12),
        .X2_2  (18),
        .Y2_2  (13),  
        .X3    (19),
        .Y3    (25),
        .X3_2  (16),
        .Y3_2  (20),  
        .X4    (6 ),       
        .Y4    (25),
        .X4_2  (8 ),
        .Y4_2  (20),  
        .X5    (2 ),       
        .Y5    (12),
        .X5_2  (6 ),
        .Y5_2  (13)  
    ) spi_connect(
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