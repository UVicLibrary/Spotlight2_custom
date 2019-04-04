#!/usr/bin/ruby
# -*- coding: utf-8 -*-

require "uri"
require "net/https"
require "base64"
require 'rubygems'
require "json"
require 'net/http/post/multipart'
require "byebug"

# screenshot="screenshot.jpg"
filename="model.stl"

# url="https://api.sketchfab.com/v3/models"

key = "18e737793f7747c28b86d3c139d42789"


url = URI.parse('https://api.sketchfab.com/v3/models')

http = Net::HTTP.new(uri.host, uri.port)
http.set_debug_output($stdout)

File.open("./model.stl") do |stl|
  req = Net::HTTP::Post::Multipart.new(url, model_params)
    "modelFile" => UploadIO.new(stl, "application/octet-stream", "model.stl")
    req.add_field("Authorization", 'Token 18e737793f7747c28b86d3c139d42789') #add to Headers
    req.add_field("Content-Type", 'application/json')
  res = Net::HTTP.start(url.host, url.port) do |http|
    http.request(req)
  end
end

# model_contents = Base64.encode64(File.read(filename))
#model_contents = File.read(filename)
# model_thumbnail = Base64.encode64(File.read(screenshot))
# data = {
#     'name'=> 'Test Model',
#     'description'=> 'Description',
#     'modelFile'=> model_contents
# }
#
# byebug
#
# uri = URI.parse(url)
# p uri
# http = Net::HTTP.new(uri.host, uri.port)
# http.use_ssl = true
#
# headers = {
#   'Authorization' => 'Token 18e737793f7747c28b86d3c139d42789',
#   'Content-Type' =>'application/json'
# }
#
# multipart_post = MultiPart::Post.new(uri.request_uri, headers)

# request = Net::HTTP::Post.new(uri.request_uri, headers)

#initheader = {'Content-Type' =>'application/json' }

# request.body = data.to_json
# byebug
# #data.to_json
#
# response = http.request(request)
#
# p response.body
