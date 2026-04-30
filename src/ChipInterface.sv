`default_nettype none

// Chip Interface
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
  logic [4:0][6:0][1:0] curr_map;
  logic refresh;
  logic pl1_win, pl2_win;
  logic [2:0] pl1_x, pl1_y;
  logic [2:0] pl2_x, pl2_y;
  logic [2:0] bomb1_x, bomb1_y;
  logic [2:0] bomb2_x, bomb2_y;
  logic bomb1_ticking, bomb2_ticking;

  assign refresh = (row == 10'd479 && col == 10'd639);

  VGA vga_m(.clk(clk), .rst_n(rst_n),
            .HS(HS), .VS(VS), .blank(blank),
            .row(row), .col(col));
  
  Display display_m(.row(row), .col(col),
                    .blank(blank),
                    .curr_map(curr_map),
                    .pl1_win(pl1_win), .pl2_win(pl2_win),
                    .pl1_x(pl1_x), .pl1_y(pl1_y),
                    .pl2_x(pl2_x), .pl2_y(pl2_y),
                    .red(red), .green(green), .blue(blue),
                    .bomb1_x(bomb1_x), .bomb1_y(bomb1_y),
                    .bomb2_x(bomb2_x), .bomb2_y(bomb2_y),
                    .bomb1_ticking(bomb1_ticking), .bomb2_ticking(bomb2_ticking));

  Bomberman game(.clk(clk), .rst_n(rst_n), .refresh(refresh),
                 .btn_up1(btn_up1), .btn_down1(btn_down1), .btn_left1(btn_left1), .btn_right1(btn_right1),
                 .btn_bomb1(btn_bomb1),
                 .btn_up2(btn_up2), .btn_down2(btn_down2), .btn_left2(btn_left2), .btn_right2(btn_right2),
                 .btn_bomb2(btn_bomb2),
                 .curr_map(curr_map),
                 .pl1_win(pl1_win), .pl2_win(pl2_win),
                 .pl1_x(pl1_x), .pl1_y(pl1_y),
                 .pl2_x(pl2_x), .pl2_y(pl2_y),
                 .bomb1_x(bomb1_x), .bomb1_y(bomb1_y),
                 .bomb2_x(bomb2_x), .bomb2_y(bomb2_y),
                 .bomb1_ticking(bomb1_ticking), .bomb2_ticking(bomb2_ticking));
endmodule: ChipInterface
