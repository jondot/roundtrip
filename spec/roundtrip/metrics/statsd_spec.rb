require 'spec_helper'
require 'roundtrip/metrics/statsd'
require 'timecop'

module Roundtrip
  describe Metrics::Statsd do
    it "should time checkpoints" do
      trip = Trip.new('trip', 'prod', Time.at(1354366786.0090559))

      statsd = Object.new
      mock(statsd).timing("prod.invoice.created", 2789)
      metrics = Metrics::Statsd.new(:statsd => { :connection => statsd })

      store = Object.new
      mock(store).get('id-xyz'){ trip }
      mock(store).add_checkpoint(trip, 'invoice.created'){ [trip, Time.at(1354366788.7987247)] }

      core = Core.new(store, metrics)
      core.checkpoint('id-xyz', 'invoice.created')
    end

    it "should time end" do
      trip = Trip.new('trip', 'prod', Time.at(1354366786.0090559))

      statsd = Object.new
      mock(statsd).timing("prod.end", 2789)
      metrics = Metrics::Statsd.new(:statsd => { :connection => statsd })

      Timecop.freeze(Time.at(1354366788.7987247)) do
        store = Object.new
        mock(store).get('id-xyz'){ trip }
        mock(store).remove(trip)

        core = Core.new(store, metrics)
        core.end('id-xyz')
      end
    end
  end
end
