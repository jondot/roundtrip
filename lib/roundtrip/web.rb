require 'roundtrip'
require 'roundtrip/store/redis'
require 'roundtrip/metrics/statsd'


require 'sinatra'
require 'json'

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

  post '/trips' do
    content_type :json
    route = params[:route]
    must_exist!(route)

    id = params[:id]

    trip = core.start(route, :id => id)
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

  delete '/trips' do
    # XXX nastily un-dry. will fix later
    content_type :json
    route = params[:route]
    older_than = params[:older_than_secs]

    must_exist!(route)

    res = core.purge(route, (older_than || 0).to_i)

    json res
  end

  get '/trips.json' do
    content_type :json
    route = params[:route]
    older_than = params[:older_than_secs]

    must_exist!(route)

    res = core.pending(route, (older_than || 0).to_i)
    json res
  end



  get '/trips.rss' do
    content_type 'text/xml'
    route = params[:route]
    must_exist!(route)

    older_than = params[:older_than_secs]

    res = core.pending(route, (older_than || "0").to_i)
    "broken"


    #
    # XXX ratom is using libxml-ruby which doesn't work with JRuby,
    # use rabl/other instead.
    #
    # feed = Atom::Feed.new do |f|
    #   f.title = "Roundtrip #{route}"
    #   f.links << Atom::Link.new(:href => "http://example.com/roundtrip/#{route}/")

    #   res.each do |p|
    #     f.entries << Atom::Entry.new do |e|
    #       e.title = p.id
    #       e.links << Atom::Link.new(:href => "http://example.com/#{p.id}")
    #       e.id = p.id
    #       e.updated = p.started_at.iso8601(6)
    #       e.summary = p.started_at.iso8601(6)
    #     end
    #   end
    # end
    # feed.to_xml
  end

private
  def core
    settings.core
  end

  def json(obj)
    obj.to_json
  end

  def must_exist!(thing)
    # XXX say which param. accept :param => val hash
    halt 406, {:error => "Parameter must be present."}.to_json unless thing && thing.strip != ""
  end
end


