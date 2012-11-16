require 'json'

require './lib/search_movie.rb'

class MovieServlet < WEBrick::HTTPServlet::AbstractServlet
  def do_GET req, res
    status = 200
    content_type = 'text/plain'
    body = ''
    
    begin
      path = req.path
      paths = path.split('/movie/')
      if(paths.count != 2)
        raise "ARGUMENT ERROR: MUST INCLUDE AN <id>"
      else
        idstr = URI.unescape(paths[1])
        img_base_url = SearchMovie.get_img_base
        tag = SearchMovie.movie_with_id idstr
        tag['Image Path'] = img_base_url + "w500" + tag["Image Path"]
        body = tag.to_json
      end
    rescue Exception => e
      body = {"ERROR" => e.to_s}.to_json
    end
    
    res.status = status
    res['Content-Type'] = content_type
    res.body = body
  end

  def dbug(str)
    puts "[%s] DEBUG  %s. (movie_servlet.rb)" % [Time.now.to_s.sub(/ [\-\+][0-9]{4}$/, ''), str]
  end
end
  