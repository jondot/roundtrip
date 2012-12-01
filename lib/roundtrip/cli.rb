require 'roundtrip'
require 'thor'
require 'roundtrip/store/redis'

class Roundtrip::CLI < Thor

  desc "start [ROUTE]", "starts a new trip on a given route"
  def start(route)
    t = core.start(route)
    say t.to_h
  end

  desc "end [TRIP_ID]", "ends a trip"
  def end(trip_id)
    t = core.end(trip_id)
    say t.to_h
  end

private 
  def core
    @core = Roundtrip::Core.new(Roundtrip::Store::Redis.new)
  end
end
