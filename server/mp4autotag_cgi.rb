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

res = Search.search(URI.unescape(search_str))

if(/\.json/i.match($OUT_FMT) != nil)
  cgi.out("text/plain") { res.to_json }
elsif(/\.html/i.match($OUT_FMT) != nil)
  html = "<html><head><title>mp4autotag_cgi</title></head><body>" << 
         "<h1>mp4autotag_cgi:</h1><h2>results</h2><table>"
  if(res.count > 0)
    row = res[0]
    keys = row.keys
    html << "<thead><tr>"
    keys.each do |key|
      html << "<th>" << key << "</th>"
    end
    html << "</tr></thead><tbody>"
  end
  html << "</tbody></table></body></html>"
  cgi.out("text/html") { html }
else
   cgi.out("text/plain") { res.to_json }
end