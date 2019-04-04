#!/usr/bin/ruby
# -*- coding: utf-8 -*-
require 'json'
require 'byebug'
require 'rest_client'

url="https://api.sketchfab.com/v3/models"

response = RestClient.post("https://api.sketchfab.com/v3/models",
{:modelFile => File.new("model.stl", 'rb'), :name => 'Title', :description => 'Description', :isPublished => "false"},
{:Authorization => 'Token 958b82879ec04945bba0cbcf7f4b691c', accept: :json})
puts response
uid = JSON.parse(response.body)["uid"] + "\n"
puts uid
