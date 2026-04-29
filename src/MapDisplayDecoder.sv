`default_nettype none
/*
for map values:
0: grass
1: breakable
2: unbreakable
3: bomb
4: fire
5: player1
6: player2
*/
module MapDisplayDecoder
  (input  logic [2:0] map_value,
   output logic [1:0] red, green, blue);
  always_comb begin
    if (map_value == 3'd0) begin // grass
      {red, green, blue} = {2'd0, 2'd2, 2'd0};
    end
    else if (map_value == 3'd1) begin // breakable
      {red, green, blue} = {2'd2, 2'd2, 2'd2};
    end
    else if (map_value == 3'd2) begin // unbreakable
      {red, green, blue} = {2'd1, 2'd1, 2'd1};
    end
    else if (map_value == 3'd3) begin // bomb
      {red, green, blue} = {2'd0, 2'd0, 2'd0};
    end
    else if (map_value == 3'd4) begin // fire
      {red, green, blue} = {2'd3, 2'd1, 2'd0};
    end
    else if (map_value == 3'd5) begin // player 1
      {red, green, blue} = {2'd3, 2'd2, 2'd3};
    end
    else if (map_value == 3'd6) begin // player 2
      {red, green, blue} = {2'd0, 2'd3, 2'd3};
    end
    else begin // other 
      {red, green, blue} = {2'd0, 2'd0, 2'd0};
    end
  end
endmodule: MapDisplayDecoder