# Roundtrip

Roundtrip is a business process tracking and measurement service
especially useful for tracking distributed systems and services.


For a simple and useful explanation, check out [this blog
post](http://blog.paracode.com/2012/12/02/tracking-your-business/)
before you start.


<img src="https://github.com/jondot/roundtrip/raw/master/examples/roundtrip-schema.png" />

With it, you can answer these questions, in real-time:

* How is each part of my processing pipeline performing? How is the
entire pipeline performing?
* What out of my running transactions didn't end? isn't ending within X
amount of time?


## Installation

You have a couple of options of running Roundtrip. It runs fine on MRI
1.9.x, and JRuby in 1.9 compatibility mode.


### Heroku

Roundtrip comes with easy heroku integration.

    $ git clone git://github.com/jondot/roundtrip.git
    $ cd roundtrip
    $ bundle install
    $ heroku create

Now configure Redis and Statsd through `config.ru` (with Heroku, you
can give the free-tier RedisToGo a try).

Next, push to your new Heroku app.

    $ git add -f Gemfile.lock
    $ git commit -am "this becomes a dedicated web project now"
    $ git push heroku master
    

### Clone and run

Roundtrip currently supports HTTP and zeromq as its RPC mechanisms.


For HTTP, this means you
can host it using your favorite battle-tested Ruby stack -- anything that can
run a Rack application.

    $ git clone git://github.com/jondot/roundtrip.git
    $ cd roundtrip
    $ bundle

Now feel free to edit `config.ru` for Redis and Statsd configuration.

    $ bundle exec rackup

### Install gem

You can install the `roundtrip` gem, and then use the web interface
within your existing Rack applications (for example, in Rails, you can
mount it).

    $ gem install roundtrip

```ruby
require 'roundtrip'
# set up the default Redis and Statsd components
Roundtrip.options[:redis] = { :host  => 'localhost' }
Roundtrip.options[:statsd] = { :host => 'localhost', :port => 8125 }

require 'roundtrip/web'
# now mount/run Roundtrip::Web
```


### Running the raw zeromq receptor

The benefits of using zeromq instead of HTTP are to avoid the overhead that typically
comes with HTTP, and provide a leaner, meaner way to input trip events
into the system.

On a modest VM, we can have a stable ~ 160 sessions/sec, where each session
starts, has 3 checkpoint updates, and ends. 

See more, or run benchmarks yourself in `benchmark/zeromq_burnin`.

Though it has been furiously tested, the zeromq receptor haven't gotten much production time, so edges might
be rough (so far so good). Please feel free to report back any problems via Github
Issues.


After installing roundtrip as a gem, you can run the zeromq receptor
like so:

    $ roundtrip raw --port 5160 --redis localhost:6379 --statsd localhost:8125

The parameters provided above are the defaults that will be taken if you just
run `roundtrip raw`.



## API Usage over HTTP

I'll use `curl` just for illustration purposes. You should use what ever
HTTP library you feel comfertable with, within your code.

For usage examples on various platforms check out `/examples`.


Supply your own ID

```
curl -XPOST -d id=id-xyz&route=invoicing http://localhost:9292/trips
{"id":"id-xyz","route":"invoicing","started_at":"2012-11-30T18:23:23.814014+02:00"}
```

Or let roundtrip generate one for you

```
curl -XPOST -d route=invoicing http://localhost:9292/trips
{"id":"cf1999e8bfbd37963b1f92c527a8748e","route":"invoicing","started_at":"2012-11-30T18:23:23.814014+02:00"}
```


Using the generated ID, lets add checkpoints:

```
curl -XPATCH -dcheckpoint=generated.pdf http://localhost:9292/trips/cf1999e8bfbd37963b1f92c527a8748e
{"ok":true}
```

```
curl -XPATCH -dcheckpoint=emailed.customer http://localhost:9292/trips/cf1999e8bfbd37963b1f92c527a8748e
{"ok":true}
```

Let's finish this off, don't forget to do something with the JSON you
get back.

```
curl -XDELETE http://localhost:9292/trips/cf1999e8bfbd37963b1f92c527a8748e
{"id":"cf1999e8bfbd37963b1f92c527a8748e","route":"invoicing","started_at":"2012-11-30T18:54:20.098477+02:00","checkpoints":[["generated.pdf","2012-11-30T19:08:26.138140+02:00"],
["emailed.customer","2012-11-30T19:12:41.332270+02:00"]]}
```

## API Usage over raw TCP (zeromq)


Roundtrip implements an RPC/serialization protocol over zeromq, using
the simple [REQ/REP](http://zguide.zeromq.org/page:all#Messaging-Patterns) pattern.

All replies are serialized back as `json`. Though zeromq has better performance
over HTTP, it is strongly advised to have prior experience with zeromq, and to
use a reliable client.

See `examples/zeromq_client` as a guideline for such a client supporting
server crashes, and automatic retries.


### Wire Protocol Description

Start a trip

    S metric.name.foo i-have-an-id-optional

Update a trip with checkpoints

    U metric.name.foo checkpoint.name

End a trip

    E metric.name.foo


### Using `zeromq_client`

For a quick start check out the client in `examples/zeromq_client.rb`.

Here is a typical session you can run with it from the command line (I
have abbreviated long strings such as ID and timestamps for
demonstration purposes).

    $ ruby zeromq_client.rb S foo.metric
    {"id":"04e...f2a","route":"foo.metric","started_at":"...","checkpoints":[]}

    $ ruby zeromq_client.rb U 04e...f2a saved.pdf
    ["saved.pdf","2012-12-23..."]

    $ ruby zeromq_client.rb E 04e...f2a         
    {"id":"04e...f2a","route":"foo.metric","started_at":"...","checkpoints":[["saved.pdf","..."]]}

This represents a complete trip.

# Contributing

Fork, implement, add tests, pull request, get my everlasting thanks and a respectable place here :).


# Copyright


Copyright (c) 2012 [Dotan Nahum](http://gplus.to/dotan) [@jondot](http://twitter.com/jondot). See MIT-LICENSE for further details.


