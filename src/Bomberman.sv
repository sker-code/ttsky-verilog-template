`default_nettype none
module Bomberman
  (input  logic clk, rst_n, refresh,
   input  logic btn_up, btn_down, btn_left, btn_right,
   input  logic btn_bomb, 
   input  logic btn_up1, btn_down1, btn_left1, btn_right1,
   //input  logic btn_bomb1, 
   output logic [10:0][14:0][2:0] map);
  
  logic [10:0][14:0][2:0] temp_map;
  logic [3:0] pl1_x, pl1_y;
  logic [3:0] pl2_x, pl2_y;
  logic [3:0] bomb1_x, bomb1_y;
  logic bomb1_ticking, bomb_firing;
  logic pl1_alive, pl2_alive;
  logic pl1_win, pl2_win;

  Map map_m(.clk(clk), .rst_n(rst_n), .refresh(refresh),
            .temp_map(temp_map),
            .map(map),
            .pl1_win(pl1_win), .pl2_win(pl2_win));

  TempMap tempmap_m(.map(map),
                    .pl1_x(pl1_x), .pl1_y(pl1_y),
                    .pl2_x(pl2_x), .pl2_y(pl2_y),
                    .bomb1_x(bomb1_x), .bomb1_y(bomb1_y),
                    .bomb_ticking(bomb1_ticking), .bomb_firing(bomb_firing),
                    .temp_map(temp_map));
  
  Player player1_m(.clk(clk), .rst_n(rst_n), .refresh(refresh),
                   .btn_up(btn_up), .btn_down(btn_down), .btn_left(btn_left), .btn_right(btn_right),
                   .map(map),
                   .is_player1('1),
                   .pl_x(pl1_x), .pl_y(pl1_y),
                   .is_alive(pl1_alive));
  
  Player player2_m(.clk(clk), .rst_n(rst_n), .refresh(refresh),
                   .btn_up(btn_up1), .btn_down(btn_down1), .btn_left(btn_left1), .btn_right(btn_right1),
                   .map(map),
                   .is_player1('0),
                   .pl_x(pl2_x), .pl_y(pl2_y),
                   .is_alive(pl2_alive));

  Bomb bomb_m(.clk(clk), .rst_n(rst_n), .refresh(refresh),
              .pl_x(pl1_x), .pl_y(pl1_y),
              .btn_bomb(btn_bomb),
              .bomb_x(bomb1_x), .bomb_y(bomb1_y),
              .bomb_ticking(bomb1_ticking), .bomb_firing(bomb_firing));

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
        pl1_win = 0;
        pl2_win = 0;
      end
      WIN1: begin
        next_state = WIN1;
        pl1_win = 1;
        pl2_win = 0;
      end
      WIN2: begin
        next_state = WIN2;
        pl1_win = 0;
        pl2_win = 1;
      end
      default: begin
        next_state = PLAY;
        pl1_win = 0;
        pl2_win = 0;
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
      counter <= 0;
    end
    else if (refresh) begin
      counter <= counter + 1;
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
    if (curr_state == WAIT) begin
      bomb_x <= pl_x;
      bomb_y <= pl_y;
    end
  end

  always_comb begin
    case (curr_state)
      WAIT: begin
        next_state = (bomb) ? TICKING : WAIT;
        bomb_ticking = 0;
        clear_counter = 1;
        bomb_firing = 0;
      end
      TICKING: begin
        next_state = (counter == 120) ? FIRE : TICKING;
        bomb_ticking = 1;
        clear_counter = 0;
        bomb_firing = 0;
      end
      FIRE: begin
        next_state = (counter == 180) ? WAIT : FIRE;
        bomb_ticking = 0;
        clear_counter = 0;
        bomb_firing = 1;
      end
      default: begin
        next_state = WAIT;
        bomb_ticking = 0;
        clear_counter = 1;
        bomb_firing = 0;
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
   input  logic [10:0][14:0][2:0] map,
   input  logic is_player1,
   output logic [3:0] pl_x, pl_y,
   output logic is_alive);

  assign is_alive = (map[pl_y][pl_x] != 3'd4);

  logic up_valid, down_valid, left_valid, right_valid;

  assign up_valid = (map[pl_y - 1][pl_x] == 0 || map[pl_y - 1][pl_x] == 4);
  assign down_valid = (map[pl_y + 1][pl_x] == 0 || map[pl_y + 1][pl_x] == 4);
  assign left_valid = (map[pl_y][pl_x - 1] == 0 || map[pl_y][pl_x - 1] == 4);
  assign right_valid = (map[pl_y][pl_x + 1] == 0 || map[pl_y][pl_x + 1] == 4);
  
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
        pl_x <= 1;
        pl_y <= 1;
      end
      else begin
        pl_x <= 13;
        pl_y <= 9;
      end
    end
    else if (up && pl_y > 1 && up_valid) begin
      pl_y <= pl_y - 1;
    end
    else if (down && pl_y < 9 && down_valid) begin
      pl_y <= pl_y + 1;
    end
    else if (left && pl_x > 1 && left_valid) begin
      pl_x <= pl_x - 1;
    end
    else if (right && pl_x < 13 && right_valid) begin
      pl_x <= pl_x + 1;
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
  (input  logic [10:0][14:0][2:0] map,
   input  logic [3:0] pl1_x, pl1_y,
   input  logic [3:0] pl2_x, pl2_y,
   input  logic [3:0] bomb1_x, bomb1_y,
   input  logic bomb_ticking, bomb_firing,
   output logic [10:0][14:0][2:0] temp_map);
  
  always_comb begin
    for (logic [3:0] i = 0; i < 11; i++) begin
      for (logic [3:0] j = 0; j < 15; j++) begin
        // if not unbreakable and not fire
        if ((map[i][j] != 3'd2) && (map[i][j] != 3'd4) && 
             bomb_firing && (((i == bomb1_y) && (j == bomb1_x)) ||
                             ((i == (bomb1_y - 1)) && (j == bomb1_x)) ||
                             ((i == (bomb1_y + 1)) && (j == bomb1_x)) ||
                             ((i == bomb1_y) && (j == (bomb1_x - 1))) ||
                             ((i == bomb1_y) && (j == (bomb1_x + 1))))) begin
            temp_map[i][j] = 3'd4; // fire
        end
        // if bomb finished firing, replace it with grass
        else if (!bomb_firing && (map[i][j] == 3'd4)) begin 
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
          if (bomb_ticking && (i == bomb1_y) && (j == bomb1_x)) begin
            temp_map[i][j] = 3'd3; // bomb
          end
          // if no bomb, left is grass
          else begin
            temp_map[i][j] = 3'd0; // grass
          end
        end 
        else begin
          temp_map[i][j] = map[i][j];
        end
      end
    end
  end
endmodule : TempMap

module Map
  (input  logic clk, rst_n, refresh,
   input  logic [10:0][14:0][2:0] temp_map,
   input  logic pl1_win, pl2_win,
   output logic [10:0][14:0][2:0] map);

  always_ff @(posedge clk) begin
    if (~rst_n) begin
      for (logic [3:0] i = 0; i < 11; i++) begin
        for (logic [3:0] j = 0; j < 15; j++) begin
          if ((i == 0) || (i == 10) || (j == 0) || (j == 14)) begin 
            map[i][j] <= 3'd2; // unbreakable borders
          end
          else if ((i[0] == 0) && (j[0] == 0))
            map[i][j] <= 3'd2; // between unbreakable blocks
          else if (((i == 1) && ((j == 1) || (j == 2) || (j == 8))) ||
                   ((i == 2) && ((j == 1) || (j == 7))) ||
                   ((i == 3) && ((j == 9)|| (j == 13))) ||
                   ((i == 4) && ((j == 3)|| (j == 9)))  ||
                   ((i == 5) && ((j == 5)|| (j == 10))) ||
                   ((i == 7) && ((j == 2)|| (j == 3)))  ||
                   ((i == 8) && ((j == 1)|| (j == 13))) ||
                   ((i == 9) && ((j == 9)|| (j == 12) || (j == 13)))) begin
            map[i][j] <= 3'd0; // grass
          end
          else begin
            map[i][j] <= 3'd1; // breakable block
          end
        end
      end
    end
    else if (refresh)
      if (pl1_win) begin
        for (logic [3:0] i = 0; i < 11; i++) begin
          for (logic [3:0] j = 0; j < 15; j++) begin 
            map[i][j] <= 3'd5;
          end
        end
      end
      else if (pl2_win) begin
        for (logic [3:0] i = 0; i < 11; i++) begin
          for (logic [3:0] j = 0; j < 15; j++) begin 
            map[i][j] <= 3'd6;
          end
        end
      end
      else begin 
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