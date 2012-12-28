
require 'spec_helper'
require 'roundtrip/core'


module Roundtrip
  describe Core do
    let(:trip_id) { 'C0FFEEBABE' }
    let(:trip) do
      Trip.new(trip_id, 'prod', Time.now)
    end

    describe "#start" do
      it "should start" do
        mock(Roundtrip::Trip).generate('prod', nil){ trip }
        store = Object.new
        mock(store).add(trip){true}
        core = Core.new(store)
        core.start('prod').must_equal(trip)
      end
      it "should start with an explicit ID given it was supplied" do
        mock(Roundtrip::Trip).generate('prod', 'id-xyz'){ trip }
        store = Object.new
        mock(store).add(trip){true}
        core = Core.new(store)
        core.start('prod', 'id-xyz').must_equal(trip)
      end
   end

    describe "#checkpoint" do
      it "should add a new checkpoint to a started trip" do
        store = Object.new
        mock(store).get("id-xyz"){ trip }
        time = Time.now
        mock(store).add_checkpoint(trip, 'generate_invoice'){ ['generate_invoice', time] }

        core = Core.new(store)
        t = core.checkpoint('id-xyz', 'generate_invoice')
        t.must_equal ['generate_invoice', time]
      end

      it "should not add a new checkpoint to a missing trip" do
        store = Object.new
        mock(store).get("id-xyz"){ nil }

        core = Core.new(store)
        core.checkpoint('id-xyz', 'generate_invoice').must_be_nil
      end
    end
    describe "#end" do
      it "should not end given it never started" do
        store = Object.new
        mock(store).get('bad-trip'){ nil }
        core = Core.new(store)
        core.end('bad-trip').must_be_nil
      end


      it "should end the exact ID that has been started" do
        t = Time.now
        trip = Trip.new('key-1', 'prod', t)
        mock(Roundtrip::Trip).generate('key-1', nil){ trip }
        store = Object.new
        mock(store).add(trip){ true }
        mock(store).get(trip.id){ trip }
        mock(store).remove(trip){ true }

        core = Core.new(store)

        core.start('key-1')
        core.end('key-1').must_equal(trip)
      end
    end

    describe "#pending" do
      it "should list all open trips" do
        store = Object.new
        pending = [ :foo ]
        mock(store).pending_trips('prod', 0){ pending }

        core = Core.new(store)

        core.pending('prod', 0).must_equal(pending)
      end

    end

    describe "#purge" do
      it "should do nothing given no pending trips" do
        store = Object.new
        pending = []
        mock(store).pending_trips('prod', 0){ pending }

        core = Core.new(store)
        core.purge('prod', 0).must_equal(pending)
      end

      it "should purge pending trips given staleness" do
        store = Object.new
        trip1 = Trip.new('key-1', 'prod', Time.now)
        pending = [trip1]
        mock(store).pending_trips('prod', 30){ pending }
        mock(store).remove(trip1)

        core = Core.new(store)
        core.purge('prod', 30).must_equal(pending)
      end

      it "should purge all pending trips given no staleness" do
        store = Object.new
        trip1 = Trip.new('key-1', 'prod', Time.now)
        pending = [trip1]
        mock(store).pending_trips('prod', 0){ pending }
        mock(store).remove(trip1)

        core = Core.new(store)
        core.purge('prod').must_equal(pending)
      end
    end
  end
end

