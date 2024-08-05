`timescale 1ns/1ps
`define AUDIO_SINE
`include "../../utils/wav_writer.sv"

module tb_audio_sine;
tb_audio #(.UUT_MODULE("audio_sine")) tb();
endmodule