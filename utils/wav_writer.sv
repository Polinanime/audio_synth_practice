module wav_writer #(parameter UUT_MODULE = "audio")();

  // Functions to save .wav file
  function automatic void write_wav_number;
    input int number;
    input int chars;
    input int fd;

    begin
      for (int i = 0; i < chars; i++) begin
        $fwrite(fd,"%c", number[7:0]);
        number = number >> 8;
      end
    end

  endfunction

  function automatic void write_wav;
    input int    sample_rate;
    input int    sample_bits;
    input int    sample_channels;
    input int    sample_num;
    input bit [7:0] sample_data [$];
    input string file;

    begin

      int fd;
      int byterate;
      int block_align;
      int subchunk2_size;
      int chunk_size;
      int bytes_per_sample;

      // Open file
      fd = $fopen(file, "wb");

      if (!fd)
        $display("Could not open file");

      // Calculate fields
      byterate       = (sample_rate * sample_channels * sample_bits)/8;
      block_align    = (sample_channels * sample_bits) / 8;
      subchunk2_size = (sample_num  * sample_channels * sample_bits)/8;
      chunk_size = 36 + subchunk2_size;

      bytes_per_sample = sample_bits / 8;

      // chunkId
      $fwrite(fd,"RIFF");

      // chunkSize
      write_wav_number(chunk_size, 4, fd);

      // format
      $fwrite(fd,"WAVE");

      // subchunk1Id
      $fwrite(fd,"fmt ");

      // subchunk1Size
      write_wav_number(16 , 4, fd);

      // audioFormat
      write_wav_number(1 , 2, fd);

      // numChannels
      write_wav_number(sample_channels , 2, fd);

      // sampleRate
      write_wav_number(sample_rate , 4, fd);

      // byteRate
      write_wav_number(byterate , 4, fd);

      // blockAlign
      write_wav_number(block_align, 2, fd);

      // bitsPerSample
      write_wav_number(sample_bits , 2, fd);

      // subchunk2Id
      $fwrite(fd,"data");

      // subchunk2Size
      write_wav_number(subchunk2_size , 4, fd);

      // data
      for (int i=0; i < sample_num; i++)
        write_wav_number(sample_data.pop_back(), bytes_per_sample, fd);

      // Close file
      $fclose(fd);

    end
  endfunction


endmodule