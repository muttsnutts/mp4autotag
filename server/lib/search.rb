require './lib/search_movie.rb'
require './lib/search_show.rb'
require './lib/tag.rb'

class Search
  def Search::search(search_path)
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
    ext = File.extname(filename_str)
    md = /(\.mp4)|(\.m4v)|(\.mov)|(\.mkv)|(\.ogg)|(\.avi)|(\.flv)|(\.m1v)|(\.m2v)|(\.mpeg)|(\.roq)|(\.rm)|(\.swf)|(\.wmv)/.match(ext)
    if(md != nil) 
      basestr = filename_str.chomp(File.extname(filename_str)).gsub(/[\.\-_\+]/, ' ')
    else
      basestr = filename_str.gsub(/[\.\-\_\+]/, ' ')
    end
    serstr = ''
    seastr = '0'
    epistr = '0'
    is_movie = true
    #check to see if this basestr is a show
    #first check for / e([0-9]+)/i
    if((md = /e([0-9]+)/i.match(basestr)) != nil)
      is_movie = false
      epistr = md[1]
      #see if we have a series name...
      if((md = /(.+) e[0-9]+/i.match(basestr)) != nil)
        serstr = md[1].strip
      end
      #see if there is a /s([0-9]+)/i for a season...
      if((md = /s([0-9]+)/i.match(basestr)) != nil)
        seastr = md[1]
        #see if we have a series name...
        if((md = /(.+) s[0-9]+ *e[0-9]+/i.match(basestr)) != nil)
          serstr = md[1].strip
        end
      end
    #maybe we have a / ([0-9]+)x([0-9]+)/i, could be a SxE...
    elsif((md = /([0-9]+)x([0-9]+)/i.match(basestr)) != nil)
      is_movie = false
      epistr = md[2]
      seastr = md[1]
      #see if we have a series name...
      if((md = /(.+) [0-9]+x[0-9]+/i.match(basestr)) != nil)
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
    rtn = []
    #if we have a movie, do a movie search
    if(is_movie)
      rtn = Search.movie_search(basestr)
    #otherwise do a show search
    else
      rtn = Search.show_search(basestr, serstr, seastr, epistr)
    end
    #if we still have nothing, and we did not do a movie search...
    if(rtn.count == 0 && !is_movie)
      rtn = Search.movie_search(basestr)
    end
    return rtn
  end
  def Search::movie_search(basestr)
    movstr = ''
    yearstr = ''
    if((md = /(.+) {0,1}\({0,1}([0-9]{4})\){0,1}/i.match(basestr)) != nil)
      movstr = md[1].chomp("(")
      movstr.chomp!(" ")
      yearstr = md[2].chomp
    else
      movstr = basestr
    end
    Search.dbug "MOVIE SEARCH: basestr = \"%s\", movstr = \"%s\", yearstr = \"%s\"" % 
                          [basestr, movstr, yearstr]
    return SearchMovie.search({'basestr' => basestr, 'movstr' => movstr, 'yearstr' => yearstr})
  end
  def Search::show_search(basestr, serstr, seastr, epistr)
    Search.dbug "SHOW SEARCH: basestr = \"%s\", serstr = \"%s\", seastr.to_i = \"%i\", epistr.to_i = \"%i\"" % 
                          [basestr, serstr, seastr.to_i, epistr.to_i]
    return SearchShow.search({'basestr' => basestr, 'serstr' => serstr, 'seastr' => seastr, 'epistr' => epistr})
  end
  def Search::dbug(str)
    puts "[%s] DEBUG  %s. (search.rb)" % [Time.now.to_s.sub(/ [\-\+][0-9]{4}$/, ''), str]
  end
end
  