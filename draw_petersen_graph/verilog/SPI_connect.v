module SPI_connect(
    input wire i_rst,
    input wire i_clk,
    input wire i_start,
    output wire o_mosi,
    output wire o_dc,
    output wire o_cs,
    output wire o_done
);

    parameter DELAY  = 2_700_000; 

    
    parameter X1 = 120;
    parameter Y1 = 46;
    parameter X1_2 = 120;
    parameter Y1_2 = 90;

    parameter X2 = 225;
    parameter Y2 = 122;
    parameter X2_2 = 177;
    parameter Y2_2 = 131;

    parameter X3 = 185;
    parameter Y3 = 245;
    parameter X3_2 = 155;
    parameter Y3_2 = 198;

    parameter X4 = 55;
    parameter Y4 = 245;
    parameter X4_2 = 84;
    parameter Y4_2 = 198;

    parameter X5 = 15;
    parameter Y5 = 122;
    parameter X5_2 = 62;
    parameter Y5_2 = 131;

    reg [2:0] r_state = 0;
    reg       r_line_start = 0;
    reg       r_line2_start = 0;
    reg       r_vertical_start = 0;
    reg r_done = 0;
    reg [8:0] r_x1;
    reg [8:0] r_y1;
    reg [8:0] r_x2;
    reg [8:0] r_y2;
    reg [8:0] r_x1_2;
    reg [8:0] r_y1_2;
    reg [8:0] r_x2_2;
    reg [8:0] r_y2_2;
    reg [8:0] r_x1_3;
    reg [8:0] r_y1_3;
    reg [8:0] r_x2_3;
    reg [8:0] r_y2_3;

    wire w_line_done;
    wire w_line_mosi;
    wire w_line_dc;
    wire w_line_cs;
    wire w_line2_done;
    wire w_line2_mosi;
    wire w_line2_dc;
    wire w_line2_cs;
    wire w_vertical_done;
    wire w_vertical_mosi;
    wire w_vertical_dc;
    wire w_vertical_cs;


    assign o_mosi = (r_state == 1) ? w_vertical_mosi :
                    (r_state == 2  || r_state == 5) ? w_line_mosi :
                    (r_state == 3 || r_state == 4) ? w_line2_mosi : 0; 
    assign o_dc =   (r_state == 1) ? w_vertical_dc :
                    (r_state == 2 || r_state == 5) ? w_line_dc :
                    (r_state == 3 || r_state == 4) ? w_line2_dc : 0; 
    assign o_cs =   (r_state == 1) ? w_vertical_cs :
                    (r_state == 2 || r_state == 5) ? w_line_cs :
                    (r_state == 3 || r_state == 4) ? w_line2_cs : 1; 
    assign o_done = r_done;

    SPI_vertical # (
        .DELAY (DELAY)
    ) spi_vertical (
        .i_rst      (i_rst),
        .i_clk      (i_clk),
        .i_start    (r_vertical_start),
        .i_x        (r_x1_3),
        .i_y1       (r_y1_3),
        .i_y2       (r_y2_3),
        .o_mosi     (w_vertical_mosi),
        .o_dc       (w_vertical_dc),
        .o_cs       (w_vertical_cs),
        .o_done     (w_vertical_done)
    );

    SPI_line # (
        .DELAY (DELAY)
    ) spi_line (
        .i_rst      (i_rst),
        .i_clk      (i_clk),
        .i_start    (r_line_start),
        .i_x1 (r_x1),
        .i_x2 (r_x2),
        .i_y1 (r_y1),
        .i_y2 (r_y2),
        .o_mosi     (w_line_mosi),
        .o_dc       (w_line_dc),
        .o_cs       (w_line_cs),
        .o_done     (w_line_done)
    );

    SPI_line2 # (
        .DELAY (DELAY)
    ) spi_line2 (
        .i_rst      (i_rst),
        .i_clk      (i_clk),
        .i_start    (r_line2_start),
        .i_x1 (r_x1_2),
        .i_x2 (r_x2_2),
        .i_y1 (r_y1_2),
        .i_y2 (r_y2_2),
        .o_mosi     (w_line2_mosi),
        .o_dc       (w_line2_dc),
        .o_cs       (w_line2_cs),
        .o_done     (w_line2_done)
    );

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_state <= 0;
            r_line_start <= 0;
            r_vertical_start <= 0;
            r_done <= 0;
            r_x1 <= X1;
            r_y1 <= Y1;
            r_x2 <= X2;
            r_y2 <= Y2;
            r_x1_2 <= X1;
            r_y1_2 <= Y1;
            r_x2_2 <= X2;
            r_y2_2 <= Y2;
        end else begin
            case (r_state)
                0: begin // 初期状態と(120,46)-(225,122)の準備
                    r_done <= 0;
                    r_x1 <= X1;
                    r_y1 <= Y1;
                    r_x2 <= X2;
                    r_y2 <= Y2;
                    if (i_start) begin
                        r_state <= 1;
                        r_vertical_start <= 1;
                        r_x1_3 <= X1;
                        r_y1_3 <= Y1;
                        r_y2_3 <= Y1_2;
                    end
                end
                1: begin // (120,46)-(225,122)の送信と(225,122)-(185,245)の準備
                    r_vertical_start <= 0;
                    if (w_vertical_done) begin
                        r_state <= 2;
                        r_line_start <= 1;
                        r_x1 <= X2_2;
                        r_y1 <= Y2_2;
                        r_x2 <= X2;
                        r_y2 <= Y2;
                    end 
                end
                2: begin // (225,122)-(185,245)の送信と(185,245)-(55,245)の準備
                    r_line_start <= 0;
                    if (w_line_done) begin
                        r_state <= 3;
                        r_line2_start <= 1;
                        r_x1_2 <= X3_2;
                        r_y1_2 <= Y3_2;
                        r_x2_2 <= X3;
                        r_y2_2 <= Y3;
                    end 
                end
                3: begin // (185,245)-(55,245)の送信と(55,245)-(15,122)の準備
                    r_line2_start <= 0;
                    if (w_line2_done) begin
                        r_state <= 4;
                        r_line2_start <= 1;
                        r_x1_2 <= X4_2;
                        r_y1_2 <= Y4_2;
                        r_x2_2 <= X4;
                        r_y2_2 <= Y4;
                    end 
                end
                4: begin // (55,245)-(15,122)の送信と(15,122)-(120,46)の準備
                    r_line2_start <= 0;
                    if (w_line2_done) begin
                        r_state <= 5;
                        r_line_start <= 1;
                        r_x1 <= X5;
                        r_y1 <= Y5;
                        r_x2 <= X5_2;
                        r_y2 <= Y5_2;
                    end 
                end
                5: begin // (15,122)-(120,90)の送信
                    r_line_start <= 0;
                    if (w_line_done) begin
                        r_state <= 0;
                        r_done <= 1;
                    end 
                end
            endcase
        end
    end

endmodule