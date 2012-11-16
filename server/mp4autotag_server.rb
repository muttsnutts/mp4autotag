#!/usr/local/bin/ruby

require 'webrick'
require './lib/search_servlet.rb'
require './lib/show_servlet.rb'
require './lib/movie_servlet.rb'

$DEBUG_POP = true

class MP4AutotagServer
  def initialize
    @port = 8080
    @doc_root = Dir::pwd
    @server_name = Socket.gethostname
    @ip_addr = IPSocket.getaddress(@server_name)
    @server = WEBrick::HTTPServer.new(
      {
        :Port         => @port,
        :DocumentRoot => @doc_root
      }
    )
  end
  def now
    return Time.now.to_s.sub(/ [\-\+][0-9]{4}$/, '')
  end
  def start
    trap("INT"){ @server.shutdown }
    puts "[%s] INFO  Running on %s(%s:%s)" % [self.now, @server_name, @ip_addr, @port]
    @server.mount '/search', SearchServlet
    @server.mount '/movie', MovieServlet
    @server.mount '/show', ShowServlet
    @server.start
  end
end

s = MP4AutotagServer.new
s.start