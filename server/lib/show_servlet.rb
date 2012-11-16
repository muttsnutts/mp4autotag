require 'json'

class ShowServlet < WEBrick::HTTPServlet::AbstractServlet
  def do_GET req, res
    status = 200
    content_type = 'text/plain'
    body = ''
    
    begin
      path = req.path
      paths = path.split('/show/')
      if(paths.count != 2)
        raise "ARGUMENT ERROR: MUST INCLUDE AN <id>"
      else
        idstr = URI.unescape(paths[1])
        body = idstr.to_json
      end
    rescue Exception => e
      body = {"ERROR" => e.to_s}.to_json
    end
    
    res.status = status
    res['Content-Type'] = content_type
    res.body = body
  end
end
  