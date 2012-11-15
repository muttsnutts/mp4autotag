#!/usr/local/bin/ruby

require 'webrick'
require './mp4autotag_search.rb'

class MP4AutotagServer
  def initialize
    @server = WEBrick::HTTPServer.new(
      {
        :Port         => 8080,
        :DocumentRoot => Dir::pwd
      }
    )
  end
  def start
    trap("INT"){ @server.shutdown }
    @server.mount '/search', MP4AutotagSearch
    @server.start
  end
end

s = MP4AutotagServer.new
s.start