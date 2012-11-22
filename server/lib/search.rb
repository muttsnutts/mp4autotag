require './lib/search_movie.rb'
require './lib/search_show.rb'
require './lib/search_itunes.rb'
require './lib/tag.rb'

class Search
  def Search::search(search_path, use_itunes=0)
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
      $OUT_FMT = md[0]
      #if(/\.json/i.match(md.to_s) == nil)
      #  raise "json is the only format currently supported."
      #end
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
    movstr = ''
    yearstr= ''
    #if we have a movie, do a movie search
    if(is_movie)
      if((md = /(.+) {0,1}\({0,1}([0-9]{4})\){0,1}/i.match(basestr)) != nil)
        movstr = md[1].chomp("(")
        movstr.chomp!(" ")
        yearstr = md[2].chomp
      else
        movstr = basestr
      end
      rtn = Search.movie_search(basestr, movstr, yearstr)
    #otherwise do a show search
    else
      rtn = Search.show_search(basestr, serstr, seastr, epistr)
    end
    #if we still have nothing, and we did not do a movie search...
    if(rtn.count == 0 && !is_movie)
      rtn = Search.movie_search(basestr)
    end

    #now if it is a use_itunes request, 
    if(use_itunes == 1)
      #get the images from itunes
      rtn.each do |tag|
        if(tag["Media Type"]["value"] == 'tvshow')
          img_path = SearchITunes.get_image({"serstr" => tag["TV Show"]['value'], "seastr" => tag['TV Season']['value']}, false)
        else
          img_path = SearchITunes.get_image({"movstr" => tag["TV Show"]['value'], "yearstr" => tag['Release Date']['value'].to_i().to_s()}, true)
        end
        #self.dbug(img_path)
        if(img_path!=nil)
          if(img_path != "")
            tag["Image Path"] = img_path
          end
        end
      end
    end
    
    return rtn
  end
  def Search::movie_search(basestr, movstr, yearstr)
    Search.dbug "MOVIE SEARCH: basestr = \"%s\", movstr = \"%s\", yearstr = \"%s\"" % 
                          [basestr, movstr, yearstr]
    return SearchMovie.search({'basestr' => basestr, 'movstr' => movstr, 'yearstr' => yearstr})
  end
  def Search::show_search(basestr, serstr, seastr, epistr)
    Search.dbug "SHOW SEARCH: basestr = \"%s\", serstr = \"%s\", seastr.to_i = \"%i\", epistr.to_i = \"%i\"" % 
                          [basestr, serstr, seastr.to_i, epistr.to_i]
    return SearchShow.search({'basestr' => basestr, 'serstr' => serstr, 'seastr' => seastr, 'epistr' => epistr})
  end
  def Search::to_html(res)
    html = "<html><head><title>mp4autotag_server</title></head><body><table>"
    if(res.count > 0)
      row = res[0]
      #keys = row.keys
      keys = ["Name","Image Path","Series Image Path","TV Show","TV Season","TV Episode",
              "Media Type","Genre","Artist","Composer","Release Date","Album",
              "Track","Grouping","Comments","Album Artist","Copyright","TV Network",
              "TV Episode Number","Short Description","cnID","dbid"]
      html << "<thead><tr>"
      keys.each do |key|
        html << "<th>" << key << "</th>"
      end
      html << "</tr></thead><tbody>"
      res.each do |tag|
        html << "<tr>"
        keys.each do |key|
          if(key.casecmp("Image Path") == 0 || key.casecmp("Series Image Path") == 0)
            val = tag[key]
            if(val != nil)
              html << "<td><img src=\"" << val << "\" height=\"120px\" /></td>"
            else
              html << "<td></td>"
            end
          elsif(key.casecmp("dbid") == 0)
            html << "<td>" << tag[key] << "</td>"
          else
            if(tag[key].is_a? Hash)
              val = tag[key]['value']
              if(val != nil)
                html << "<td>" << val.to_s << "</td>"
              else
                html << "<td></td>"
              end
            end
          end
        end
        html << "</tr>"
      end
    end
    html << "</tbody></table></body></html>"
    return html
  end
  def Search::dbug(str)
    if $DEBUG_POP
      puts "[%s] DEBUG  %s. (search.rb)" % [Time.now.to_s.sub(/ [\-\+][0-9]{4}$/, ''), str]
    end
  end
end
  