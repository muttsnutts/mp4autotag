#!/usr/local/bin/ruby

require 'cgi'
require 'uri'
require 'json'

require './lib/search.rb'

$DEBUG_POP = false

cgi = CGI.new
search_str = cgi['search']
if(search_str == nil)
  cgi.out("text/plain") { {"ERROR" => "MUST HAVE SEARCH STRING"}.json }
  exit
end

cgi.out("text/plain") { Search.search(URI.unescape(search_str)).to_json }