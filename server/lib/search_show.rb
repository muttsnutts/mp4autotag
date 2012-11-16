require 'rexml/document'
require 'net/http'
require 'open-uri'

require './lib/tag.rb'

class SearchShow
  $SHOW_SERIES_SEARCH_URL_FMT = "http://www.thetvdb.com/api/GetSeries.php?seriesname=%s"
  $SHOW_SERIES_ID_URL_FMT = "http://www.thetvdb.com/api/A8B8C9F3D5621481/series/%s/all/en.xml"
  $SHOW_BANNERS_URL_FMT = "http://www.thetvdb.com/banners/%s"
  def SearchShow::search(search)
    #set search episode number and season number
    s_epinum = search['epistr'].to_i
    s_seanum = search['seastr'].to_i
    seriesname = search["serstr"]
    #search results catagories
    r1m = []
    r2m = []
    r3m = []
    r4m = []
    #get all the different series matches...
    xmldoc = SearchShow.series_with_name(seriesname)
    #run though the series...
    xmldoc.elements.each('Data/Series') do |series|
      #get all the episodes for this series...
      serdoc = SearchShow.series_with_id(series.elements['seriesid'].get_text.value.strip)
      #set this series info..
      actors = SearchShow.safe_get(serdoc.elements['Data/Series/Actors'])
      genres = SearchShow.safe_get(serdoc.elements['Data/Series/Genre'])
      tvshow = SearchShow.safe_get(serdoc.elements['Data/Series/SeriesName'])
      tvnetwork = SearchShow.safe_get(serdoc.elements['Data/Series/Network'])
      release = SearchShow.safe_get(serdoc.elements['Data/Series/FirstAired'])
      serposter = SearchShow.safe_get(serdoc.elements['Data/Series/poster'])
      #go though all the episodes
      self.dbug "SETTING ALL EPISODES FOR: %s" % [tvshow] 
      serdoc.elements.each('Data/Episode') do |episode|
        epinum = SearchShow.safe_get(episode.elements['EpisodeNumber']).to_i
        seanum = SearchShow.safe_get(episode.elements['SeasonNumber']).to_i
        absnum = SearchShow.safe_get(episode.elements['absolute_number']).to_i
        epiname = SearchShow.safe_get(episode.elements['EpisodeName'])
        desc = SearchShow.safe_get(episode.elements['Overview'])
        poster = SearchShow.safe_get(episode.elements['filename'])
        epiid = SearchShow.safe_get(episode.elements['id'])
        writer = SearchShow.safe_get(episode.elements['Writer'])
        director = SearchShow.safe_get(episode.elements['Director'])
        rel2 = SearchShow.safe_get(episode.elements['FirstAired'])
        if(rel2.casecmp("") != 0) 
          release = rel2
        end
        #set the new tag
        tag = Tag.create_tag
        tag['Media Type']['value'] = "tvshow"
        tag['Artist']['value'] = actors
        tag['TV Show']['value'] = tvshow
        tag['Grouping']['value'] = tvshow
        tag['Genre']['value'] = genres
        tag['TV Network']['value'] = tvnetwork
        tag['Release Date']['value'] = release
        tag['Copyright']['value'] = release
        tag['TV Episode']['value'] = epinum.to_s
        tag['TV Season']['value'] = seanum.to_s
        tag['cnID']['value'] = epiid
        tag['Track']['value'] = absnum.to_s
        tag['Album']['value'] = epiname
        tag['Short Description']['value'] = desc
        tag['Composer']['value'] = writer
        tag['Album Artist']['value'] = director
        tag['Name']['value'] = "%s - S%0.2iE%0.2i - %s" % [tvshow, seanum, epinum, epiname]
        tag['dbid'] = epiid
        #get the full image path...
        if(poster != nil)
          tag['Image Path'] = $SHOW_BANNERS_URL_FMT % [poster]
        else
          tag['Image Path'] = $SHOW_BANNERS_URL_FMT % [serposter]
        end
        tag['Series Image Path'] = $SHOW_BANNERS_URL_FMT % [serposter]
        #put the tag in the correct results catagories
        if(epinum == s_epinum && seanum == s_seanum)
          if(seriesname.casecmp(tvshow) == 0)
						r1m.unshift(tag)
					else
						r1m << tag;
					end
				elsif(epinum == s_epinum)
					r2m << tag
				elsif(absnum == s_epinum)
					r3m << tag;
				elsif(seanum == s_seanum)
					r4m << tag;
				end
      end
    end
    return r1m.concat(r2m).concat(r3m).concat(r4m)
  end
  def SearchShow::series_with_id(serid)
    url = $SHOW_SERIES_ID_URL_FMT % serid
    self.dbug "SERIES WITH ID %s (%s)" % [serid, url]
    return REXML::Document.new(SearchShow.query(url))
  end
  def SearchShow::series_with_name(serstr)
    url = $SHOW_SERIES_SEARCH_URL_FMT % URI.escape(serstr)
    self.dbug "SERIES WITH NAME %s (%s)" % [serstr, url]
    return REXML::Document.new(SearchShow.query(url))
  end
  def SearchShow::query(urlstr)
    str = ''
    open(urlstr) do |f|
      str << f.read
    end
    if str == ''
      return nil
    end
    return str
  end
  def SearchShow::safe_get(xe)
    if(xe != nil)
      if(xe.kind_of? REXML::Element)
        if((r = xe.get_text) != nil)
          return r.value.strip
        end
      end
    end
    return ''
  end
  def SearchShow::dbug(str)
    puts "[%s] DEBUG  %s. (search_show.rb)" % [Time.now.to_s.sub(/ [\-\+][0-9]{4}$/, ''), str]
  end
end