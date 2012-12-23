
require 'spec_helper'
require 'roundtrip/raw'


module Roundtrip
  describe Raw do
    
    before do

    end
    describe "select" do

      it "should handle trip start" do
        core = Object.new; socket = Object.new

        mstr = ''
        mock(socket).recv_string(mstr){ |str| str[0..-1] = "S foo.metric" }
        mock(core).send(:start, "foo.metric"){ {:hello => :world} }
        mock(socket).send_string( {:hello => :world}.to_json )
        r = Raw.new(core)
        r.select(socket)
      end

      it "should handle trip start given ID" do
        core = Object.new; socket = Object.new

        mstr = ''
        mock(socket).recv_string(mstr){ |str| str[0..-1] = "S foo.metric 123" }
        mock(core).send(:start, "foo.metric", "123"){ {:hello => :world} }
        mock(socket).send_string( {:hello => :world}.to_json )
        r = Raw.new(core)
        r.select(socket)
      end
      
      it "should handle trip updates" do
        core = Object.new; socket = Object.new

        mstr = ''
        mock(socket).recv_string(mstr){ |str| str[0..-1] = "U foo.metric" }
        mock(core).send(:checkpoint, "foo.metric"){ {:hello => :world} }
        mock(socket).send_string( {:hello => :world}.to_json )
        r = Raw.new(core)
        r.select(socket)
      end

      it "should handle trip end" do
        core = Object.new; socket = Object.new

        mstr = ''
        mock(socket).recv_string(mstr){ |str| str[0..-1] = "E foo.metric" }
        mock(core).send(:end, "foo.metric"){ {:hello => :world} }
        mock(socket).send_string( {:hello => :world}.to_json )
        r = Raw.new(core)
        r.select(socket)
      end

      it "should handle core errors" do
        core = Object.new; socket = Object.new

        mstr = ''
        mock(socket).recv_string(mstr){ |str| str[0..-1] = "E foo.metric" }
        mock(core).send(:end, "foo.metric"){ raise "bad code" }
        mock(socket).send_string( {:error => "bad code" }.to_json )
        r = Raw.new(core)
        r.select(socket)
      end

      it "should handle input errors" do
        core = Object.new; socket = Object.new

        mstr = ''
        mock(socket).recv_string(mstr){ |str| str[0..-1] = "" }
        mock(socket).send_string( {:error => "bad protocol: []" }.to_json )
        r = Raw.new(core)
        r.select(socket)
      end
   end
  end
end

