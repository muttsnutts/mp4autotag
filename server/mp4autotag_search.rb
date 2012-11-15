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
    #remove the filename
    filename_str = pathparts.last
    #get the relitives of the path
    parentdir_str = nil
    if(pathparts.count > 1)
      parentdir_str = pathparts[pathparts.count-2]
    end
    grandparentdir_str = nil
    if(pathparts.count > 2)
      grandparentdir_str = pathparts[pathparts.count-3]
    end
    
    #see what we have for an extension, because .xml, .json, .txt, and .html are formats
    ext = File.extname(filename_str)
    md = /(\.xml)|(\.json)|(\.txt)|(\.html)/i.match(ext)
    if(md != nil)
      if(/\.json/i.match(md.to_s) == nil)
        raise "json is the only format currently supported."
      end
      filename_str.chomp!(ext)
    end   
    base_str = filename_str.chomp(File.extname(filename_str)).gsub(/[\.\-_\+]/, ' ')
    serstr = ''
    seastr = '0'
    epistr = '0'
    is_movie = true
    #check to see if this base_str is a show
    #first check for / e([0-9]+)/i
    if((md = /e([0-9]+)/i.match(base_str)) != nil)
      is_movie = false
      epistr = md[1]
      #see if we have a series name...
      if((md = /(.+) e[0-9]+/i.match(base_str)) != nil)
        serstr = md[1].strip
      end
      #see if there is a /s([0-9]+)/i for a season...
      if((md = /s([0-9]+)/i.match(base_str)) != nil)
        seastr = md[1]
        #see if we have a series name...
        if((md = /(.+) s[0-9]+e[0-9]+/i.match(base_str)) != nil)
          serstr = md[1].strip
        end
      end
    #maybe we have a / ([0-9]+)x([0-9]+)/i, could be a SxE...
    elsif((md = /([0-9]+)x([0-9]+)/i.match(base_str)) != nil)
      is_movie = false
      epistr = md[2]
      seastr = md[1]
      #see if we have a series name...
      if((md = /(.+) [0-9]+x[0-9]+/i.match(base_str)) != nil)
        serstr = md[1].strip
      end
    #maybe we have a /([0-9]{4})/ could be a date, or a SSEE...
    #elsif((md = /([0-9]{4})/i.match(filename_str)) != nil)
    end
    #if we don't have a movie and we don't have a seastr and we have a parent dir string, check the parent...
    if(is_movie == false && parentdir_str != nil)
      #see if the parentdir_str has /season ([0-9]+)/
      if((md = /season ([0-9]+)/i.match(parentdir_str)) != nil)
        if(grandparentdir_str != nil)
          parentdir_str = grandparentdir_str
        end
        if(seastr == '0')
          seastr = md[1]
        end
      end
    end
    #if we don't have a movie and we don't have a serstr and we have a parent dir string, make the serstr tha parent...
    if(is_movie == false && serstr == '' && parentdir_str != nil)
      serstr = parentdir_str
    end
    
    #if we have a movie, do a movie search
    if(is_movie)
      movie_name = ''
      year_str = ''
      if((md = /(.+) \({0,1}([0-9]{4})\){0,1}/i.match(base_str)) != nil)
        movie_name = md[1]
        year_str = md[2]
      else
        movie_name = base_str
      end
      return self.movie_search({'base_str' => base_str, 'movie_name' => movie_name, 'movie_year' => year_str})
    #otherwise do a show search
    else
      return self.show_search({'base_str' => base_str, 'serstr' => serstr, 'seastr' => seastr, 'epistr' => epistr})
    end
  end
  def movie_search(search)
    return search
  end
  def show_search(search)
    return search
  end
end
  