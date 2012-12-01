require 'spec_helper'
require 'roundtrip/store/redis'
require 'redis'
require 'redis/namespace'
require 'timecop'


# dirty test. requires running a local redis
# todo: check how redis rb  does its tests. (and how integrates with travis-ci)
module Roundtrip
  describe Store::Redis do

    before do
      @redis = ::Redis::Namespace.new('roundtrip-testing', :redis => Redis.new)
      ks = @redis.keys "rt:*"
      @redis.pipelined do
        ks.each{ |k| @redis.del k }
      end
    end

    let(:store){ Store::Redis.new({ :redis => { :connection => @redis }}) }

    it "should add and get trips" do
      t = Trip.new('trip', 'prod', Time.now)
      store.add(t)
      store.get(t.id).must_equal(t)
    end

    it "should get a trip by ID" do
      t = Trip.new('trip', 'prod', Time.now)
      id = store.add(t)

      r = store.get('trip')
      r.id.must_equal 'trip'
      r.route.must_equal 'prod'
    end

    it "should remove a trip by ID" do
      t = Trip.new('trip', 'prod', Time.now)
      id = store.add(t)
      store.remove(t).must_equal(true)
    end

    it "should add a checkpoint" do
      t = Trip.new('trip', 'id-xyz', Time.now)
      store.add(t)
      time = Time.now
      Timecop.freeze(time) do
        store.add_checkpoint(t, 'generate.invoice')
        trip = store.get(t.id)
        checkpoint, ts = trip.checkpoints[0]
        checkpoint.must_equal 'generate.invoice'
        ts.to_f.must_equal time.to_f
      end
    end


    describe "#pending_trips" do
      it "should fetch pending trips" do
        t = Trip.new('trip', 'prod', Time.now)
        id = store.add(t)
        pending = store.pending_trips('prod')
        pending.first.must_equal t
      end

      it "should return empty for nonexisting route" do
        t = Trip.new('trip', 'prod', Time.now)
        id = store.add(t)
        pending = store.pending_trips('nonexisting')
        pending.must_equal []
      end

      it "should fetch pending trips older than a point in time" do
        t = Trip.new('trip', 'prod', Time.now-400)
        id = store.add(t)
        pending = store.pending_trips('prod', 300)
        pending.first.must_equal t
      end

    end

    it "should not have side-effects" do
      t = Trip.new('trip', 'prod', Time.now)
      id = store.add(t)
      store.remove(t).must_equal(true)
      store.pending_trips('prod').must_equal []
    end
  end
end
