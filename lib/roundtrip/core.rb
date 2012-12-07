require 'roundtrip/trip'

class Roundtrip::Core
  def initialize(store, metrics=Roundtrip::Metrics::Null.new)
    @store = store
    @metrics = metrics
  end

  def start(route, opts={})
    must_be_present! route

    t = Roundtrip::Trip.generate(route, opts)
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
    end_trip(trip) if trip
    trip
  end

  def pending(route, older_than=0)
    must_be_present! route

    @store.pending_trips(route, older_than)
  end

  def purge(route, older_than=0)
    pending_trips = pending(route, older_than)
    pending_trips.each{ |trip| end_trip(trip) }
    pending_trips
  end

private
  def end_trip(trip)
    @store.remove(trip)
    @metrics.time(trip.route, 'end', msec(Time.now - trip.started_at))
  end

  def msec(floating_delta)
    (floating_delta*1000).floor
  end
  def must_be_present!(*things)
    things.each do |thing|
      raise "parameter must be present" unless thing && thing.strip != ""
    end
  end
end
