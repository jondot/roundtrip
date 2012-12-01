require 'roundtrip/store'
require 'redis'


class Roundtrip::Store::Redis
  def initialize(opts={:redis => {:host => 'localhost'}})
    @conn = opts[:redis][:connection]  || Redis.new(opts[:redis])
  end

  def get(id)
    blob = @conn.get(trip_key(id))
    trip = Marshal.load(blob) if blob
    if trip
      trip.checkpoints = @conn.zrange(checkpoints_key(id), "0", "-1", :withscores => true).map{|pair| [pair[0], Time.at(pair[1])]}
    end
    trip
  end

  def add(trip)
    @conn.multi do
      @conn.set(trip_key(trip.id), Marshal.dump(trip))
      @conn.zadd(route_key(trip.route), trip.started_at.to_i, trip.id)
    end
  end

  def add_checkpoint(trip, at)
    time = Time.now
    @conn.zadd(checkpoints_key(trip.id), time.to_f, at)
    [at, time]
  end

  def remove(trip)
    res = @conn.multi do
      @conn.del(trip_key(trip.id))
      @conn.del(checkpoints_key(trip.id))
      @conn.zrem(route_key(trip.route), trip.id)
    end
    res.count == 3 && res[0] == 1 && res[2] == true
  end

  def pending_trips(prod, older_than=0)
    start_stamp = Time.now.to_i - older_than
    ids = @conn.zrangebyscore(route_key(prod), 0, start_stamp.to_s)
    return [] if ids.empty?

    tripsdata = @conn.mget(ids.map{|k| trip_key(k) })
    tripsdata.map { |blob| Marshal.load(blob) }
  end

  def prune_old_trips(prod, timespan)

  end



private
  def trip_key(trip_id)
    "rt:trip:#{trip_id}"
  end

  def route_key(route)
    "rt:route:#{route}"
  end

  def checkpoints_key(trip_id)
    "rt:cp:#{trip_id}"
  end
end
