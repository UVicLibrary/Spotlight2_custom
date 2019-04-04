#!/usr/bin/ruby
# -*- coding: utf-8 -*-

require "uri"
require "net/https"
require "base64"
require 'rubygems'
require "json"
require 'rest_client'

url="https://api.sketchfab.com/v3/models"

data = {
    'modelFile'=> FileUploadIO.new("model.stl", "application/octet-stream")
}

uri = URI.parse(url)
p uri
multipart_post = Net::HTTP::Post::MultiPart.new(data)

response = multipart_post.submit(url)

p response.body


# #!/usr/bin/ruby
# # -*- coding: utf-8 -*-
#
# require "uri"
# require "net/https"
# require "base64"
# require 'rubygems'
# require "json"
# require "ruby-multipart-post" # gem install ruby-multipart-post
#
# path="./"
# filename="/model.stl"
# description="Test of the api with a simple model"
# token_api="FF00FF"
# title="Uber Glasses"
# tags="test collada glasses"
# private=1
# password="Tr0b4dor&3"
#
# url="https://api.sketchfab.com/v1/models"
#
# data = {
#     'title'=> title,
#     'description'=> description,
#     'fileModel'=> FileUploadIO.new(path+filename, "application/octet-stream"),
#     'filenameModel'=> filename,
#     'tags'=> tags,
#     'token'=> token_api,
#     'private'=> private,
#     'password'=> password
# }
#
# uri = URI.parse(url)
# p uri
#
# multipart_post = MultiPart::Post.new(data)
# response = multipart_post.submit(url)
#
# p response.body
