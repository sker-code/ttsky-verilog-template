`default_nettype none
module Bomberman
  (input  logic clk, rst_n, refresh,
   input  logic btn_up1, btn_down1, btn_left1, btn_right1,
   input  logic btn_bomb1, 
   input  logic btn_up2, btn_down2, btn_left2, btn_right2,
   input  logic btn_bomb2,
   output logic [4:0][6:0][2:0] curr_map);
  
  logic [4:0][6:0][1:0] prev_map;
  logic [4:0][6:0][1:0] give_prev_map;
  logic [2:0] pl1_x, pl1_y;
  logic [2:0] pl2_x, pl2_y;
  logic [2:0] prev_pl1_x, prev_pl1_y;
  logic [2:0] prev_pl2_x, prev_pl2_y;
  logic [2:0] bomb1_x, bomb1_y;
  logic [2:0] bomb2_x, bomb2_y;
  logic bomb1_ticking, bomb1_firing;
  logic bomb2_ticking, bomb2_firing;
  logic pl1_alive, pl2_alive;
  logic pl1_win, pl2_win;

  PrevMap map_m(.clk(clk), .rst_n(rst_n), .refresh(refresh),
            .give_prev_map(give_prev_map),
            .prev_map(prev_map));

  CurrMap currmap_m(.prev_map(prev_map),
                    .pl1_x(pl1_x), .pl1_y(pl1_y),
                    .pl2_x(pl2_x), .pl2_y(pl2_y),
                    .prev_pl1_x(prev_pl1_x), .prev_pl1_y(prev_pl1_y),
                    .prev_pl2_x(prev_pl2_x), .prev_pl2_y(prev_pl2_y),
                    .bomb1_x(bomb1_x), .bomb1_y(bomb1_y),
                    .bomb2_x(bomb2_x), .bomb2_y(bomb2_y),
                    .bomb1_ticking(bomb1_ticking), .bomb1_firing(bomb1_firing),
                    .bomb2_ticking(bomb2_ticking), .bomb2_firing(bomb2_firing),
                    .pl1_win(pl1_win), .pl2_win(pl2_win),
                    .curr_map(curr_map),
                    .give_prev_map(give_prev_map));
  
  PrevPlayer prevplayer_m(.clk(clk), .rst_n(rst_n), .refresh(refresh),
                          .pl1_x(pl1_x), .pl1_y(pl1_y),
                          .pl2_x(pl2_x), .pl2_y(pl2_y),
                          .prev_pl1_x(prev_pl1_x), .prev_pl1_y(prev_pl1_y),
                          .prev_pl2_x(prev_pl2_x), .prev_pl2_y(prev_pl2_y));

  Player player1_m(.clk(clk), .rst_n(rst_n), .refresh(refresh),
                   .btn_up(btn_up1), .btn_down(btn_down1), .btn_left(btn_left1), .btn_right(btn_right1),
                   .curr_map(curr_map),
                   .is_player1(1'd1),
                   .pl_x(pl1_x), .pl_y(pl1_y),
                   .is_alive(pl1_alive));
  
  Player player2_m(.clk(clk), .rst_n(rst_n), .refresh(refresh),
                   .btn_up(btn_up2), .btn_down(btn_down2), .btn_left(btn_left2), .btn_right(btn_right2),
                   .curr_map(curr_map),
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

  Winner winner_m(.pl1_alive(pl1_alive), .pl2_alive(pl2_alive),
                  .clk(clk), .rst_n(rst_n),
                  .pl1_win(pl1_win), .pl2_win(pl2_win));
  
endmodule: Bomberman

module Winner
  (input  logic pl1_alive, pl2_alive,
   input  logic clk, rst_n,
   output logic pl1_win, pl2_win);

  always_ff @(posedge clk) begin
    if (~rst_n) begin
      pl1_win <= 1'd0;
      pl2_win <= 1'd0;
    end
    else if (~pl1_alive) begin
      pl2_win <= 1'd1;
    end
    else if (~pl2_alive) begin
      pl1_win <= 1'd1;
    end
  end
endmodule: Winner

module BombCounter
  (input  logic clk, rst_n, refresh, clear,
   output logic [5:0] counter);
  
  always_ff @(posedge clk) begin
    if (~rst_n || clear) begin
      counter <= 7'd0;
    end
    else if (refresh) begin
      counter <= counter + 7'd1;
    end
  end

endmodule: BombCounter

module Bomb
  (input  logic clk, rst_n, refresh,
   input  logic [2:0] pl_x, pl_y,
   input  logic btn_bomb,
   output logic [2:0] bomb_x, bomb_y,
   output logic bomb_ticking, bomb_firing);
  
  logic bomb;
  logic [5:0] counter;
  logic clear_counter; 

  ButtonBuffer up_m(.button_in(btn_bomb), .clk(clk), .rst_n(rst_n), .refresh(refresh),
                    .button_out(bomb));
  
  enum logic [1:0] {WAIT, TICKING, FIRE} curr_state, next_state;

  BombCounter cntr(.clk(clk), .rst_n(rst_n), .refresh(refresh), .clear(clear_counter),
                   .counter(counter));
  
  always_ff @(posedge clk) begin 
    if (~rst_n) begin
      bomb_x <= 3'd0;
      bomb_y <= 3'd0;
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
        next_state = (counter == 40) ? FIRE : TICKING;
        bomb_ticking = 1'd1;
        clear_counter = 1'd0;
        bomb_firing = 1'd0;
      end
      FIRE: begin
        next_state = (counter == 63) ? WAIT : FIRE;
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
   input  logic [4:0][6:0][2:0] curr_map,
   input  logic is_player1,
   output logic [2:0] pl_x, pl_y,
   output logic is_alive);

  assign is_alive = (curr_map[pl_y][pl_x] != 3'd3);

  logic up_valid, down_valid, left_valid, right_valid;

  assign up_valid = (curr_map[pl_y - 1][pl_x] == 3'd0 || curr_map[pl_y - 1][pl_x] == 3'd3);
  assign down_valid = (curr_map[pl_y + 1][pl_x] == 3'd0 || curr_map[pl_y + 1][pl_x] == 3'd3);
  assign left_valid = (curr_map[pl_y][pl_x - 1] == 3'd0 || curr_map[pl_y][pl_x - 1] == 3'd3);
  assign right_valid = (curr_map[pl_y][pl_x + 1] == 3'd0 || curr_map[pl_y][pl_x + 1] == 3'd3);
  
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
        pl_x <= 3'd0;
        pl_y <= 3'd0;
      end
      else begin
        pl_x <= 3'd6;
        pl_y <= 3'd4;
      end
    end
    else if (up && pl_y > 3'd0 && up_valid) begin
      pl_y <= pl_y - 3'd1;
    end
    else if (down && pl_y < 3'd4 && down_valid) begin
      pl_y <= pl_y + 3'd1;
    end
    else if (left && pl_x > 3'd0 && left_valid) begin
      pl_x <= pl_x - 3'd1;
    end
    else if (right && pl_x < 3'd6 && right_valid) begin
      pl_x <= pl_x + 3'd1;
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

module PrevPlayer
  (input  logic clk, rst_n, refresh,
   input  logic [2:0] pl1_x, pl1_y,
   input  logic [2:0] pl2_x, pl2_y,
   output logic [2:0] prev_pl1_x, prev_pl1_y,
   output logic [2:0] prev_pl2_x, prev_pl2_y);
  
  always_ff @(posedge clk) begin
    if (~rst_n) begin
      prev_pl1_x <= 3'd0;
      prev_pl1_y <= 3'd0;
      prev_pl2_x <= 3'd6;
      prev_pl2_y <= 3'd4;
    end
    else if (refresh) begin
      prev_pl1_x <= pl1_x;
      prev_pl1_y <= pl1_y;
      prev_pl2_x <= pl2_x;
      prev_pl2_y <= pl2_y;
    end
  end

endmodule : PrevPlayer

module CurrMap
  (input  logic [4:0][6:0][1:0] prev_map,
   input  logic [2:0] pl1_x, pl1_y,
   input  logic [2:0] pl2_x, pl2_y,
   input  logic [2:0] prev_pl1_x, prev_pl1_y,
   input  logic [2:0] prev_pl2_x, prev_pl2_y,
   input  logic [2:0] bomb1_x, bomb1_y,
   input  logic [2:0] bomb2_x, bomb2_y,
   input  logic bomb1_ticking, bomb1_firing,
   input  logic bomb2_ticking, bomb2_firing,
   input  logic pl1_win, pl2_win,
   output logic [4:0][6:0][2:0] curr_map,
   output logic [4:0][6:0][1:0] give_prev_map);

  always_comb begin
    for (int i = 0; i < 5; i++) begin
      for (int j = 0; j < 7; j++) begin
        if (pl1_win) begin //player 1 win
          curr_map[i][j] = 3'd5;
          give_prev_map[i][j] = 2'd0;
        end
        else if (pl2_win) begin // player 2 win
          curr_map[i][j] = 3'd6;
          give_prev_map[i][j] = 2'd0;
        end
        // if not unbreakable, replace with fire - player 1
        else if ((prev_map[i][j] != 2'd2) && 
             bomb1_firing && (((i == bomb1_y) && (j == bomb1_x)) ||
                              ((i == bomb1_y - 3'd1) && (j == bomb1_x)) ||
                              ((i == bomb1_y + 3'd1) && (j == bomb1_x)) ||
                              ((i == bomb1_y) && (j == bomb1_x - 3'd1)) ||
                              ((i == bomb1_y) && (j == bomb1_x + 3'd1)))) begin
            curr_map[i][j] = 3'd3; // fire
            give_prev_map[i][j] = 2'd3;
        end
        // if not unbreakable, replace with fire - player 2
        else if ((prev_map[i][j] != 2'd2) && 
             bomb2_firing && (((i == bomb2_y) && (j == bomb2_x)) ||
                              ((i == bomb2_y - 3'd1) && (j == bomb2_x)) ||
                              ((i == bomb2_y + 3'd1) && (j == bomb2_x)) ||
                              ((i == bomb2_y) && (j == bomb2_x - 3'd1)) ||
                              ((i == bomb2_y) && (j == bomb2_x + 3'd1)))) begin
            curr_map[i][j] = 3'd3; // fire
            give_prev_map[i][j] = 2'd3;
        end
        // if bomb finished firing, replace it with grass - player 1 and player 2
        else if (!bomb1_firing && !bomb2_firing && (prev_map[i][j] == 2'd3)) begin 
            curr_map[i][j] = 3'd0; // grass
            give_prev_map[i][j] = 2'd0;
        end
        // player 1 placement
        else if ((i == pl1_y) && (j == pl1_x)) begin 
          curr_map[i][j] = 3'd5;
          give_prev_map[i][j] = 2'd0;
        end
        // player 2 placement
        else if ((i == pl2_y) && (j == pl2_x)) begin
          curr_map[i][j] = 3'd6; 
          give_prev_map[i][j] = 2'd0;
        end
        // place bomb based on player 1 location
        else if (bomb1_ticking && (i == bomb1_y) && (j == bomb1_x)) begin 
          curr_map[i][j] = 3'd4; // bomb
          give_prev_map[i][j] = 2'd0;
        end
        // place bomb based on player 2 location
        else if (bomb2_ticking && (i == bomb2_y) && (j == bomb2_x)) begin
          curr_map[i][j] = 3'd4; // bomb
          give_prev_map[i][j] = 2'd0;
        end 
        // default case
        else begin
          curr_map[i][j] = prev_map[i][j];
          give_prev_map[i][j] = prev_map[i][j];
        end
      end
    end
  end
endmodule : CurrMap

module ResetMap
  (output logic [4:0][6:0][1:0] reset_map);

  always_comb begin
    for (int i = 0; i < 5; i++) begin
      for (int j = 0; j < 7; j++) begin
        if ((i[0] == 1'd1) && (j[0] == 1'd1))
          reset_map[i][j] = 3'd2; // unbreakable individual blocks
        else if (((i == 0) && ((j == 0) || (j == 1))) ||
                 ((i == 1) && (j == 0)) ||
                 ((i == 3) && (j == 6)) ||
                 ((i == 4) && ((j == 5) || (j == 6)))) begin
          reset_map[i][j] = 3'd0; // grass
        end
        else begin
          reset_map[i][j] = 3'd1; // breakable block
        end
      end
    end
  end

endmodule : ResetMap

module PrevMap
  (input  logic clk, rst_n, refresh,
   input  logic [4:0][6:0][1:0] give_prev_map,
   output logic [4:0][6:0][1:0] prev_map);

  logic [4:0][6:0][1:0] reset_map;

  ResetMap resetmap_m(.reset_map(reset_map));

  always_ff @(posedge clk) begin
    if (~rst_n) begin
      prev_map <= reset_map;
    end
    else if (refresh) begin 
      prev_map <= give_prev_map;
    end
  end

endmodule: PrevMap

module Synchronizer
  (input  logic async, clk,
   output logic sync);

  logic buffer;

  always_ff @(posedge clk) begin
    sync <= buffer;
    buffer <= async;
  end
endmodule: Synchronizer