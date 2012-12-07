
require 'spec_helper'
require 'roundtrip/trip'


module Roundtrip
  describe Trip do
    describe "::generate" do
      it "should generate with a random ID if none given" do
        t1 = Trip.generate("foo")
        t2 = Trip.generate("foo", :invalid_option => 'poo')
        t1.route.must_equal "foo"
        t1.id.wont_equal t2.id
      end
      it "should generate with the specified ID" do
        t = Trip.generate("foo", :id => 'poo')
        t.route.must_equal "foo"
        t.id.must_equal 'poo'
      end
   end
  end
end
