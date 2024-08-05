`timescale 1ns/1ps
`define AUDIO_SAW
`include "../../utils/wav_writer.sv"

module tb_audio_saw;
  tb_audio #(.UUT_MODULE("audio_saw")) tb();
endmodule