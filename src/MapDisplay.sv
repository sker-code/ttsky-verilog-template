`default_nettype none
module MapDisplay
  (input  logic [9:0] row, col,
   input  logic [10:0][14:0][2:0] map,
   output logic [1:0] red, green, blue);
  
  logic [2:0] map_value;
  logic [3:0] i, j;

  assign map_value = map[i][j];
  
  MapDisplayDecoder mapdecoder_m(.map_value(map_value), 
                                 .red(red), .green(green), .blue(blue));

  always_comb begin
    if      (row < 10'd40)  i = 4'd0; // row 0
    else if (row < 10'd80)  i = 4'd1; // row 1
    else if (row < 10'd120) i = 4'd2; // row 2
    else if (row < 10'd160) i = 4'd3; // row 3
    else if (row < 10'd200) i = 4'd4; // row 4
    else if (row < 10'd240) i = 4'd5; // row 5
    else if (row < 10'd280) i = 4'd6; // row 6
    else if (row < 10'd320) i = 4'd7; // row 7
    else if (row < 10'd360) i = 4'd8; // row 8
    else if (row < 10'd400) i = 4'd9; // row 9
    else                    i = 4'd10; // row 10
    if      (col < 10'd40)  j = 4'd0; // col 0
    else if (col < 10'd80)  j = 4'd1; // col 1
    else if (col < 10'd120) j = 4'd2; // col 2
    else if (col < 10'd160) j = 4'd3; // col 3
    else if (col < 10'd200) j = 4'd4; // col 4
    else if (col < 10'd240) j = 4'd5; // col 5
    else if (col < 10'd280) j = 4'd6; // col 6
    else if (col < 10'd320) j = 4'd7; // col 7
    else if (col < 10'd360) j = 4'd8; // col 8
    else if (col < 10'd400) j = 4'd9; // col 9
    else if (col < 10'd440) j = 4'd10; // col 10
    else if (col < 10'd480) j = 4'd11; // col 11
    else if (col < 10'd520) j = 4'd12; // col 12
    else if (col < 10'd560) j = 4'd13; // col 13
    else                    j = 4'd14; // col 14
  end
endmodule: MapDisplay