
require 'spec_helper'
require 'roundtrip/trip'


module Roundtrip
  describe Trip do
    describe "::generate" do
      it "should generate with a random ID if none given" do
        t = Trip.generate("foo", nil)
        t.route.must_equal "foo"
        t.id.wont_be_nil
      end
      it "should generate with the specified ID" do
        t = Trip.generate("foo", 'poo')
        t.route.must_equal "foo"
        t.id.must_equal 'poo'
      end
   end
  end
end
