`default_nettype none
module Bomberman
  (input  logic clk, rst_n, refresh,
   input  logic btn_up1, btn_down1, btn_left1, btn_right1,
   input  logic btn_bomb1, 
   input  logic btn_up2, btn_down2, btn_left2, btn_right2,
   input  logic btn_bomb2,
   output logic [6:0][8:0][2:0] map);
  
  logic [6:0][8:0][2:0] temp_map;
  logic [3:0] pl1_x, pl1_y;
  logic [3:0] pl2_x, pl2_y;
  logic [3:0] bomb1_x, bomb1_y;
  logic [3:0] bomb2_x, bomb2_y;
  logic bomb1_ticking, bomb1_firing;
  logic bomb2_ticking, bomb2_firing;
  logic pl1_alive, pl2_alive;
  logic pl1_win, pl2_win;

  Map map_m(.clk(clk), .rst_n(rst_n), .refresh(refresh),
            .temp_map(temp_map),
            .map(map));

  TempMap tempmap_m(.map(map),
                    .pl1_x(pl1_x), .pl1_y(pl1_y),
                    .pl2_x(pl2_x), .pl2_y(pl2_y),
                    .bomb1_x(bomb1_x), .bomb1_y(bomb1_y),
                    .bomb2_x(bomb2_x), .bomb2_y(bomb2_y),
                    .bomb1_ticking(bomb1_ticking), .bomb1_firing(bomb1_firing),
                    .bomb2_ticking(bomb2_ticking), .bomb2_firing(bomb2_firing),
                    .pl1_win(pl1_win), .pl2_win(pl2_win),
                    .temp_map(temp_map));
  
  Player player1_m(.clk(clk), .rst_n(rst_n), .refresh(refresh),
                   .btn_up(btn_up1), .btn_down(btn_down1), .btn_left(btn_left1), .btn_right(btn_right1),
                   .map(map),
                   .is_player1(1'd1),
                   .pl_x(pl1_x), .pl_y(pl1_y),
                   .is_alive(pl1_alive));
  
  Player player2_m(.clk(clk), .rst_n(rst_n), .refresh(refresh),
                   .btn_up(btn_up2), .btn_down(btn_down2), .btn_left(btn_left2), .btn_right(btn_right2),
                   .map(map),
                   .is_player1(1'd0),
                   .pl_x(pl2_x), .pl_y(pl2_y),
                   .is_alive(pl2_alive));

  Bomb bomb1_m(.clk(clk), .rst_n(rst_n), .refresh(refresh),
              .pl_x(pl1_x), .pl_y(pl1_y),
              .btn_bomb(btn_bomb1),
              .bomb_x(bomb1_x), .bomb_y(bomb1_y),
              .bomb_ticking(bomb1_ticking), .bomb_firing(bomb1_firing));

  Bomb bomb2_m(.clk(clk), .rst_n(rst_n), .refresh(refresh),
              .pl_x(pl2_x), .pl_y(pl2_y),
              .btn_bomb(btn_bomb2),
              .bomb_x(bomb2_x), .bomb_y(bomb2_y),
              .bomb_ticking(bomb2_ticking), .bomb_firing(bomb2_firing));

  GameFSM fsm_m(.pl1_alive(pl1_alive), .pl2_alive(pl2_alive),
                .clk(clk), .rst_n(rst_n),
                .pl1_win(pl1_win), .pl2_win(pl2_win));
  
endmodule: Bomberman

module GameFSM
  (input  logic pl1_alive, pl2_alive,
   input  logic clk, rst_n,
   output logic pl1_win, pl2_win);

  enum logic [1:0] {PLAY, WIN1, WIN2} curr_state, next_state;

  always_comb begin
    case (curr_state)
      PLAY: begin
        next_state = (pl1_alive && pl2_alive) ? PLAY : ((pl2_alive) ? WIN2 : WIN1);
        pl1_win = 1'd0;
        pl2_win = 1'd0;
      end
      WIN1: begin
        next_state = WIN1;
        pl1_win = 1'd1;
        pl2_win = 1'd0;
      end
      WIN2: begin
        next_state = WIN2;
        pl1_win = 1'd0;
        pl2_win = 1'd1;
      end
      default: begin
        next_state = PLAY;
        pl1_win = 1'd0;
        pl2_win = 1'd0;
      end
    endcase
  end

  always_ff @(posedge clk) begin
  if (~rst_n) 
    curr_state <= PLAY;
  else
    curr_state <= next_state;
  end
endmodule: GameFSM

module BombCounter
  (input  logic clk, rst_n, refresh, clear,
   output logic [7:0] counter);
  
  always_ff @(posedge clk) begin
    if (~rst_n || clear) begin
      counter <= 1'd0;
    end
    else if (refresh) begin
      counter <= counter + 8'd1;
    end
  end

endmodule: BombCounter

module Bomb
  (input  logic clk, rst_n, refresh,
   input  logic [3:0] pl_x, pl_y,
   input  logic btn_bomb,
   output logic [3:0] bomb_x, bomb_y,
   output logic bomb_ticking, bomb_firing);
  
  logic bomb;
  logic [7:0] counter;
  logic clear_counter; 

  ButtonBuffer up_m(.button_in(btn_bomb), .clk(clk), .rst_n(rst_n), .refresh(refresh),
                    .button_out(bomb));
  
  enum logic [1:0] {WAIT, TICKING, FIRE} curr_state, next_state;

  BombCounter cntr(.clk(clk), .rst_n(rst_n), .refresh(refresh), .clear(clear_counter),
                   .counter(counter));
  
  always_ff @(posedge clk) begin 
    if (~rst_n) begin
      bomb_x <= 4'd0;
      bomb_y <= 4'd0;
    end
    else if (curr_state == WAIT) begin
      bomb_x <= pl_x;
      bomb_y <= pl_y;
    end
  end

  always_comb begin
    case (curr_state)
      WAIT: begin
        next_state = (bomb) ? TICKING : WAIT;
        bomb_ticking = 1'd0;
        clear_counter = 1'd1;
        bomb_firing = 1'd0;
      end
      TICKING: begin
        next_state = (counter == 120) ? FIRE : TICKING;
        bomb_ticking = 1'd1;
        clear_counter = 1'd0;
        bomb_firing = 1'd0;
      end
      FIRE: begin
        next_state = (counter == 180) ? WAIT : FIRE;
        bomb_ticking = 1'd0;
        clear_counter = 1'd0;
        bomb_firing = 1'd1;
      end
      default: begin
        next_state = WAIT;
        bomb_ticking = 1'd0;
        clear_counter = 1'd1;
        bomb_firing = 1'd0;
      end
    endcase
  end

  always_ff @(posedge clk) begin
  if (~rst_n) 
    curr_state <= WAIT;
  else
    curr_state <= next_state;
  end

endmodule: Bomb

module Player
  (input  logic clk, rst_n, refresh,
   input  logic btn_up, btn_down, btn_left, btn_right,
   input  logic [6:0][8:0][2:0] map,
   input  logic is_player1,
   output logic [3:0] pl_x, pl_y,
   output logic is_alive);

  assign is_alive = (map[pl_y][pl_x] != 3'd4);

  logic up_valid, down_valid, left_valid, right_valid;

  assign up_valid = (map[pl_y - 1][pl_x] == 3'd0 || map[pl_y - 1][pl_x] == 3'd4);
  assign down_valid = (map[pl_y + 1][pl_x] == 3'd0 || map[pl_y + 1][pl_x] == 3'd4);
  assign left_valid = (map[pl_y][pl_x - 1] == 3'd0 || map[pl_y][pl_x - 1] == 3'd4);
  assign right_valid = (map[pl_y][pl_x + 1] == 3'd0 || map[pl_y][pl_x + 1] == 3'd4);
  
  logic up, down, left, right;

  ButtonBuffer up_m(.button_in(btn_up), .clk(clk), .rst_n(rst_n), .refresh(refresh),
                    .button_out(up));
  
  ButtonBuffer down_m(.button_in(btn_down), .clk(clk), .rst_n(rst_n), .refresh(refresh),
                    .button_out(down));

  ButtonBuffer left_m(.button_in(btn_left), .clk(clk), .rst_n(rst_n), .refresh(refresh),
                    .button_out(left));
  
  ButtonBuffer right_m(.button_in(btn_right), .clk(clk), .rst_n(rst_n), .refresh(refresh),
                    .button_out(right));

  always_ff @(posedge clk) begin
    if (~rst_n) begin
      if (is_player1) begin
        pl_x <= 4'd1;
        pl_y <= 4'd1;
      end
      else begin
        pl_x <= 4'd7;
        pl_y <= 4'd5;
      end
    end
    else if (up && pl_y > 4'd1 && up_valid) begin
      pl_y <= pl_y - 4'd1;
    end
    else if (down && pl_y < 4'd5 && down_valid) begin
      pl_y <= pl_y + 4'd1;
    end
    else if (left && pl_x > 4'd1 && left_valid) begin
      pl_x <= pl_x - 4'd1;
    end
    else if (right && pl_x < 4'd7 && right_valid) begin
      pl_x <= pl_x + 4'd1;
    end
  end
  
endmodule: Player

module ButtonBuffer
  (input  logic button_in, clk, rst_n, refresh,
   output logic button_out);

  logic button_sync;
  Synchronizer sync_m(.async(button_in), .clk(clk),
                      .sync(button_sync));
  
  enum logic {UP, DOWN} curr_state, next_state;
  
  always_comb begin
    case (curr_state)
      UP: begin
        next_state = (button_sync && refresh) ? DOWN : UP;
        button_out = (button_sync && refresh);
      end
      DOWN: begin 
        next_state = (~button_sync && refresh) ? UP : DOWN;
        button_out = 0;
      end
    endcase
  end
  always_ff @(posedge clk) begin
  if (~rst_n) 
    curr_state <= UP;
  else
    curr_state <= next_state;
  end
endmodule: ButtonBuffer

module TempMap
  (input  logic [6:0][8:0][2:0] map,
   input  logic [3:0] pl1_x, pl1_y,
   input  logic [3:0] pl2_x, pl2_y,
   input  logic [3:0] bomb1_x, bomb1_y,
   input  logic [3:0] bomb2_x, bomb2_y,
   input  logic bomb1_ticking, bomb1_firing,
   input  logic bomb2_ticking, bomb2_firing,
   input  logic pl1_win, pl2_win,
   output logic [6:0][8:0][2:0] temp_map);
  
  always_comb begin
    for (int i = 0; i < 7; i++) begin
      for (int j = 0; j < 9; j++) begin
        if (pl1_win) begin //player 1 win
          temp_map[i][j] = 3'd5;
        end
        else if (pl2_win) begin // player 2 win
          temp_map[i][j] = 3'd6;
        end
        // if not unbreakable and not fire, replace with fire - player 1
        else if ((map[i][j] != 3'd2) && (map[i][j] != 3'd4) && 
             bomb1_firing && (((i == bomb1_y) && (j == bomb1_x)) ||
                              ((i == bomb1_y - 4'd1) && (j == bomb1_x)) ||
                              ((i == bomb1_y + 4'd1) && (j == bomb1_x)) ||
                              ((i == bomb1_y) && (j == bomb1_x - 4'd1)) ||
                              ((i == bomb1_y) && (j == bomb1_x + 4'd1)))) begin
            temp_map[i][j] = 3'd4; // fire
        end
        // if not unbreakable and not fire, replace with fire - player 2
        else if ((map[i][j] != 3'd2) && (map[i][j] != 3'd4) && 
             bomb2_firing && (((i == bomb2_y) && (j == bomb2_x)) ||
                              ((i == bomb2_y - 4'd1) && (j == bomb2_x)) ||
                              ((i == bomb2_y + 4'd1) && (j == bomb2_x)) ||
                              ((i == bomb2_y) && (j == bomb2_x - 4'd1)) ||
                              ((i == bomb2_y) && (j == bomb2_x + 4'd1)))) begin
            temp_map[i][j] = 3'd4; // fire
        end
        // if bomb finished firing, replace it with grass - player 1 and player 2
        else if (!bomb1_firing && !bomb2_firing && (map[i][j] == 3'd4)) begin 
            temp_map[i][j] = 3'd0; // grass
        end
        // player 1 placement
        else if ((i == pl1_y) && (j == pl1_x)) begin 
          temp_map[i][j] = 3'd5; 
        end
        // player 2 placement
        else if ((i == pl2_y) && (j == pl2_x)) begin
          temp_map[i][j] = 3'd6; 
        end
        // place bomb based on player 1 location
        else if (map[i][j] == 3'd5) begin // prev player 1 location
          // if placed bomb, place the bomb
          if (bomb1_ticking && (i == bomb1_y) && (j == bomb1_x)) begin
            temp_map[i][j] = 3'd3; // bomb
          end
          // if no bomb, left is grass
          else begin
            temp_map[i][j] = 3'd0; // grass
          end
        end
        // place bomb based on player 2 location
        else if (map[i][j] == 3'd6) begin // prev player 2 location
          // if placed bomb, place the bomb
          if (bomb2_ticking && (i == bomb2_y) && (j == bomb2_x)) begin
            temp_map[i][j] = 3'd3; // bomb
          end
          // if no bomb, left is grass
          else begin
            temp_map[i][j] = 3'd0; // grass
          end
        end 
        // default case
        else begin
          temp_map[i][j] = map[i][j];
        end
      end
    end
  end
endmodule : TempMap

module ResetMap
  (output logic [6:0][8:0][2:0] reset_map);
  always_comb begin
    for (int i = 0; i < 7; i++) begin
      for (int j = 0; j < 9; j++) begin
        if ((i == 0) || (i == 6) || (j == 0) || (j == 8)) begin 
          reset_map[i][j] = 3'd2; // unbreakable borders
        end
        else if ((i[0] == 0) && (j[0] == 0))
          reset_map[i][j] = 3'd2; // between unbreakable blocks
        else if (((i == 1) && ((j == 1) || (j == 2) || (j == 6))) ||
                  ((i == 2) && (j == 1)) ||
                  ((i == 4) && (j == 7)) ||
                  ((i == 5) && ((j == 2) || (j == 6) || (j == 7)))) begin
          reset_map[i][j] = 3'd0; // grass
        end
        else begin
          reset_map[i][j] = 3'd1; // breakable block
        end
      end
    end
  end

endmodule : ResetMap

module Map
  (input  logic clk, rst_n, refresh,
   input  logic [6:0][8:0][2:0] temp_map,
   output logic [6:0][8:0][2:0] map);

  logic [6:0][8:0][2:0] reset_map;

  ResetMap resetmap_m(.reset_map(reset_map));

  always_ff @(posedge clk) begin
    if (~rst_n) begin
      map = reset_map;
    end
    else if (refresh) begin 
      map <= temp_map;
    end
  end

endmodule: Map

module Synchronizer
  (input  logic async, clk,
   output logic sync);

  logic buffer;

  always_ff @(posedge clk) begin
    sync <= buffer;
    buffer <= async;
  end
endmodule: Synchronizer