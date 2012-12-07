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

You have a couple of options of running Roundtrip.


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

Roundtrip currently supports HTTP as its RPC mechanism (CLI and 0mq are
on the way). This means you
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



## API Usage

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


# Contributing

Fork, implement, add tests, pull request, get my everlasting thanks and a respectable place here :).


# Copyright


Copyright (c) 2012 [Dotan Nahum](http://gplus.to/dotan) [@jondot](http://twitter.com/jondot). See MIT-LICENSE for further details.


