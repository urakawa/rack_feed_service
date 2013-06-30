require 'rubygems'
require 'sinatra/base'
require 'haml'
require 'sass'

require 'open-uri'
require 'rss'

require 'pp'

class HelloApp < Sinatra::Base
  set :haml, {:format => :html5 }

  get '/' do
    'Hello Root'
  end
  
  get '/hello' do
    'Hello World'
  end
  
  get '/feed' do
    # URLへアクセスしページを取得
    uri = URI.parse('http://www.uraq.net/atom.xml')
    #uri = URI.parse('http://b.hatena.ne.jp/hotentry.rss')
    
    # RSSとして読み込み
    rss_source = uri.read
    begin
      rss = RSS::Parser.parse(rss_source)
    rescue RSS::InvalidRSSError
      rss = RSS::Parser.parse(rss_source, false)
    end
    
    @entries = Array.new
    case rss.class.name
    when "RSS::RDF"
      #pp rss
      isFirst = true;
      rss.items.each do |item|
        #if isFirst
        #  #pp item
        #  p item.link
        #  p item.title
        #  p item.description
        #  
        #end
        #isFirst = false
        @entries.push({'link'=>item.link, 'title'=>item.title, 'description'=>item.description})
        
      end
    when "RSS::Atom::Feed"
      isFirst = true;
      rss.entries.map.each do |item|
        #if isFirst
        #  p item.link.href
        #  p item.title.content
        #  p item.summary.content
        #end
        #isFirst = false
        @entries.push({'link'=>item.link.href, 'title'=>item.title.content, 'description'=>item.summary.content})
      end
    end
    
    @rss = rss
    haml :feed
  end
  
  
  get '/stylesheet.css' do
    scss :stylesheet
  end
end

run HelloApp
