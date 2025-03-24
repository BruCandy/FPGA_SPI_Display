module SPI_top(
    input wire i_clk,
    input wire i_rst,
    output wire o_mosi,
    output wire o_cs,
    output wire o_dc,
    output wire o_rst,
    output wire o_clk
);

    parameter DELAY  = 2_700_000; 
    parameter WIDTH  = 240;
    parameter HEIGHT = 320;

    reg [2:0] r_state;
    reg       r_init_start = 0;
    reg       r_clear_start = 0;
    reg       r_pentagon_start = 0;
    reg       r_star_start = 0;
    reg       r_connect_start = 0;

    wire w_init_done;
    wire w_init_mosi;
    wire w_init_dc;
    wire w_init_cs;
    wire w_clear_done;
    wire w_clear_mosi;
    wire w_clear_dc;
    wire w_clear_cs;
    wire w_pentagon_done;
    wire w_pentagon_mosi;
    wire w_pentagon_dc;
    wire w_pentagon_cs;
    wire w_star_done;
    wire w_star_mosi;
    wire w_star_dc;
    wire w_star_cs;
    wire w_connect_done;
    wire w_connect_mosi;
    wire w_connect_dc;
    wire w_connect_cs;

    assign w_rst = ~i_rst;
    assign o_rst = i_rst;
    assign o_clk = i_clk;

    assign o_mosi = (r_state == 1) ? w_init_mosi :
                    (r_state == 2) ? w_clear_mosi :
                    (r_state == 3) ? w_pentagon_mosi :
                    (r_state == 4) ? w_star_mosi :
                    (r_state == 5) ? w_connect_mosi : 0; 
    assign o_dc =   (r_state == 1) ? w_init_dc :
                    (r_state == 2) ? w_clear_dc :
                    (r_state == 3) ? w_pentagon_dc : 
                    (r_state == 4) ? w_star_dc : 
                    (r_state == 5) ? w_connect_dc : 0; 
    assign o_cs =   (r_state == 1) ? w_init_cs :
                    (r_state == 2) ? w_clear_cs :
                    (r_state == 3) ? w_pentagon_cs :  
                    (r_state == 4) ? w_star_cs :  
                    (r_state == 5) ? w_connect_cs : 1; 

    SPI_init # (
        .DELAY (DELAY)
    )spi_init(
        .i_rst      (w_rst),
        .i_clk      (i_clk),
        .i_start    (r_init_start),
        .o_mosi     (w_init_mosi),
        .o_dc       (w_init_dc),
        .o_cs       (w_init_cs),
        .o_done     (w_init_done)
    );

    SPI_clear # (
        .DELAY  (DELAY),
        .WIDTH  (WIDTH),
        .HEIGHT (HEIGHT)
    ) spi_clear(
        .i_rst      (w_rst),
        .i_clk      (i_clk),
        .i_start    (r_clear_start),
        .o_mosi     (w_clear_mosi),
        .o_dc       (w_clear_dc),
        .o_cs       (w_clear_cs),
        .o_done     (w_clear_done)
    );

    SPI_pentagon # (
        .DELAY (DELAY)
    ) SPI_pentagon (
        .i_rst      (w_rst),
        .i_clk      (i_clk),
        .i_start    (r_pentagon_start),
        .o_mosi     (w_pentagon_mosi),
        .o_dc       (w_pentagon_dc),
        .o_cs       (w_pentagon_cs),
        .o_done     (w_pentagon_done)
    );

    SPI_star # (
        .DELAY (DELAY)
    ) SPI_star (
        .i_rst      (w_rst),
        .i_clk      (i_clk),
        .i_start    (r_star_start),
        .o_mosi     (w_star_mosi),
        .o_dc       (w_star_dc),
        .o_cs       (w_star_cs),
        .o_done     (w_star_done)
    );

    SPI_connect # (
        .DELAY (DELAY)
    ) SPI_connect (
        .i_rst      (w_rst),
        .i_clk      (i_clk),
        .i_start    (r_connect_start),
        .o_mosi     (w_connect_mosi),
        .o_dc       (w_connect_dc),
        .o_cs       (w_connect_cs),
        .o_done     (w_connect_done)
    );

    always @(posedge i_clk or posedge w_rst) begin
        if (w_rst) begin
            r_state <= 0;
            r_init_start <= 0;
            r_clear_start <= 0;
            r_pentagon_start <= 0;
            r_star_start <= 0;
            r_connect_start <= 0;
        end else begin
            case (r_state)
                0:begin
                    r_init_start <= 1;
                    r_state <= 1;
                end
                1: begin // 初期設定
                    r_init_start <= 0;
                    if (w_init_done) begin
                        r_state <= 2;
                        r_clear_start <= 1;
                    end
                end
                2: begin // CLEAR
                    r_clear_start <= 0;
                    if (w_clear_done) begin
                        r_state <= 3;
                        r_pentagon_start <= 1;
                    end 
                end
                3: begin // pentagon
                    r_pentagon_start <= 0;
                    if (w_pentagon_done) begin
                        r_state <= 4;
                        r_star_start <= 1;
                    end 
                end
                4: begin // pentagon
                    r_star_start <= 0;
                    if (w_star_done) begin
                        r_state <= 5;
                        r_connect_start <= 1;
                    end 
                end
                5: begin // pentagon
                    r_connect_start <= 0;
                    if (w_connect_done) begin
                        r_state <= 6;
                    end 
                end
                6: begin //FIN
                    // もう一度実行する場合はリセットボタンを押す
                end
            endcase
        end
    end

endmodule