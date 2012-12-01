require 'statsd'


class Roundtrip::Metrics::Statsd
  def initialize(opts={:statsd => {:host => 'localhost', :port => 8125}})
    @statsd =opts[:statsd][:connection] || ::Statsd.new(opts[:statsd][:host], opts[:statsd][:port])
  end

  def time(route, event, time)
    @statsd.timing("#{route}.#{event}", time)
  end
end

