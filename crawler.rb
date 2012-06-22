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

def get_links(html)
  begin
    scheme = html.request.path.scheme
    hostname = html.request.path.hostname
    pattern = /<a.*?href.*?['"](.*?)['"].*?>/m
    links = html.scan(pattern).flatten
    links.map do |link|
      !link.include?(scheme) ? "#{scheme}://#{hostname}/#{link}" : link
    end
  rescue
    []
  end
end

def get_words(html)
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
  @graphs[url] = links
end

def crawl(url)
  html  = get_html(url)
  words = get_words(html)
  links = get_links(html)

  add_to_index(url, words)
  add_to_graph(url, links)

  @links += links
  @links.shift while @graph.key?(@links.first)
  crawl(@links.shift) if @links.count > 0
end

crawl('http://www.huffingtonpost.com')

