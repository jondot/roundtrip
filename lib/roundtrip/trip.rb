require 'securerandom'
require 'time'


class Roundtrip::Trip
  attr_accessor :id, :route, :started_at, :checkpoints

  def initialize(id, route, started_at)
    self.id = id
    self.route = route
    self.started_at = started_at
    self.checkpoints = []
  end


  def to_json(*a)
    to_h.to_json(*a)
  end

  def to_h
    {
      :id  => id, 
      :route => route, 
      :started_at => started_at.iso8601(6), 
      :checkpoints => checkpoints.map{|cp| [cp[0], cp[1].iso8601(6)] }
    }
  end

  def ==(o)
    o.class == self.class && o.to_h == to_h
  end
  alias_method :eql?, :==

  def self.generate(route)
    new(SecureRandom.hex, route, Time.now)
  end
end
