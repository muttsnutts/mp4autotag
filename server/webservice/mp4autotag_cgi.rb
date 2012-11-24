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

use_itunes = cgi['use_itunes'].to_i
  
res = Search.search(URI.unescape(search_str), use_itunes)

if(/\.json/i.match($OUT_FMT) != nil)
  cgi.out("text/plain") { res.to_json }
elsif(/\.html/i.match($OUT_FMT) != nil)
  cgi.out("text/html") { Search.to_html(res) }
else
   cgi.out("text/plain") { res.to_json }
end