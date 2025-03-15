module SPI_clear (
    input wire i_rst,
    input wire i_clk,
    input wire i_start,
    output wire o_mosi,
    output wire o_dc,
    output wire o_cs,
    output wire o_done
);

    parameter WIDTH         = 240;
    parameter HEIGHT        = 320;
    parameter SET_COLUMN    = 8'h2A;
    parameter SET_PAGE      = 8'h2B;
    parameter WRITE_RAM     = 8'h2C;


    reg [3:0]  r_state   = 0;
    reg        r_we_cmd  = 0;
    reg        r_we_data = 0;
    reg [7:0]  r_cmd;
    reg [7:0]  r_data;
    reg        r_dc = 0;
    reg        r_done = 0;
    reg        r_need_delay = 0; 
    reg [8:0]  r_ycnt = 0;
    reg [11:0] r_rcnt = 0;
    reg        r_state_column = 0;
    reg        r_state_page = 0;
    reg        r_state_ram  = 0;

    wire w_done_cmd;
    wire w_done_data;
    wire o_cmd;
    wire o_data;
    wire o_cs_cmd;
    wire o_cs_data;

    parameter DELAY = 2_700_000; 


    SPI_cmd # (
        .DELAY (DELAY)
    ) spi_cmd (
        .i_rst          (i_rst       ),
        .i_clk          (i_clk       ),
        .i_cmd          (r_cmd       ),
        .i_we           (r_we_cmd    ),
        .i_need_delay   (r_need_delay),
        .o_cmd          (o_cmd       ),
        .o_cs           (o_cs_cmd    ),
        .o_done         (w_done_cmd  )
    );

    SPI_data_8 spi_data_8 (
        .i_rst          (i_rst      ),
        .i_clk          (i_clk      ),
        .i_data         (r_data     ),
        .i_we           (r_we_data  ),
        .o_data         (o_data     ),
        .o_cs           (o_cs_data  ),
        .o_done         (w_done_data)
    );

    assign o_dc = r_dc;
    assign o_done = r_done;
    assign o_mosi = r_dc ? o_data : o_cmd;
    assign o_cs   = r_dc ? o_cs_data : o_cs_cmd;

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_state   <= 0;
            r_done    <= 0;
            r_we_cmd  <= 0;
            r_we_data <= 0;
            r_need_delay <= 0;
        end else begin
                r_done    <= 0;
                if (r_ycnt == HEIGHT) begin
                    r_done <= 1;
                    r_ycnt <= 0;
                end else begin
                    case (r_state)
                        0: begin // 初期状態 & SWREST準備
                            r_we_cmd     <= 0;
                            r_we_data    <= 0;
                            r_need_delay <= 0;
                            r_done       <= 0;
                            if (i_start) begin
                                r_dc         <= 0;
                                r_we_cmd     <= 1;
                                r_we_data    <= 0;
                                r_cmd        <= SET_COLUMN;
                                r_state      <= 1;
                            end
                        end
                        1: begin // SET_COLMN_cmd送信中 & SET_COLMN_data準備
                            r_we_cmd    <= 0;
                            r_we_data   <= 0;
                            r_dc        <= 1;
                            case (r_state_column)
                                0: begin
                                    if (w_done_cmd) begin
                                        r_state_column <= 1;
                                    end
                                end
                                1: begin
                                    r_we_cmd        <= 0;
                                    r_we_data       <= 1;
                                    r_data          <= 8'h00;
                                    r_state_column  <= 2;
                                end
                                2: begin
                                    r_we_cmd  <= 0;
                                    r_we_data <= 0;
                                    if (w_done_data) begin
                                        r_we_cmd        <= 0;
                                        r_we_data       <= 1;
                                        r_data          <= 8'h00;
                                        r_state_column  <= 3;
                                    end
                                end
                                3: begin 
                                    r_we_cmd  <= 0;
                                    r_we_data <= 0;
                                    if (w_done_data) begin
                                        r_we_cmd        <= 0;
                                        r_we_data       <= 1;
                                        r_data          <= 8'h01;
                                        r_state_column  <= 4;
                                    end
                                end
                                4: begin
                                    r_we_cmd  <= 0;
                                    r_we_data <= 0;
                                    if (w_done_data) begin
                                        r_we_cmd        <= 0;
                                        r_we_data       <= 1;
                                        r_data          <= 8'h3F;
                                        r_state_column  <= 5;
                                    end
                                end
                                5: begin
                                    r_we_cmd    <= 0;
                                    r_we_data   <= 0;
                                    if (w_done_cmd) begin
                                        r_state_column <= 0;
                                        r_state <= 2;
                                    end
                                end
                            endcase
                        end
                        2: begin // SET_COLMN_data送信中 & SET_PAGE_cmd準備
                            r_we_cmd    <= 0;
                            r_we_data   <= 0;
                            if (w_done_cmd) begin
                                r_dc        <= 0;
                                r_we_cmd    <= 1;
                                r_we_data   <= 0;
                                r_cmd       <= SET_PAGE;
                                r_state     <= 3;
                            end
                        end
                        3: begin // SET_PAGE_cmd送信中 & SET_PAGE_data準備
                            r_we_cmd    <= 0;
                            r_we_data   <= 0;
                            r_dc        <= 1;
                            case (r_state_page)
                                0: begin
                                    if (w_done_cmd) begin
                                        r_state_page <= 1;
                                    end
                                end
                                1: begin
                                    r_we_cmd      <= 0;
                                    r_we_data     <= 1;
                                    r_data        <= r_ycnt >> 8;
                                    r_state_page  <= 2;
                                end
                                2: begin
                                    r_we_cmd  <= 0;
                                    r_we_data <= 0;
                                    if (w_done_data) begin
                                        r_we_cmd      <= 0;
                                        r_we_data     <= 1;
                                        r_data        <= r_ycnt & 8'hff;
                                        r_state_page  <= 3;
                                    end
                                end
                                3: begin 
                                    r_we_cmd  <= 0;
                                    r_we_data <= 0;
                                    if (w_done_data) begin
                                        r_we_cmd      <= 0;
                                        r_we_data     <= 1;
                                        r_data        <= (r_ycnt + 7) >> 8;
                                        r_state_page  <= 4;
                                    end
                                end
                                4: begin
                                    r_we_cmd  <= 0;
                                    r_we_data <= 0;
                                    if (w_done_data) begin
                                        r_we_cmd      <= 0;
                                        r_we_data     <= 1;
                                        r_data        <= (r_ycnt + 7) & 8'hff;
                                        r_state_page  <= 5;
                                    end
                                end
                                5: begin
                                    r_we_cmd    <= 0;
                                    r_we_data   <= 0;
                                    if (w_done_cmd) begin
                                        r_state_page <= 0;
                                        r_state <= 4;
                                    end
                                end
                        endcase
                    end
                    4: begin // SET_PAGE_data送信中 & WRITE_RAM_cmd準備
                        r_we_cmd    <= 0;
                        r_we_data   <= 0;
                        if (w_done_cmd) begin
                            r_dc        <= 0;
                            r_we_cmd    <= 1;
                            r_we_data   <= 0;
                            r_cmd       <= WRITE_RAM;
                            r_state     <= 5;
                        end
                    end
                    5: begin // WRITE_RAM_cmd送信中 & WRITE_RAM_data準備と送信
                        r_we_cmd    <= 0;
                        r_we_data   <= 0;
                        r_dc        <= 1;
                        if (r_rcnt == 3840 - 1) begin
                            if (w_done_data) begin
                                r_we_cmd    <= 0;
                                r_we_data   <= 0;
                                r_state     <= 6;
                            end
                        end else begin
                            if (w_done_data) begin
                                r_we_cmd      <= 0;
                                r_we_data     <= 1;
                                r_data        <= 8'b00000000;
                                r_state       <= 6;
                            end
                        end
                    end
                    6: begin // FIN
                        r_done  <= 1;
                        r_state <= 0;
                    end
                    endcase
                r_ycnt <= r_ycnt + 8;
                end
        end
    end

endmodule