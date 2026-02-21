// Task 1
`default_nettype none

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