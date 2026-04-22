`default_nettype none
module VGA
  (input  logic clk, rst_n,
   output logic HS, VS, blank,
   output logic [9:0] row, col);

  logic HS_blank, VS_blank;
  logic [9:0] HS_counter, VS_counter;

  assign blank = HS_blank | VS_blank;
  assign col = HS_counter - 10'd144;
  assign row = VS_counter - 10'd31;

  always_comb begin
    if (HS_counter < 10'd96) begin //96 (T_PW)
      HS = 1'b0;
      HS_blank = 1'b1;
    end
    else if (HS_counter < 10'd144) begin //96 + 48 = 144 (T_BP)
      HS = 1'b1;
      HS_blank = 1'b1;
    end
    else if (HS_counter < 10'd784) begin // 96 + 48 + 640 = 784 (T_DISP)
      HS = 1'b1;
      HS_blank = 1'b0;
    end
    else if (HS_counter < 10'd800) begin // 96 + 48 + 640 + 16 = 800 (T_FP)
      HS = 1'b1;
      HS_blank = 1'b1;
    end
    else begin
      HS = 1'b1;
      HS_blank = 1'b1;
    end
  end
  always_ff @(posedge clk) begin //HS
    if (~rst_n) begin
      HS_counter <= 10'd0;
    end
    else begin
      if (HS_counter < 10'd799) begin
        HS_counter <= HS_counter + 1;
      end
      else begin
        HS_counter <= 10'd0;
      end
    end
  end

  always_comb begin
    if (VS_counter < 10'd2) begin //2 (T_PW)
      VS = 1'b0;
      VS_blank = 1'b1;
    end
    else if (VS_counter < 10'd31) begin //2 + 29 = 31 (T_BP)
      VS = 1'b1;
      VS_blank = 1'b1;
    end
    else if (VS_counter < 10'd511) begin //2 + 29 + 480 = 511 (T_DISP)
      VS = 1'b1;
      VS_blank = 1'b0;
    end
    else if (VS_counter < 10'd521) begin //2 + 29 + 480 + 10 = 521 (T_FP)
      VS = 1'b1;
      VS_blank = 1'b1;
    end
    else begin
      VS = 1'b1;
      VS_blank = 1'b1;
    end
  end

  always_ff @(posedge clk) begin //VS
    if (~rst_n) begin
      VS_counter <= 10'b0;
    end
    else begin
      if (VS_counter < 10'd520) begin
        if (HS_counter >= 10'd799) begin
          VS_counter <= VS_counter + 1;
        end
      end
      else begin
        VS_counter <= 10'b0;
      end
    end
  end
endmodule : VGA