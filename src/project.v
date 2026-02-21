/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_example (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // All output pins must be assigned. If not used, assign to 0.
  // assign uo_out  = ui_in + uio_in;  // Example: ou_out is the sum of ui_in and uio_in
  // assign uio_out = 0;
  // assign uio_oe  = 0;

  // uio[0] = 0, uio[1] = 0, uio[2] = 1
  assign uio_oe = 8'b0010_0000;
  assign uio_out[7:3] = 0;
  assign uio_out[1:0] = 0;

  // List all unused inputs to prevent warnings
  wire _unused = &{uio_in[7:2], ena, '0};

  //RangeFinder
  RangeFinder #(8) rf(.data_in(ui_in), .clock(clk), .reset(~rst_n), .go(uio_in[0]), .finish(uio_in[1]),
                      .range(uo_out), .error(uio_out[2]));

endmodule


// RangeFinder
module RangeFinder
  #(parameter WIDTH=16)
  (input  logic [WIDTH-1:0] data_in,
   input  logic             clock, reset,
   input  logic             go, finish,
   output logic [WIDTH-1:0] range,
   output logic             error);

  logic first;
  logic is_min, is_max;
  logic [WIDTH-1:0] min, max;
  logic [WIDTH-1:0] range_upper, range_lower;

  FSM control(.*);

  Register #(WIDTH) reg1(.Q(min),
                        .en(first | is_min),
                        .clear('0),
                        .clock(clock),
                        .D(data_in));

  Register #(WIDTH) reg2(.Q(max),
                        .en(first | is_max),
                        .clear('0),
                        .clock(clock),
                        .D(data_in));

  assign is_min = (data_in < min) ? 1 : 0;
  assign is_max = (max < data_in) ? 1 : 0;
  assign range_upper = (is_max) ? data_in : max;
  assign range_lower = (is_min) ? data_in : min;
  assign range = range_upper - range_lower;

endmodule: RangeFinder

//FSM for rangefinder
module FSM
  (input  logic clock, reset,
   input  logic go, finish,
   output logic error, first);
  
  enum logic [1:0] {START, CHECK, WRONG, BUFFER} curr_state, next_state;

  always_comb begin
    case (curr_state)
      START: begin
        error = (finish) ? 1 : 0;
        first = (go & ~finish) ? 1 : 0;
        if (~go & ~finish) next_state = START;
        else if (finish) next_state = WRONG;
        else if (go & ~finish) next_state = CHECK;
        else next_state = START;
      end
      CHECK: begin
        error = 0;
        first = 0;
        if (~go & ~finish) next_state = BUFFER;
        else if (go) next_state = CHECK;
        else if (~go & finish) next_state = START;
        else next_state = START;
      end
      BUFFER: begin
        error = (go) ? 1 : 0;
        first = 0;
        if (~go & finish) next_state = START;
        else if (~go & ~finish) next_state = BUFFER;
        else if (go) next_state = WRONG;
        else next_state = START;
      end
      WRONG: begin
        error = (go & ~finish) ? 0 : 1;
        first = (go) ? 1 : 0;
        next_state = (go & ~finish) ? CHECK : WRONG;
      end
    endcase
  end

  always_ff @(posedge clock, posedge reset)
    if (reset)
      curr_state <= START;
    else
      curr_state <= next_state;

endmodule: FSM

//register from 240 library
module Register
  # (parameter WIDTH = 8)
  (output logic [WIDTH-1:0] Q,
   input  logic en, clear, clock, 
   input  logic [WIDTH-1:0] D);

  always_ff @(posedge clock)
    if (en)
      Q <= D;
    else if (clear)
      Q <= '0;
endmodule: Register