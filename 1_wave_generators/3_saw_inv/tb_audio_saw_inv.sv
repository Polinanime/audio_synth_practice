`timescale 1ns/1ps
`define AUDIO_SAW_INV
`include "../../utils/wav_writer.sv"

module tb_audio_saw_inv;
  tb_audio #(.UUT_MODULE("audio_saw_inv")) tb();
endmodule