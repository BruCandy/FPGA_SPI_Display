module SPI_wrapper(
  input  wire   i_clk,
  input  wire   i_rst,
  output wire   o_mosi,
  output wire   o_cs,
  output wire   o_dc,
  output wire   o_rst,
  output wire   o_clk,
  output wire   o_led
);

  wire w_rst;
  reg [31:0] r_counter = 32'h00000000;
  reg r_clk = 1'b0;

  always @(posedge i_clk) begin
    if(r_counter == 32'd1350000) begin
      r_counter <= 32'h00000000;
      r_clk     <= ~r_clk;
    end else begin
      r_counter <= r_counter + 32'h00000001;
      r_clk     <= r_clk;
    end
  end

  assign w_rst = ~i_rst;
  assign o_clk = r_clk;

  SPI_top SPI(
    .i_clk  (r_clk),
    .i_rst  (w_rst),
    .o_mosi (o_mosi),
    .o_cs   (o_cs),
    .o_dc   (o_dc),
    .o_rst  (o_rst),
    .o_done(o_led)
  );

endmodule