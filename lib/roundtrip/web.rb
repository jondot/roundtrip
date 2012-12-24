require 'roundtrip'
require 'roundtrip/store/redis'
require 'roundtrip/metrics/statsd'
require 'nokogiri'

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

    trip = core.start(route, id)
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
    builder = Nokogiri::XML::Builder.new do
      root {
        rss(:version => "2.0") {
          channel {
            title "Roundtrip: #{route}"
            description "Roundtrip RSS feed for current trips on route #{route}"
            link "https://github.com/jondot/roundtrip"
            res.each do |p|
              item {
                title   p.id
                guid    p.id
                pubDate p.started_at.iso8601(6)
                description p.started_at.iso8601(6)
                link "http://example.com/#{p.id}"
              }
            end
          }
        }
      }
    end
    builder.to_xml
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


