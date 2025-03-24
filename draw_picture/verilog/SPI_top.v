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
    parameter X1     = 70;
    parameter X2     = 170;
    parameter Y1     = 110;
    parameter Y2     = 210;

    reg [1:0] r_state = 0;
    reg       r_init_start = 0;
    reg       r_clear_start = 0;
    reg       r_square_start = 0;

    wire w_init_done;
    wire w_init_mosi;
    wire w_init_dc;
    wire w_init_cs;
    wire w_clear_done;
    wire w_clear_mosi;
    wire w_clear_dc;
    wire w_clear_cs;
    wire w_square_done;
    wire w_square_mosi;
    wire w_square_dc;
    wire w_square_cs;

    assign w_rst = ~i_rst;
    assign o_rst = i_rst;
    assign o_clk = i_clk;

    assign o_mosi = (r_state == 0) ? w_init_mosi :
                    (r_state == 1) ? w_clear_mosi :
                    (r_state == 2) ? w_square_mosi : 0; 
    assign o_dc =   (r_state == 0) ? w_init_dc :
                    (r_state == 1) ? w_clear_dc :
                    (r_state == 2) ? w_square_dc : 0; 
    assign o_cs =   (r_state == 0) ? w_init_cs :
                    (r_state == 1) ? w_clear_cs :
                    (r_state == 2) ? w_square_cs : 1; 

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

    SPI_square # (
        .DELAY (DELAY),
        .X1    (X1   ),
        .X2    (X2   ),
        .Y1    (Y1   ),
        .Y2    (Y2   ) 
    ) spi_square (
        .i_rst      (w_rst),
        .i_clk      (i_clk),
        .i_start    (r_square_start),
        .o_mosi     (w_square_mosi),
        .o_dc       (w_square_dc),
        .o_cs       (w_square_cs),
        .o_done     (w_square_done)
    );

    always @(posedge i_clk or posedge w_rst) begin
        if (w_rst) begin
            r_state <= 0;
            r_init_start <= 1;
        end else begin
            case (r_state)
                0: begin // 初期設定
                    r_init_start <= 0;
                    if (w_init_done) begin
                        r_state <= 1;
                        r_clear_start <= 1;
                    end
                end
                1: begin // CLEAR
                    r_clear_start <= 0;
                    if (w_clear_done) begin
                        r_state <= 2;
                        r_square_start <= 1;
                    end 
                end
                2: begin // SQUARE
                    r_square_start <= 0;
                    if (w_square_done) begin
                        r_state <= 3;
                    end 
                end
                3: begin //FIN
                    // もう一度実行する場合はリセットボタンを押す
                end
            endcase
        end
    end

endmodule