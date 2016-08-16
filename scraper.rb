require "watir-webdriver"
require "nokogiri"
require 'redis'
require 'json'

BASE_URL = "http://concerts.livenation.com"
SETTLEMENT_PATH = "/microsite/settlement"
EVENTS_HASH_NAME = "events"

browser = Watir::Browser.new :phantomjs
@redis = Redis.new(url: ENV['REDIS_URL'])

def goto_page(browser, url)
  browser.goto url
  page = Nokogiri::HTML.parse browser.html
  return page
end

def process_results(results)
  new_events = []
  results.each do |result|
    month_abbr = result.css(".month abbr > text()").text
    month = result.css(".month abbr").first["title"]
    date = result.css("td.date div.date").first.text
    day = result.css(".day abbr").first["title"]

    venue = result.css(".location span[itemprop='location'] strong > text()").text
    location = result.css(".location span[itemprop='location'] > text()").text
    time = result.css(".location div > text()").text

    artist = result.css("[itemprop='name performers']").first.text
    
    url = result.css("a.event").first["href"]

    event = { 
      artist: artist,
      venue: venue,
      location: location,
      time: time,
      date: { 
        month_abbr: month_abbr,
        month: month,
        date: date,
        day: day } ,
      url: url
    }

    hash = "#{date}#{month}#{artist}"
    new_events << hash

    if !@redis.hexists(EVENTS_HASH_NAME, hash)
      puts "Adding: #{hash}"
      @redis.hset(EVENTS_HASH_NAME, hash, JSON.generate(event))
    end
  end

  return new_events
end

def cleanup(new_events)
  # Remove events that no longer exist
  existing = @redis.hkeys(EVENTS_HASH_NAME)
  diff = existing - new_events
  
  unless diff.empty?
    puts "Removing: '#{diff.join("' '")}'}"
    @redis.hdel(EVENTS_HASH_NAME, "'#{diff.join("' '")}'")
  end
end

# Go to settlement page
puts "Going to #{BASE_URL}#{SETTLEMENT_PATH}"
settlement = goto_page(browser, "#{BASE_URL}#{SETTLEMENT_PATH}")
cities_path = settlement.css("ul.change_location_list li a")[0]["href"]

# Go to cities list page
cities_url = "#{BASE_URL}#{cities_path}"
puts "Going to #{cities_url}"
cities = goto_page(browser, cities_url)

# Find "Greater Seattle Area"
seattle_path = cities.css(".container-empty:nth-of-type(1) td:nth-of-type(4) p:nth-of-type(9) a")[0]["href"]
seattle_url = "#{BASE_URL}#{seattle_path}"

# Go to Great Seattle Area concert list
puts "Going to #{seattle_url}"
browser.goto seattle_url
browser.td(class: "event").wait_until_present(10)
seattle = Nokogiri::HTML.parse browser.html

# Grab results
results = seattle.css("#result_local #tbl_local tr")

new_events = process_results(results)

cleanup(new_events)