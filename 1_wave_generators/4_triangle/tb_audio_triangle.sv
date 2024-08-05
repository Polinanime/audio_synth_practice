`timescale 1ns/1ps
`define AUDIO_TRIANGLE
`include "../../utils/wav_writer.sv"

module tb_audio_triangle;
tb_audio #(.UUT_MODULE("audio_triangle")) tb();
endmodule