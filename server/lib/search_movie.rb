require 'json'
require 'net/http'
require 'open-uri'

require './lib/tag.rb'

class SearchMovie
  $MOVIE_SEARCH_URL_FMT = "http://api.themoviedb.org/3/search/movie?api_key=ae802ff2638e8a186add7079dda29e03&query=%s"
  $MOVIE_GET_CAST_URL_FMT = "http://api.themoviedb.org/3/movie/%s/casts?api_key=ae802ff2638e8a186add7079dda29e03"
  $MOVIE_GET_MOVIE_URL_FMT = "http://api.themoviedb.org/3/movie/%s?api_key=ae802ff2638e8a186add7079dda29e03"
  $MOVIE_CONFIG = "http://api.themoviedb.org/3/configuration?api_key=ae802ff2638e8a186add7079dda29e03"
  
  def SearchMovie::search(search)
    #create the string to search for...
    search_str = String::new(search['movstr'])
    if(search['yearstr'].to_i > 1880)
      search_str << "+" << search['yearstr'].to_i.to_s
    end
    SearchMovie.dbug "SEARCH MOVIES FOR: \"%s\"" % [search_str]
    #movie query for search string and get a results array...
    resary = SearchMovie.query_array(search_str)
    #if no results and we tryed using a year, try again without the year...
    if(resary.count == 0 && search['yearstr'].to_i > 1880)
      search_str = search['movstr']
      SearchMovie.dbug "RE-SEARCH MOVIES FOR: \"%s\"" % [search_str]
      resary = SearchMovie.query_array(search_str)
    end
    #if still no results, try removing some stuff...
    if(resary.count == 0)
      search_str = search['movstr'].gsub(/( and )|( the )|( \& )|( a )|( [0-9] )/i, ' ').gsub(/^(and )|(the )|(\& )|(a )|([0-9]+ )/i, '')
      SearchMovie.dbug "RE-RE-SEARCH MOVIES FOR: \"%s\"" % [search_str]
      resary = SearchMovie.query_array(search_str)
    end
    #if still no results, return empty, we got nothing...
    if(resary.count == 0)
      return []
    end
    #loop though the results, adding the result to return array
    #get the image base path so you only have to do it once...
    img_base_url = SearchMovie::get_img_base
    rtnary = Array.new
    resary.each do |res|
      #get the movie with id of res
      if((m = SearchMovie.movie_with_id(res['id'])) != nil)
        #set the image path correctly
        m["Image Path"] = img_base_url + "w500" + m["Image Path"]
        rtnary << m
      else
        SearchMovie.dbug "NO MOVIE WITH ID: \"%s\"" % [res['id']]
      end
    end
    return rtnary
  end
  def SearchMovie::movie_with_id(m_id)
    SearchMovie.dbug "GET MOVIE WITH ID: %s" % m_id
    json = SearchMovie.id_query(m_id)
    return SearchMovie::json2tag(json)
  end
  def SearchMovie::query_array(search_str)
    json = JSON.load(SearchMovie.query($MOVIE_SEARCH_URL_FMT % [URI.escape(search_str)]))
    #get the results array
    resary = json['results']
    if resary == nil
      raise "Unable to GET results from themoviedb.org: %s" % search_str
    end
    return resary
  end
  def SearchMovie::id_query(m_id)
    return JSON.load(SearchMovie.query($MOVIE_GET_MOVIE_URL_FMT % [m_id]))
  end
  def SearchMovie::cast_query_array(m_id)
    json = JSON.load(SearchMovie.query($MOVIE_GET_CAST_URL_FMT % [m_id]))
    return json["cast"]
  end
  def SearchMovie::query(urlstr)
    str = ''
    open(urlstr) do |f|
      str << f.read
    end
    if str == ''
      return nil
    end
    return str
  end
  def SearchMovie::json2tag(json)
    tag = Tag.create_tag
    if(json != nil)
      tag["Media Type"]['value'] = "movie"
      tag["dbid"] = SearchMovie::get_safe(json, 'id')
      tag["cnID"]['value'] = SearchMovie::get_safe(json, 'id')
      tag["Short Description"]['value'] = SearchMovie::get_safe(json, 'overview')
      tag['Release Date']['value'] = SearchMovie::get_safe(json, 'release_date')
      tag['TV Show']['value'] = SearchMovie::get_safe(json, 'title')
      tag['Album']['value'] = SearchMovie::get_safe(json, 'title')
      tag['Name']['value'] = "%s (%i)" % [SearchMovie::get_safe(json, 'title'), SearchMovie::get_safe(json, 'release_date').to_i]
      artists = []
      ja = SearchMovie.cast_query_array(SearchMovie::get_safe(json, 'id'))
      ja.each do |artist|
        artists << artist["name"]
      end
      tag['Artist']['value'] = artists.join('|')
      genres = []
      g = SearchMovie::get_safe(json, 'genres')
      if(g == '')
        g.each do |genre|
          genres << genre["name"]
        end
      end
      tag['Genre']['value'] = genres.join("|")
      tag['Image Path'] = SearchMovie::get_safe(json, 'poster_path')
    end
    return tag
  end
  def SearchMovie::get_safe(json, key)
    rtn = json[key]
    if rtn != nil
      return rtn
    end
    return ''
  end
  def SearchMovie::get_img_base
    json = JSON.load(SearchMovie.query($MOVIE_CONFIG))
    return json['images']['base_url']
  end
  def SearchMovie::dbug(str)
    if $DEBUG_POP
      puts "[%s] DEBUG  %s. (search_movie.rb)" % [Time.now.to_s.sub(/ [\-\+][0-9]{4}$/, ''), str]
    end
  end
end