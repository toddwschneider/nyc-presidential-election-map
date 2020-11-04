require 'csv'
require 'nokogiri'
require 'rest-client'

home_dom = Nokogiri::HTML(RestClient.get("https://web.enrboenyc.us/CD23464ADI0.html").body)

county_names = ["New York", "Bronx", "Kings", "Queens", "Richmond"]

county_urls = home_dom.css("table a").
  select { |a| county_names.include?(a.text) }.
  map { |a| "https://web.enrboenyc.us/#{a["href"]}" }

assembly_district_urls = county_urls.flat_map do |url|
  dom = Nokogiri::HTML(RestClient.get(url).body)

  dom.css("table a").
    select { |a| a.text.start_with?("AD ") }.
    map { |a| "https://web.enrboenyc.us/#{a["href"]}" }
end

td_indexes = {
  3 => :biden,
  5 => :trump,
  7 => :trump,
  9 => :biden,
  11 => :hawkins,
  13 => :jorgensen
}

unofficial_results = assembly_district_urls.flat_map do |url|
  assembly_district_id = Integer(url[/AD(\d{2})/, 1])

  dom = Nokogiri::HTML(RestClient.get(url).body)

  ed_rows = dom.css("table tr").
    select { |tr| tr.at("td")&.text.to_s.start_with?("ED ") }

  ed_rows.flat_map do |row|
    td_values = row.css("td").map(&:text)
    next if td_values[1].strip == "0.00%"

    elect_dist = Integer(td_values[0].split(" ").last)

    votes_by_candidate = td_indexes.each.with_object(Hash.new(0)) do |(i, candidate), h|
      h[candidate] += Integer(td_values[i])
    end

    votes_by_candidate[:ad] = assembly_district_id
    votes_by_candidate[:ed] = elect_dist

    votes_by_candidate
  end.compact
end

CSV.open("unofficial_results_2020.csv", "wb") do |csv|
  csv << %w(elect_dist republican democratic green libertarian year)

  unofficial_results.each do |h|
    csv << [
      h[:ad] * 1000 + h[:ed],
      h[:trump],
      h[:biden],
      h[:hawkins],
      h[:jorgensen],
      2020
    ]
  end
end
