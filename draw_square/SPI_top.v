module SPI_top(
    input wire i_clk,
    input wire i_rst,
    output wire o_mosi,
    output wire o_cs,
    output wire o_dc,
    output wire o_rst,
    output wire o_clk,
    output wire o_led
);

    parameter DELAY = 2_700_000; 
    parameter WIDTH = 240;
    parameter HEIGHT = 320;

    reg [1:0] r_state = 0;
    reg       r_init_start = 0;
    reg       r_clear_start = 0;

    wire w_init_done;
    wire w_init_mosi;
    wire w_init_dc;
    wire w_init_cs;
    wire w_clear_done;
    wire w_clear_mosi;
    wire w_clear_dc;
    wire w_clear_cs;

    assign o_led = i_rst;
    assign w_rst = ~i_rst;
    assign o_rst = i_rst;
    assign o_clk = i_clk;

    assign o_mosi = (r_state == 0) ? w_init_mosi :
                    (r_state == 1) ? w_clear_mosi : 0; 
    assign o_dc =   (r_state == 0) ? w_init_dc :
                    (r_state == 1) ? w_clear_dc : 0;
    assign o_cs =   (r_state == 0) ? w_init_cs :
                    (r_state == 1) ? w_clear_cs : 1; 

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
                    end 
                end
                2: begin //FIN
                    // もう一度実行する場合はリセットボタンを押す
                end
            endcase
        end
    end

endmodule