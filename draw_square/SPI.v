module SPI(
    input wire i_clk,
    input wire i_rst,
    output wire o_mosi,
    output wire o_cs,
    output wire o_dc,
    output wire o_rst,
    output wire o_clk,
    output wire o_led
);

    reg r_state = 0;
    reg r_init_start;
    reg r_done = 0;

    wire      w_init_done;

    parameter DELAY = 2_700_000; 

    assign o_led = i_rst;

    SPI_init # (
        .DELAY (DELAY)
    )spi_init(
        .i_rst      (i_rst),
        .i_clk      (i_clk),
        .i_start    (r_init_start),
        .o_mosi     (o_mosi),
        .o_dc       (o_dc),
        .o_cs       (o_cs),
        .o_done     (w_init_done)
    );

    assign w_rst = ~i_rst;
    assign o_rst = w_rst;
    assign o_clk = i_clk;

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_state <= 0;
            r_init_start <= 1;
        end else begin
            case (r_state)
                0: begin // 初期設定
                    r_init_start <= 0;
                    if (w_init_done) begin
                        r_state <= 1;
                    end
                end
                1: begin // 終了
                    // もう一度実行する場合はresetボタンを押す。
                end
            endcase
        end
    end

endmodule