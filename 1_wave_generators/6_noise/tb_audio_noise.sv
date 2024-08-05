`timescale 1ns/1ps
`define AUDIO_NOISE
`include "../../utils/wav_writer.sv"

module tb_audio_noise;
tb_audio #(.UUT_MODULE("audio_noise")) tb();
endmodule