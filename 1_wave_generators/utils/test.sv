`include "../../utils/wav_writer.sv"

module tb_audio;

    wav_writer writer();


  localparam DIV_48KHZ = 259;
  localparam DIV_48KHZ_WIDTH = $clog2(DIV_48KHZ);

  localparam FREQ_440HZ = 16'd4723;

  logic clk;
  logic rstn;

  bit [7:0] audio_data [$];

  int sample_rate;
  int sample_bits;
  int sample_channels;

  logic       sample_val;
  logic [7:0] sample_data;

  logic [DIV_48KHZ_WIDTH-1:0] clk_div_ff;
  logic [DIV_48KHZ_WIDTH-1:0] clk_div_next;

  // Generate 12.5 MHz clock
  initial clk <= 0;
  always #40ns clk <= ~clk;

  // Reset
  initial begin
    rstn <= 1'b0;
    repeat(2) @(posedge clk);
    rstn <= 1'b1;
  end


  initial begin
    sample_rate = 48000;
    sample_bits = 8;
    sample_channels = 1;

    repeat(12500000) @(posedge clk);

    writer.write_wav(sample_rate,
              sample_bits,
              sample_channels,
              audio_data.size(),
              audio_data,
              "audio.wav"
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
      audio_data.push_front(sample_data);
    end

    // UUT module instantiation
    
    // There must be a better way to do this 
    // But SV doesnt allow to use a string to instantiate a module((((

    // Also, ifdef-endif makes it even more ugly and complicated
    // But it is the only way to make it work with the wave generators
    
    `ifdef AUDIO_SQUARE
        audio_square UUT (
        .clk_i         (clk),
        .rstn_i        (rstn),
        .freq_i        (FREQ_440HZ),
        .sample_data_o (sample_data)
        );
    `endif

    `ifdef AUDIO_SAW
        audio_saw UUT (
        .clk_i         (clk),
        .rstn_i        (rstn),
        .freq_i        (FREQ_440HZ),
        .sample_data_o (sample_data)
        );
    `endif
    `ifdef AUDIO_SAW_INV
        audio_saw_inv UUT (
            .clk_i         (clk),
            .rstn_i        (rstn),
            .freq_i        (FREQ_440HZ),
            .sample_data_o (sample_data)
        );
    `endif

    `ifdef AUDIO_TRIANGLE
        audio_triangle UUT (
            .clk_i         (clk),
            .rstn_i        (rstn),
            .freq_i        (FREQ_440HZ),
            .sample_data_o (sample_data)
        );
    `endif

    `ifdef AUDIO_SINE
        audio_sine UUT (
            .clk_i         (clk),
            .rstn_i        (rstn),
            .freq_i        (FREQ_440HZ),
            .sample_data_o (sample_data)
        );  
    `endif

    `ifdef AUDIO_NOISE
        audio_noise UUT (
            .clk_i         (clk),
            .rstn_i        (rstn),
            .freq_i        (FREQ_440HZ),
            .sample_data_o (sample_data)
            );
    `endif




endmodule