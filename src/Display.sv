`default_nettype none
module Display
  (input  logic [9:0] row, col,
   input  logic blank,
   input  logic [4:0][6:0][1:0] curr_map,
   input  logic pl1_win, pl2_win, 
   input  logic [2:0] pl1_x, pl1_y,
   input  logic [2:0] pl2_x, pl2_y,
   input  logic [2:0] bomb1_x, bomb1_y,
   input  logic [2:0] bomb2_x, bomb2_y,
   input  logic bomb1_ticking, bomb2_ticking,
   output logic [1:0] red, green, blue);
  
  logic border;
  logic [1:0] map_red, map_green, map_blue;

  MapDisplay mapdisplay_m(.row(row), .col(col),
                          .curr_map(curr_map),
                          .pl1_x(pl1_x), .pl1_y(pl1_y),
                          .pl2_x(pl2_x), .pl2_y(pl2_y),
                          .bomb1_x(bomb1_x), .bomb1_y(bomb1_y),
                          .bomb2_x(bomb2_x), .bomb2_y(bomb2_y),
                          .bomb1_ticking(bomb1_ticking), .bomb2_ticking(bomb2_ticking),
                          .border(border),
                          .red(map_red), .green(map_green), .blue(map_blue));
  
  always_comb begin
    if (blank) begin
      {red, green, blue} = '0;
    end
    else if (border) begin
      {red, green, blue} = {2'd1, 2'd1, 2'd1}; // unbreakable blocks for border
    end
    else if (pl1_win & pl2_win) begin
      {red, green, blue} = {2'd2, 2'd2, 2'd3}; // tie
    end
    else if (pl1_win) begin
      {red, green, blue} = {2'd3, 2'd2, 2'd3};
    end
    else if (pl2_win) begin
      {red, green, blue} = {2'd0, 2'd3, 2'd3};
    end
    else begin
      {red, green, blue} = {map_red, map_green, map_blue};
    end
  end
endmodule: Display
