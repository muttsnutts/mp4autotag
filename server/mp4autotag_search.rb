require 'json'

class MP4AutotagSearch < WEBrick::HTTPServlet::AbstractServlet
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
        body = self.search(URI.unescape(paths[1])).to_json
      end
    rescue Exception => e
      body = {"ERROR" => e.to_s}.to_json
    end
    
    res.status = status
    res['Content-Type'] = content_type
    res.body = body
  end
  def search(search_path)
    #part out the search path
    pathparts = search_path.split('/')
    #remove the basename and replace .-_+ with space
    filename_str = pathparts.last
    base_str = filename_str.chomp(File.extname(filename_str)).gsub(/[\.\-_\+]/, ' ')
    #
    return base_str
  end
end
  