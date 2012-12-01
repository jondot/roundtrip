# Roundtrip

Need to push up docs.


## Installation

Add this line to your application's Gemfile:

    gem 'roundtrip'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install roundtrip

## Usage
```
curl -XPOST http://localhost:9292/invoicing/trips
{"id":"cf1999e8bfbd37963b1f92c527a8748e","route":"invoicing","started_at":"2012-11-30T18:23:23.814014+02:00"}
```


```
curl -XPATCH -dcheckpoint=generated.pdf http://localhost:9292/trips/cf1999e8bfbd37963b1f92c527a8748e
{"ok":true}
```

```
curl -XPATCH -dcheckpoint=emailed.customer http://localhost:9292/trips/cf1999e8bfbd37963b1f92c527a8748e
{"ok":true}
```

```
curl -XDELETE http://localhost:9292/trips/cf1999e8bfbd37963b1f92c527a8748e
{"id":"cf1999e8bfbd37963b1f92c527a8748e","route":"invoicing","started_at":"2012-11-30T18:54:20.098477+02:00","checkpoints":[["generated.pdf","2012-11-30T19:08:26.138140+02:00"],
["emailed.customer","2012-11-30T19:12:41.332270+02:00"]]}
```
## Contributing


1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
