`default_nettype none

module ChipInterface
  (input  logic clk, rst_n,
   input  logic btn_up1, btn_down1, btn_left1, btn_right1,
   input  logic btn_bomb1,
   input  logic btn_up2, btn_down2, btn_left2, btn_right2,
   input  logic btn_bomb2,
   output logic [1:0] red, green, blue, 
   output logic HS, VS);

  logic [9:0] row, col;
  logic blank;
  logic [4:0][6:0][2:0] map;
  logic refresh;

  VGA vga_m(.clk(clk), .rst_n(rst_n),
          .HS(HS), .VS(VS), .blank(blank),
          .row(row), .col(col));
  
  Display display_m(.row(row), .col(col),
                  .blank(blank),
                  .map(map),
                  .red(red), .green(green), .blue(blue));

  assign refresh = (row == 10'd479 && col == 10'd639);

  Bomberman game(.clk(clk), .rst_n(rst_n), .refresh(refresh),
                 .btn_up1(btn_up1), .btn_down1(btn_down1), .btn_left1(btn_left1), .btn_right1(btn_right1),
                 .btn_bomb1(btn_bomb1),
                 .btn_up2(btn_up2), .btn_down2(btn_down2), .btn_left2(btn_left2), .btn_right2(btn_right2),
                 .btn_bomb2(btn_bomb2),
                 .map(map));

endmodule: ChipInterface
