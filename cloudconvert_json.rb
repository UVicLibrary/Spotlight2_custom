#!/usr/bin/ruby
# -*- coding: utf-8 -*-
require 'json'
require 'byebug'
require 'rest_client'


response = RestClient.post("https://api.cloudconvert.com/v1/process",
  {
    Authorization: Bearer "NdGMEU0cnIPNvUQbdf9xQYT82cQT7SnWVcWSwRqedGdQLZ2EJPm8Q34glw6c5m5z",
    "inputformat": "pdf",
    "outputformat": "jpg"
  })

response = RestClient.post("https://api.cloudconvert.com/v1/convert",
  {
    "apikey": "NdGMEU0cnIPNvUQbdf9xQYT82cQT7SnWVcWSwRqedGdQLZ2EJPm8Q34glw6c5m5z",
    "input": "upload",
    "url": "#{File.join(Dir.pwd, "first_page.pdf")}",
    "inputformat": "pdf",
    "outputformat": "jpg",
    "file": "first_page.pdf",
    "download": "true"
  })

  puts response.inspect
