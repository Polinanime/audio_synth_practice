`timescale 1ns/1ps
`define AUDIO_SQUARE
`include "../../utils/wav_writer.sv"

module tb_audio_square;
  localparam string UUT_MODULE = "audio_square";
  tb_audio tb();
endmodule