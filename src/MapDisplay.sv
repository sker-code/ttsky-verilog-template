`default_nettype none
module MapDisplay
  (input  logic [9:0] row, col,
   input  logic [6:0][8:0][2:0] map,
   output logic [1:0] red, green, blue);
  
  logic [2:0] map_value;
  logic [3:0] i, j;

  assign map_value = map[i][j];
  
  MapDisplayDecoder mapdecoder_m(.map_value(map_value), 
                                 .red(red), .green(green), .blue(blue));

  always_comb begin
    if      (row < 10'd68)  i = 4'd0; // row 0
    else if (row < 10'd136)  i = 4'd1; // row 1
    else if (row < 10'd204) i = 4'd2; // row 2
    else if (row < 10'd272) i = 4'd3; // row 3
    else if (row < 10'd340) i = 4'd4; // row 4
    else if (row < 10'd408) i = 4'd5; // row 5
    else                    i = 4'd6; // row 6
    if      (col < 10'd68)  j = 4'd0; // col 0
    else if (col < 10'd136) j = 4'd1; // col 1
    else if (col < 10'd204) j = 4'd2; // col 2
    else if (col < 10'd272) j = 4'd3; // col 3
    else if (col < 10'd340) j = 4'd4; // col 4
    else if (col < 10'd408) j = 4'd5; // col 5
    else if (col < 10'd476) j = 4'd6; // col 6
    else if (col < 10'd544) j = 4'd7; // col 7
    else                    j = 4'd8; // col 8
  end
endmodule: MapDisplay