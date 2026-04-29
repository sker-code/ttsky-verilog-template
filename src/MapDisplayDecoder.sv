`default_nettype none
/*
for map values:
0: grass
1: breakable
2: unbreakable
3: fire
4: bomb
5: player1
6: player2
*/
module MapDisplayDecoder
  (input  logic [1:0] map_value,
   input  logic pl1placement, pl2placement,
   input  logic bomb1placement, bomb2placement,
   output logic [1:0] red, green, blue);
  always_comb begin
    if (pl1placement) begin
      {red, green, blue} = {2'd3, 2'd2, 2'd3}; //player 1
    end
    else if (pl2placement) begin // player 2
      {red, green, blue} = {2'd0, 2'd3, 2'd3};
    end
    else if (bomb1placement | bomb2placement) begin
      {red, green, blue} = {2'd0, 2'd0, 2'd0}; // bomb
    end
    else if (map_value == 2'd0) begin // grass
      {red, green, blue} = {2'd0, 2'd2, 2'd0};
    end
    else if (map_value == 2'd1) begin // breakable
      {red, green, blue} = {2'd2, 2'd2, 2'd2};
    end
    else if (map_value == 2'd2) begin // unbreakable
      {red, green, blue} = {2'd1, 2'd1, 2'd1};
    end
    else if (map_value == 2'd3) begin // fire
      {red, green, blue} = {2'd3, 2'd1, 2'd0};
    end
    else begin // invalid 
      {red, green, blue} = {2'd0, 2'd0, 2'd0};
    end
  end
endmodule: MapDisplayDecoder