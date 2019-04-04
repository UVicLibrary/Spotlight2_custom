require 'json'
require 'iiif/presentation'
require 'byebug'

obj = File.read("test.json")
m = IIIF::Service.parse(JSON.parse(obj))
puts m.to_json(pretty: true)
