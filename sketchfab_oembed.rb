#!/usr/bin/ruby
# -*- coding: utf-8 -*-
require 'json'
require 'byebug'
require 'rest_client'

uid = "fa7b1089af344838adcc779268a57960"
# uid = "9fbb222ceb2c455ba72b5a27dc2f1f04"

response = RestClient.get "https://sketchfab.com/oembed?url=https://sketchfab.com/models/" + uid
  puts JSON.parse(response.body)["thumbnail_url"]
  # puts response.headers
