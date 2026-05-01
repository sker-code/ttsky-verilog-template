/*
 * Copyright (c) 2026 Sylvia Ker
 * SPDX-License-Identifier: Apache-2.0
 */
`default_nettype none

module tt_um_sker (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  assign uio_oe = 8'b0000_0000; // IOs: Enable path (active high: 0=input, 1=output)
  wire _unused = &{uio_in[7:2], ena, '0}; // List all unused inputs to prevent warnings
  assign uio_out = 0; // If output pins not used, assign to 0.

  ChipInterface chip(.clk(clk), .rst_n(rst_n),
                     .btn_up1(ui_in[0]), .btn_down1(ui_in[1]), .btn_left1(ui_in[2]), .btn_right1(ui_in[3]),
                     .btn_bomb1(uio_in[0]),
                     .btn_up2(ui_in[4]), .btn_down2(ui_in[5]), .btn_left2(ui_in[6]), .btn_right2(ui_in[7]),
                     .btn_bomb2(uio_in[1]),
                     .red({uo_out[0], uo_out[4]}), .green({uo_out[1], uo_out[5]}), .blue({uo_out[2], uo_out[6]}), 
                     .HS(uo_out[3]), .VS(uo_out[7]));
endmodule
