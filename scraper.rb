require "watir-webdriver"
require "nokogiri"

BASE_URL = "http://concerts.livenation.com"
SETTLEMENT_PATH = "/microsite/settlement"

browser = Watir::Browser.new :phantomjs

def goto_page(browser, url)
  browser.goto url
  page = Nokogiri::HTML.parse browser.html
  return page
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
browser.td(class: "event").wait_until_present(5)
seattle = Nokogiri::HTML.parse browser.html

# Grab results
output = []
results = seattle.css("#result_local #tbl_local tr")

results.each do |result|
  date = result.css(".month abbr").first["title"]
  artist = result.css("[itemprop='name performers']").first.text
  output << { date: date, artist: artist }
end

puts output
