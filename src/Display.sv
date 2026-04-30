`default_nettype none
/*
0: grass
1: breakable
2: unbreakable
3: fire
4: bomb
5: player1
6: player2
*/

// Determines the display values
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

// Gives details of map display from player logic
module MapDisplay
  (input  logic [9:0] row, col,
   input  logic [4:0][6:0][1:0] curr_map,
   input  logic [2:0] pl1_x, pl1_y,
   input  logic [2:0] pl2_x, pl2_y,
   input  logic [2:0] bomb1_x, bomb1_y,
   input  logic [2:0] bomb2_x, bomb2_y,
   input  logic bomb1_ticking, bomb2_ticking,
   output logic border,
   output logic [1:0] red, green, blue);
  
  logic [1:0] map_value;
  logic [2:0] i, j;
  logic row_border, col_border;
  logic pl1placement, pl2placement;
  logic bomb1placement, bomb2placement;

  assign pl1placement = (i == pl1_y) && (j == pl1_x);
  assign pl2placement = (i == pl2_y) && (j == pl2_x);
  assign bomb1placement = (bomb1_ticking && (i == bomb1_y) && (j == bomb1_x));
  assign bomb2placement = (bomb2_ticking && (i == bomb2_y) && (j == bomb2_x));
  assign map_value = curr_map[i][j];
  assign border = row_border | col_border;
  
  MapDisplayDecoder mapdecoder_m(.map_value(map_value), 
                                 .pl1placement(pl1placement), .pl2placement(pl2placement),
                                 .bomb1placement(bomb1placement), .bomb2placement(bomb2placement),
                                 .red(red), .green(green), .blue(blue));

  always_comb begin
    row_border = 1'd0;
    col_border = 1'd0;
    if      (row < 10'd68)  begin row_border = 1'd1;  i = 3'd0; end // border
    else if (row < 10'd136) i = 3'd0; // row 0
    else if (row < 10'd204) i = 3'd1; // row 1
    else if (row < 10'd272) i = 3'd2; // row 2
    else if (row < 10'd340) i = 3'd3; // row 3
    else if (row < 10'd408) i = 3'd4; // row 4
    else begin row_border = 1'd1; i = 3'd0; end // border

    if      (col < 10'd68)  begin col_border = 1'd1; j = 3'd0; end // border
    else if (col < 10'd136) j = 3'd0; // col 0
    else if (col < 10'd204) j = 3'd1; // col 1
    else if (col < 10'd272) j = 3'd2; // col 2
    else if (col < 10'd340) j = 3'd3; // col 3
    else if (col < 10'd408) j = 3'd4; // col 4
    else if (col < 10'd476) j = 3'd5; // col 5
    else if (col < 10'd544) j = 3'd6; // col 6
    else begin col_border = 1'd1; j = 3'd0; end // border
  end
endmodule: MapDisplay

// Gives rbg values based on map value
module MapDisplayDecoder
  (input  logic [1:0] map_value,
   input  logic pl1placement, pl2placement,
   input  logic bomb1placement, bomb2placement,
   output logic [1:0] red, green, blue);

  always_comb begin
    if (pl1placement) begin
      {red, green, blue} = {2'd3, 2'd2, 2'd3}; //player 1
    end
    else if (pl2placement) begin 
      {red, green, blue} = {2'd0, 2'd3, 2'd3}; // player 2
    end
    else if (bomb1placement | bomb2placement) begin
      {red, green, blue} = {2'd0, 2'd0, 2'd0}; // bomb
    end
    else if (map_value == 2'd0) begin 
      {red, green, blue} = {2'd0, 2'd2, 2'd0}; // grass
    end
    else if (map_value == 2'd1) begin 
      {red, green, blue} = {2'd2, 2'd2, 2'd2}; // breakable
    end
    else if (map_value == 2'd2) begin 
      {red, green, blue} = {2'd1, 2'd1, 2'd1}; // unbreakable
    end
    else if (map_value == 2'd3) begin 
      {red, green, blue} = {2'd3, 2'd1, 2'd0}; // fire
    end
    else begin 
      {red, green, blue} = {2'd0, 2'd0, 2'd0}; // invalid 
    end
  end
endmodule: MapDisplayDecoder