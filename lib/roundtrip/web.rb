require 'roundtrip'
require 'roundtrip/store/redis'
require 'roundtrip/metrics/statsd'


require 'sinatra'
require 'json'
require 'atom'

# XXX
# put on heroku
# change url to be provider based at admin
# set up configuration for redis to one of the test instances
# check cross-cycle
#
class Roundtrip::Web < Sinatra::Base

  configure do
    store = Roundtrip::Store::Redis.new(Roundtrip.options)
    stats = Roundtrip::Metrics::Statsd.new(Roundtrip.options)

    set :core, Roundtrip::Core.new(store, stats)
  end

  post '/:route/trips' do
    content_type :json
    route = params[:route]
    must_exist!(route)

    trip = core.start(route)
    # XXX add location: header
    json trip
  end

  patch '/trips/:id' do
    content_type :json
    id = params[:id]
    checkpoint = params[:checkpoint]
    must_exist! id
    must_exist! checkpoint

    core.checkpoint(id, checkpoint)
    json(:ok => true)
  end

  delete '/trips/:id' do
    content_type :json
    id = params[:id]
    must_exist!(id)

    trip = core.end(id)
    json trip
  end

  get '/:route/trips.json' do
    content_type :json
    route = params[:route]
    older_than = params[:older_than_secs]

    must_exist!(route)

    res = core.pending(route, (older_than || 0).to_i)
    json res
  end

  get '/:route/trips.rss' do
    content_type 'text/xml'
    route = params[:route]
    must_exist!(route)

    older_than = params[:older_than_secs]

    res = core.pending(route, (older_than || "0").to_i)

    feed = Atom::Feed.new do |f|
      f.title = "Roundtrip #{route}"
      f.links << Atom::Link.new(:href => "http://example.com/roundtrip/#{route}/")

      res.each do |p|
        f.entries << Atom::Entry.new do |e|
          e.title = p.id
          e.links << Atom::Link.new(:href => "http://example.com/#{p.id}")
          e.id = p.id
          e.updated = p.started_at.iso8601(6)
          e.summary = p.started_at.iso8601(6)
        end
      end
    end
    feed.to_xml
  end

  def core
    settings.core
  end

  def json(obj)
    obj.to_json
  end

  def must_exist!(thing)
    halt 406, {:error => "Parameter `route` must be present."}.to_json unless thing && thing.strip != ""
  end
end


