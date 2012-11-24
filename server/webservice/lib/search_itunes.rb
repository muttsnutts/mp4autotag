require 'json'
require 'net/http'
require 'open-uri'

require './lib/tag.rb'

class SearchITunes
  $ITUNES_GET_SHOW_URL_FMT = "https://itunes.apple.com/search?term=%s+%s&media=tvShow&entity=tvSeason"
  $ITUNES_GET_MOVIE_URL_FMT= "https://itunes.apple.com/search?term=%s&media=movie"
  
  def SearchITunes::get_image(search, is_movie=false)
    urlstr = ''
    if(is_movie)
      urlstr = $ITUNES_GET_MOVIE_URL_FMT % [URI.escape(search["movstr"])]
    else
      urlstr = $ITUNES_GET_SHOW_URL_FMT % [URI.escape(search["serstr"]), URI.escape(search["seastr"]).to_i]
    end
    dbug("CONNECT: %s" % urlstr)
    res = JSON.load(Search.query(urlstr))
    if(SearchITunes.is_res(res))
      rtn = SearchITunes.get_safe(res, "artworkUrl100", 0)
      if(rtn != nil)
        rtn = rtn.gsub(/100x100/, '600x600')
      else
        rtn = ''
      end
      #self.dbug("RETURN %s" % rtn)
      return rtn
    end
  end
  def SearchITunes::get_safe(obj, prop, at)
    if(!SearchITunes.is_res(obj))
      self.dbug("RESULTS NOT A RES PROPER")
      return ''
    end
    if(!(obj['results'][at].kind_of? Hash))
      self.dbug("RESULTS[%i] is not a Hash" % at)
      return ''
    end
    if(!(obj['results'][at][prop].kind_of? String))
      self.dbug("RESULTS[%i][%s] is not a String" % [at, prop])
      return ''
    end
    #self.dbug(obj['results'])
    return obj['results'][at][prop]
  end
  def SearchITunes::is_res(obj)
    if(obj == nil)
      self.dbug("obj is nil")
      return false
    end
    if(!(obj['resultCount'].kind_of? Integer))
      self.dbug("RESULTCOUNT NOT AN INTEGER %s" % obj["resultCount"].class)
      return false
    end
    
    if(obj['resultCount'] == 0)
      self.dbug("NO RESULTS")
      return false
    end
      
    if(!(obj["results"].kind_of? Array))
      self.dbug("RESULTS NOT AN ARRAY")
      return false
    end
    
    return true
  end
  def SearchITunes::dbug(str)
    if $DEBUG_POP
      puts "[%s] DEBUG  %s. (%s)" % [Time.now.to_s.sub(/ [\-\+][0-9]{4}$/, ''), str, File.basename(__FILE__)]
    end
  end
end