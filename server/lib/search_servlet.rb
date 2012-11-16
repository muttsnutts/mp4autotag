require './lib/search.rb'

class SearchServlet < WEBrick::HTTPServlet::AbstractServlet
  def do_GET req, res
    status = 200
    content_type = 'text/plain'
    body = ''
    
    begin
      path = req.path
      paths = path.split('/search')
      if(paths.count != 2)
        raise "ARGUMENT ERROR: MUST INCLUDE A <filename>"
      else
        self.dbug "SEARCHING ON: %s" % [URI.unescape(paths[1])]
        body = Search.search(URI.unescape(paths[1])).to_json
      end
    rescue Exception => e
      body = {"ERROR" => e.to_s}.to_json
    end
    
    res.status = status
    res['Content-Type'] = content_type
    res.body = body
  end
  
  def dbug(str)
    if $DEBUG_POP
      puts "[%s] DEBUG  %s. (search_servlet.rb)" % [Time.now.to_s.sub(/ [\-\+][0-9]{4}$/, ''), str]
    end
  end
end