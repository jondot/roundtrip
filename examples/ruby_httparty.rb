require 'httparty'

#
# run Roundtrip on localhost:9292 (default rack).
#

resp = HTTParty.post 'http://localhost:9292/invoicing/trips'

# carry this ID around with you.
id = resp["id"]

HTTParty.patch "http://localhost:9292/trips/#{id}", :query => { :checkpoint => 'generate.pdf' }
HTTParty.patch "http://localhost:9292/trips/#{id}", :query => { :checkpoint => 'create.invoice' }

resp = HTTParty.delete "http://localhost:9292/trips/#{id}"

puts resp

