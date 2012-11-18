#!/usr/local/bin/ruby

require 'cgi'
require 'uri'

$LOAD_PATH.unshift("./lib")
require 'json'

require './lib/search.rb'

$DEBUG_POP = false
$OUT_FMT = '.json'

cgi = CGI.new
search_str = cgi['search']
if(search_str == "")
  cgi.out("text/html") { File.read('mp4autotag_cgi.html') }
  exit
end

#if(/\.json/i.match($OUT_FMT) != nil)
  cgi.out("text/plain") { Search.search(URI.unescape(search_str)).to_json }
#end