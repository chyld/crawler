require 'pry'
require 'httparty'

@links = []
@index = {}
@graph = {}

def get_html(url)
  begin
    HTTParty.get(url)
  rescue
    ''
  end
end

def get_links(url, html)
  begin
    pattern = /<a.*?href.*?['"](.*?)['"].*?>/m
    links = html.scan(pattern).flatten
    links.map { |link| URI.parse(link).relative? ? (URI.parse(url) + URI.parse(link)).to_s : link }
  rescue
    []
  end
end

def get_words(url, html)
  begin
    html.split.flatten
  rescue
    []
  end
end

def add_to_index(url, words)
  words.each do |word|
    @index.key?(word) ? @index[word] << url : @index[word] = [url]
  end
end

def add_to_graph(url, links)
  @graph[url] = links
end

def crawl(url)
  html  = get_html(url)
  words = get_words(url, html)
  links = get_links(url, html)

  add_to_index(url, words)
  add_to_graph(url, links)

  @links += links
  @links.shift while @graph.key?(@links.first)
  crawl(@links.shift) if @links.count > 0
end

crawl('http://172.16.3.105/~loaner/index.html')
binding.pry

