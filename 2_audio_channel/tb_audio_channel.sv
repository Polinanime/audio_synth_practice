`timescale 1ns/1ps
`define AUDIO_CHANNEL
`include "../utils/wav_writer.sv"
module tb_audio_channel();

  wav_writer writer();

  localparam DIV_48KHZ = 260 - 1;
  localparam DIV_48KHZ_WIDTH = $clog2(DIV_48KHZ);

  logic clk;
  logic rstn;

  bit [7:0] audio_data [$];

  int sample_rate;
  int sample_bits;
  int sample_channels;
  int sample_num;

  logic        channel_en;
  logic [2:0]  channel_gen_sel;
  logic [15:0] channel_freq;
  logic [7:0]  channel_volume;
  logic [7:0]  channel_sample_data;

  logic [DIV_48KHZ_WIDTH-1:0] clk_div_ff;
  logic [DIV_48KHZ_WIDTH-1:0] clk_div_next;

  logic        sample_val;


  // Generate 12.5 MHz clock
  initial clk <= 0;
  always #40ns clk <= ~clk;


  // Reset
  initial begin
    rstn <= 1'b0;
    repeat(2) @(posedge clk);
    rstn <= 1'b1;
  end

  // Action sequence
  initial begin

    channel_en = '1;
    channel_gen_sel = 3'd0;
    channel_freq = 16'd4723; // set 440 Hz frequency
    channel_volume = 16'hff;

    repeat(12500000) @(posedge clk);
    channel_gen_sel = 3'd1;
    repeat(12500000) @(posedge clk);
    channel_gen_sel = 3'd2;
    repeat(12500000) @(posedge clk);
    channel_gen_sel = 3'd3;
    repeat(12500000) @(posedge clk);
    channel_gen_sel = 3'd4;
    repeat(12500000) @(posedge clk);
    channel_gen_sel = 3'd5;
    repeat(12500000) @(posedge clk);

    sample_rate = 48000;
    sample_bits = 8;
    sample_channels = 1;
    sample_num = audio_data.size();

    writer.write_wav(sample_rate,
              sample_bits,
              sample_channels,
              sample_num,
              audio_data,
              "audio_channel.wav"
              );

    $finish();
  end


  // Sample data at 48 KHz frequency for .wav file
  assign clk_div_next = (clk_div_ff == DIV_48KHZ) ? '0
                                                  : clk_div_ff + 1;

  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn)
      clk_div_ff <= '0;
    else
      clk_div_ff <= clk_div_next;
  end

  assign sample_val = (clk_div_ff == DIV_48KHZ);

  always @ (posedge clk)
    if (sample_val) begin
      audio_data.push_front(channel_sample_data);
    end

  // UUT
  audio_channel UUT (
    .clk_i         (clk),
    .rstn_i        (rstn),
    .en_i          (channel_en),
    .gen_sel_i     (channel_gen_sel),
    .freq_i        (channel_freq),
    .volume_i      (channel_volume),
    .sample_data_o (channel_sample_data)
  );

endmodule