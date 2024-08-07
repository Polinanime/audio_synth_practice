`timescale 1ns/1ps
`define AUDIO_MUSIC
`include "../utils/wav_writer.sv"

module tb_music();

  wav_writer writer();

  localparam DIV_48KHZ = 260 - 1;
  localparam DIV_48KHZ_WIDTH = $clog2(DIV_48KHZ);

  localparam CYCLE = 2 * 12500000;

  localparam G4_FREQ  = 16'd4208; // 392 Hz
  localparam Dd4_FREQ = 16'd3339; // 311.1 Hz
  localparam Ad4_FREQ = 16'd5005; // 466.2 Hz



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

  logic       sample_val;


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

    channel_gen_sel = 3'd4;
    channel_volume  = 16'hff;

    channel_en   = '1;
    channel_freq = G4_FREQ;
    repeat(CYCLE/8) @(posedge clk);
    channel_en   = '0;

    repeat(CYCLE/8) @(posedge clk);
    channel_en   = '1;
    repeat(CYCLE/8) @(posedge clk);
    channel_en   = '0;

    repeat(CYCLE/8) @(posedge clk);
    channel_en   = '1;
    repeat(CYCLE/8) @(posedge clk);
    channel_en   = '0;

    repeat(CYCLE/8) @(posedge clk);
    channel_en   = '1;
    channel_freq = Dd4_FREQ;

    repeat(CYCLE/8) @(posedge clk);
    channel_freq = Ad4_FREQ;

    repeat(CYCLE/8) @(posedge clk);
    channel_freq = G4_FREQ;
    repeat(CYCLE/8) @(posedge clk);
    channel_en   = '0;

    repeat(CYCLE/8) @(posedge clk);
    channel_en   = '1;
    channel_freq = Dd4_FREQ;

    repeat(CYCLE/8) @(posedge clk);
    channel_freq = Ad4_FREQ;

    repeat(CYCLE/8) @(posedge clk);
    channel_freq = G4_FREQ;
    repeat(CYCLE/8) @(posedge clk);
    channel_en   = '0;

    sample_rate = 48000;
    sample_bits = 8;
    sample_channels = 1;
    sample_num = audio_data.size();

    writer.write_wav(sample_rate,
              sample_bits,
              sample_channels,
              sample_num,
              audio_data,
              "music.wav"
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
