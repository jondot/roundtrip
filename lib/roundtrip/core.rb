require 'roundtrip/trip'

class Roundtrip::Core
  def initialize(store, metrics=Roundtrip::Metrics::Null.new)
    @store = store
    @metrics = metrics
  end

  def start(route)
    must_be_present! route

    t = Roundtrip::Trip.generate(route)
    @store.add(t)
    t
  end

  def checkpoint(id, at)
    must_be_present! id, at
    trip = @store.get(id)
    if trip
      res = @store.add_checkpoint(trip, at)
      @metrics.time(trip.route, at, msec(res[1] - trip.started_at))
      res
    end
  end

  def end(id)
    must_be_present! id

    trip = @store.get(id)
    if trip
      @store.remove(trip)
      @metrics.time(trip.route, 'end', msec(Time.now - trip.started_at))
    end
    trip
  end

  def pending(route, older_than=0)
    must_be_present! route

    @store.pending_trips(route, older_than)
  end

private
  def msec(floating_delta)
    (floating_delta*1000).floor
  end
  def must_be_present!(*things)
    things.each do |thing|
      raise "parameter must be present" unless thing && thing.strip != ""
    end
  end
end
