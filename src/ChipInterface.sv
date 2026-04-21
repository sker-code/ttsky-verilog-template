
`default_nettype none
module ChipInterface
  (input  logic clk, rst_n,
   input  logic btn_up, btn_down, btn_left, btn_right,
   input  logic btn_bomb,
   input  logic btn_up1, btn_down1, btn_left1, btn_right1,
   input  logic btn_bomb1,
   output logic [1:0] red, green, blue, 
   output logic HS, VS);

  logic [9:0] row, col;
  logic blank;
  logic [10:0][14:0][2:0] map;
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
                 .btn_up(btn_up), .btn_down(btn_down), .btn_left(btn_left), .btn_right(btn_right),
                 .btn_bomb(btn_bomb),
                 .btn_up1(btn_up1), .btn_down1(btn_down1), .btn_left1(btn_left1), .btn_right1(btn_right1),
                 .btn_bomb1(btn_bomb1),
                 .map(map));

endmodule: ChipInterface

    