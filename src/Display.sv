`default_nettype none
module Display
  (input  logic [9:0] row, col,
   input  logic blank,
   input  logic [6:0][8:0][2:0] map,
   output logic [1:0] red, green, blue);
  
  logic [1:0] map_red, map_green, map_blue;

  MapDisplay mapdisplay_m(.row(row), .col(col),
                          .map(map),
                          .red(map_red), .green(map_green), .blue(map_blue));
  
  always_comb begin
    if (blank) begin
      {red, green, blue} = '0;
    end
    else begin
      {red, green, blue} = {map_red, map_green, map_blue};
    end
  end
endmodule: Display
