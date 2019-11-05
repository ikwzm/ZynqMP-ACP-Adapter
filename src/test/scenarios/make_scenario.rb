#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
#---------------------------------------------------------------------------------
#
#       Version     :   0.2.0
#       Created     :   2019/11/4
#       File name   :   make_scneario.rb
#       Author      :   Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
#       Description :   ZynqMP-ACP-Adapter用シナリオ生成スクリプト
#
#---------------------------------------------------------------------------------
#
#       Copyright (C) 2019 Ichiro Kawazome
#       All rights reserved.
# 
#       Redistribution and use in source and binary forms, with or without
#       modification, are permitted provided that the following conditions
#       are met:
# 
#         1. Redistributions of source code must retain the above copyright
#            notice, this list of conditions and the following disclaimer.
# 
#         2. Redistributions in binary form must reproduce the above copyright
#            notice, this list of conditions and the following disclaimer in
#            the documentation and/or other materials provided with the
#            distribution.
# 
#       THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
#       "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
#       LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
#       A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT
#       OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#       SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
#       LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
#       DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
#       THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
#       (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
#       OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# 
#---------------------------------------------------------------------------------
require 'optparse'
require 'pp'
require_relative "../../../Dummy_Plug/tools/Dummy_Plug/ScenarioWriter/axi4"
require_relative "../../../Dummy_Plug/tools/Dummy_Plug/ScenarioWriter/number-generater"
class ScenarioGenerater
  #-------------------------------------------------------------------------------
  # インスタンス変数
  #-------------------------------------------------------------------------------
  attr_reader   :program_name, :program_version
  attr_accessor :name   , :file_name, :test_items
  attr_accessor :acp_model, :acp_data_width, :max_xfer_size
  attr_accessor :axi_model

  #-------------------------------------------------------------------------------
  # initialize
  #-------------------------------------------------------------------------------
  def initialize
    @program_name      = "make_scenario"
    @program_version   = "0.0.3"
    @acp_data_width    = 128
    @max_xfer_size     = 4096
    @axi_model         = nil
    @acp_model         = nil
    @no                = 0
    @name              = "ZYNQMP_ACP_ADAPTER_TEST"
    @file_name         = nil
    @test_items        = []
    @test_item_list    = [:simple_read_test, :random_read_test, :simple_write_test, :random_write_test]
    @opt               = OptionParser.new do |opt|
      opt.program_name = @program_name
      opt.version      = @program_version
      opt.on("--verbose"              ){|val| @verbose   = true}
      opt.on("--name       STRING"    ){|val| @name      = val }
      opt.on("--output     FILE_NAME" ){|val| @file_name = val }
      opt.on("--simple_read_test"     ){|val| @test_items.push(:simple_read_test ) }
      opt.on("--random_read_test"     ){|val| @test_items.push(:random_read_test ) }
      opt.on("--simple_write_test"    ){|val| @test_items.push(:simple_write_test) }
      opt.on("--random_write_test"    ){|val| @test_items.push(:random_write_test) }
    end
  end
  #-------------------------------------------------------------------------------
  # parse_options
  #-------------------------------------------------------------------------------
  def parse_options(argv)
    @opt.parse(argv)
  end
  #-------------------------------------------------------------------------------
  # スレーブ側とマスター側のライトトランザクションを生成するメソッド.
  #-------------------------------------------------------------------------------
  def gen_write(io, axi_addr, axi_data, axi_seq, acp_seq)
    axi_tran = @axi_model.write_transaction.clone({:Address => axi_addr, :Data => axi_data})
    io.print @axi_model.execute(axi_tran, axi_seq)
    acp_addr   = axi_addr
    data_pos   = 0
    remain_len = axi_data.length
    resp_start_event = :ADDR_XFER
    while(remain_len > 0) do
      if ((acp_addr % 64) == 0) then
        xfer_len = (remain_len < 64) ? 16 : 64
      else
        xfer_len = 16-(acp_addr % 16)
      end
      if (remain_len < xfer_len) then
        xfer_len = remain_len
      end
      resp_delay_cycle = (xfer_len > 16) ? 4 : 1
      acp_data = axi_data[data_pos, xfer_len]
      acp_tran = @acp_model.write_transaction.clone({:Address => acp_addr, :Data => acp_data})
      new_seq  = acp_seq.clone({:ResponseStartEvent => resp_start_event, :ResponseDelayCycle => resp_delay_cycle})
      io.print @acp_model.execute(acp_tran, new_seq)
      remain_len = remain_len - xfer_len
      acp_addr   = acp_addr   + xfer_len
      data_pos   = data_pos   + xfer_len
      resp_start_event = :NO_WAIT
    end
  end
  #-------------------------------------------------------------------------------
  # スレーブ側とマスター側のリードトランザクションを生成するメソッド.
  #-------------------------------------------------------------------------------
  def gen_read(io, axi_addr, axi_data, axi_seq, acp_seq)
    if (((axi_addr % 16) + axi_data.length) <= 16) then
      boundary_size = 16
    else
      boundary_size = 64
    end
    pre_len  = axi_addr % boundary_size
    post_len = (boundary_size-1) - ((axi_data.length + pre_len - 1) % boundary_size)
    acp_addr = axi_addr - pre_len
    acp_data = Array.new(pre_len, 0) + axi_data + Array.new(post_len, 0)
    axi_tran = @axi_model.read_transaction.clone({:Address => axi_addr, :Data => axi_data})
    acp_tran = @acp_model.read_transaction.clone({:Address => acp_addr, :Data => acp_data})
    io.print @axi_model.execute(axi_tran, axi_seq)
    io.print @acp_model.execute(acp_tran, acp_seq)
  end
  #-------------------------------------------------------------------------------
  # タイミングをランダムに生成するメソッド.
  #-------------------------------------------------------------------------------
  def gen_randam_sequence(default_sequence)
  end
  #-------------------------------------------------------------------------------
  # シンプルリードトランザクションテスト
  #-------------------------------------------------------------------------------
  def test_simple_read(io)
    test_major_num    = 1
    test_minor_num    = 1
    address_pattern   = (0..64).step(4).to_a
    size_pattern      = [1,4,8,12,16,20,32,48,64,96,128,192,256]
    size_pattern.each { |size|
      address_pattern.each { |axi_addr|
        title   = sprintf("%s.%d.%-5d", @name.to_s, test_major_num, test_minor_num)
        test_minor_num = test_minor_num + 1
        if ((axi_addr % @max_xfer_size) + size) > @max_xfer_size then
          size = @max_xfer_size - (axi_addr % @max_xfer_size)
        end
        axi_data = (1..size).collect{rand(256)}
        axi_seq  = @axi_model.default_sequence.clone({})
        acp_seq  = @acp_model.default_sequence.clone({})
        io.print "---\n"
        io.print "- N : \n"
        io.print "  - SAY : ", title, sprintf(" READ  ADDR=0x%08X, SIZE=%-3d\n", axi_addr, size)

        if (((axi_addr % 16) + axi_data.length) <= 16) then
          boundary_size = 16
        else
          boundary_size = 64
        end
        pre_len  = axi_addr % boundary_size
        post_len = (boundary_size-1) - ((axi_data.length + pre_len - 1) % boundary_size)
        acp_addr = axi_addr - pre_len
        acp_data = Array.new(pre_len, 0) + axi_data + Array.new(post_len, 0)
        axi_tran = @axi_model.read_transaction.clone({:Address => axi_addr, :Data => axi_data})
        acp_tran = @acp_model.read_transaction.clone({:Address => acp_addr, :Data => acp_data})
        io.print @axi_model.execute(axi_tran, axi_seq)
        io.print @acp_model.execute(acp_tran, acp_seq)
      }
    }
    io.print "---\n"
  end
  #-------------------------------------------------------------------------------
  # ランダムリードトランザクションテスト
  #-------------------------------------------------------------------------------
  def test_random_read(io)
    test_major_num           = 2
    addr_start_event_pattern = [:ADDR_VALID, :NO_WAIT  ]
    data_start_event_pattern = [:ADDR_VALID, :ADDR_XFER]
    resp_start_event_pattern = [:ADDR_VALID, :ADDR_XFER, :FIRST_DATA_XFER, :LAST_DATA_XFER]
    addr_delay_cycle_pattern = Dummy_Plug::ScenarioWriter::RandomNumberGenerater.new([0,0,0,0,0,1,1,2,3,4])
    data_xfer_pattern        = Dummy_Plug::ScenarioWriter::RandomNumberGenerater.new([0,0,0,0,0,1,1,2,3,4])
    resp_delay_cycle_pattern = Dummy_Plug::ScenarioWriter::RandomNumberGenerater.new([0,0,0,0,0,1,1,2,3,4])
    (1..1000).each {|test_minor_num|  
      title    = sprintf("%s.%d.%-5d", @name.to_s, test_major_num, test_minor_num)
      axi_addr = rand(@max_xfer_size) + (rand(0xFFFFF) * 0x1000)
      axi_id   = rand(2**@axi_model.width.id-1)
      axi_cache= rand(15)
      size     = rand(255)+1
      if ((axi_addr % @max_xfer_size) + size) > @max_xfer_size then
        size = @max_xfer_size - (axi_addr % @max_xfer_size)
      end

      axi_data  = (1..size).collect{rand(256)}
      axi_seq   = @axi_model.default_sequence.clone({
        :AddrStartEvent     => addr_start_event_pattern[rand(addr_start_event_pattern.size)],
        :DataStartEvent     => data_start_event_pattern[rand(data_start_event_pattern.size)],
        :ResponseStartEvent => resp_start_event_pattern[rand(resp_start_event_pattern.size)],
        :AddrDelayCycle     => addr_delay_cycle_pattern.next,
        :DataXferPattern    => data_xfer_pattern.next,
        :ResponseDeleyCycle => resp_delay_cycle_pattern.next
      })
      acp_seq   = @acp_model.default_sequence.clone({
        :AddrStartEvent     => addr_start_event_pattern[rand(addr_start_event_pattern.size)],
        :DataStartEvent     => data_start_event_pattern[rand(data_start_event_pattern.size)],
        :ResponseStartEvent => resp_start_event_pattern[rand(resp_start_event_pattern.size)],
        :AddrDelayCycle     => addr_delay_cycle_pattern.next,
        :DataXferPattern    => data_xfer_pattern.next,
        :ResponseDeleyCycle => resp_delay_cycle_pattern.next
      })
      io.print "---\n"
      io.print "- N : \n"
      io.print "  - SAY : ", title, sprintf(" READ  ADDR=0x%08X, SIZE=%-3d\n", axi_addr, size)

      if (((axi_addr % 16) + axi_data.length) <= 16) then
        boundary_size = 16
      else
        boundary_size = 64
      end
      pre_len  = axi_addr % boundary_size
      post_len = (boundary_size-1) - ((axi_data.length + pre_len - 1) % boundary_size)
      acp_addr = axi_addr - pre_len
      acp_data = Array.new(pre_len, 0) + axi_data + Array.new(post_len, 0)
      axi_tran = @axi_model.read_transaction.clone({:Address => axi_addr, :Data => axi_data, :ID => axi_id, :Cache => axi_cache})
      acp_tran = @acp_model.read_transaction.clone({:Address => acp_addr, :Data => acp_data, :ID => axi_id, :Cache => axi_cache})
      io.print @axi_model.execute(axi_tran, axi_seq)
      io.print @acp_model.execute(acp_tran, acp_seq)
    }
    io.print "---\n"
  end
  #-------------------------------------------------------------------------------
  # シンプルライトトランザクションテスト
  #-------------------------------------------------------------------------------
  def test_simple_write(io)
    test_major_num    = 3
    test_minor_num    = 1
    address_pattern   = (0..64).step(4).to_a
    size_pattern      = [1,4,8,12,16,20,32,48,64,96,128,192,256]
    size_pattern.each { |size|
      address_pattern.each { |axi_addr|
        title   = sprintf("%s.%d.%-5d", @name.to_s, test_major_num, test_minor_num)
        test_minor_num = test_minor_num + 1
        if ((axi_addr % @max_xfer_size) + size) > @max_xfer_size then
          size = @max_xfer_size - (axi_addr % @max_xfer_size)
        end
        axi_data = (1..size).collect{rand(256)}
        axi_seq  = @axi_model.default_sequence.clone({})
        io.print "---\n"
        io.print "- N : \n"
        io.print "  - SAY : ", title, sprintf(" WRITE ADDR=0x%08X, SIZE=%-3d\n", axi_addr, size)

        axi_tran = @axi_model.write_transaction.clone({:Address => axi_addr, :Data => axi_data})
        io.print @axi_model.execute(axi_tran, axi_seq)
        acp_addr   = axi_addr
        data_pos   = 0
        remain_len = axi_data.length
        resp_start_event = :ADDR_XFER

        while(remain_len > 0) do
          if ((acp_addr % 64) == 0) then
            xfer_len = (remain_len < 64) ? 16 : 64
          else
            xfer_len = 16-(acp_addr % 16)
          end
          if (remain_len < xfer_len) then
            xfer_len = remain_len
          end
          resp_delay_cycle = (xfer_len > 16) ? 4 : 1
          acp_data = axi_data[data_pos, xfer_len]
          acp_tran = @acp_model.write_transaction.clone({:Address => acp_addr, :Data => acp_data})
          acp_seq  = @acp_model.default_sequence.clone({:ResponseStartEvent => resp_start_event, :ResponseDelayCycle => resp_delay_cycle})
          io.print @acp_model.execute(acp_tran, acp_seq)
          remain_len = remain_len - xfer_len
          acp_addr   = acp_addr   + xfer_len
          data_pos   = data_pos   + xfer_len
          resp_start_event = :NO_WAIT
        end
      }
    }
    io.print "---\n"
  end
  #-------------------------------------------------------------------------------
  # ランダムライトトランザクションテスト
  #-------------------------------------------------------------------------------
  def test_random_write(io)
    test_major_num           = 4
    addr_start_event_pattern = [:ADDR_VALID, :NO_WAIT  ]
    data_start_event_pattern = [:ADDR_VALID, :ADDR_XFER]
    resp_start_event_pattern = [:ADDR_VALID, :ADDR_XFER, :FIRST_DATA_XFER, :LAST_DATA_XFER]
    addr_delay_cycle_pattern = Dummy_Plug::ScenarioWriter::RandomNumberGenerater.new([0,0,0,0,0,1,1,2,3,4])
    data_xfer_pattern        = Dummy_Plug::ScenarioWriter::RandomNumberGenerater.new([0,0,0,0,0,1,1,2,3,4])
    resp_delay_cycle_pattern = Dummy_Plug::ScenarioWriter::RandomNumberGenerater.new([0,0,0,0,0,1,1,2,3,4])
    (1..1000).each {|test_minor_num|  
      title    = sprintf("%s.%d.%-5d", @name.to_s, test_major_num, test_minor_num)
      axi_addr = rand(@max_xfer_size) + (rand(0xFFFFF) * 0x1000)
      axi_id   = rand(2**@axi_model.width.id-1)
      axi_cache= rand(15)
      size     = rand(255)+1
      if ((axi_addr % @max_xfer_size) + size) > @max_xfer_size then
        size = @max_xfer_size - (axi_addr % @max_xfer_size)
      end
      axi_data = (1..size).collect{rand(256)}
      axi_seq  = @axi_model.default_sequence.clone({
        :AddrStartEvent     => addr_start_event_pattern[rand(addr_start_event_pattern.size)],
        :DataStartEvent     => data_start_event_pattern[rand(data_start_event_pattern.size)],
        :ResponseStartEvent => resp_start_event_pattern[rand(resp_start_event_pattern.size)],
        :AddrDelayCycle     => addr_delay_cycle_pattern.next,
        :DataXferPattern    => data_xfer_pattern.next,
        :ResponseDeleyCycle => resp_delay_cycle_pattern.next
      })
      io.print "---\n"
      io.print "- N : \n"
      io.print "  - SAY : ", title, sprintf(" WRITE ADDR=0x%08X, SIZE=%-3d\n", axi_addr, size)

      axi_tran = @axi_model.write_transaction.clone({:Address => axi_addr, :Data => axi_data, :ID => axi_id, :Cache => axi_cache})
      io.print @axi_model.execute(axi_tran, axi_seq)
      acp_addr   = axi_addr
      data_pos   = 0
      remain_len = axi_data.length
      resp_start_event = :ADDR_XFER

      while(remain_len > 0) do
        if ((acp_addr % 64) == 0) then
          xfer_len = (remain_len < 64) ? 16 : 64
        else
          xfer_len = 16-(acp_addr % 16)
        end
        if (remain_len < xfer_len) then
          xfer_len = remain_len
        end
        resp_delay_cycle = (xfer_len > 16) ? 16 : 4
        acp_data = axi_data[data_pos, xfer_len]
        acp_tran = @acp_model.write_transaction.clone({:Address => acp_addr, :Data => acp_data, :ID => axi_id, :Cache => axi_cache})
        acp_seq  = @acp_model.default_sequence.clone({:ResponseStartEvent => resp_start_event, :ResponseDelayCycle => resp_delay_cycle})
        io.print @acp_model.execute(acp_tran, acp_seq)
        remain_len = remain_len - xfer_len
        acp_addr   = acp_addr   + xfer_len
        data_pos   = data_pos   + xfer_len
        resp_start_event = :NO_WAIT
      end
    }
    io.print "---\n"
  end
  #-------------------------------------------------------------------------------
  # 
  #-------------------------------------------------------------------------------
  def generate
    if @file_name == nil then
        @file_name = sprintf("zynqmp_acp_adapter_test.snr");
    end
    if @test_items == []
      @test_items = @test_item_list
    end
    if @axi_model == nil
      @axi_model = Dummy_Plug::ScenarioWriter::AXI4::Master.new("AXI", {
        :ID_WIDTH      =>  4,
        :ADDR_WIDTH    => 32,
        :DATA_WIDTH    => @acp_data_width,
        :MAX_TRAN_SIZE => @max_xfer_size  
      })
    end
    if @acp_model == nil
      @acp_model = Dummy_Plug::ScenarioWriter::AXI4::Slave.new("ACP", {
        :ID_WIDTH      =>  4,
        :ADDR_WIDTH    => 32,
        :DATA_WIDTH    => @acp_data_width,
        :MAX_TRAN_SIZE => @max_xfer_size  
      })
    end
    title = @name.to_s;
    io = open(@file_name, "w")
    io.print "---\n"
    io.print "- N : \n"
    io.print "  - SAY : ", title, "\n"
    @test_items.each {|item|
        test_simple_read(io)  if (item == :simple_read_test )
        test_random_read(io)  if (item == :random_read_test )
        test_simple_write(io) if (item == :simple_write_test)
        test_random_write(io) if (item == :random_write_test)
    }
  end
end


gen = ScenarioGenerater.new
gen.parse_options(ARGV)
gen.generate