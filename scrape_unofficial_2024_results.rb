require 'csv'
require 'nokogiri'
require 'rest-client'

class NycUnofficialResultsScraper
  def scrape!
    index_url = "https://enr.boenyc.gov/CD26825AD0.html"

    assembly_district_urls = Nokogiri::HTML(RestClient.get(index_url).body).
      css("table a").
      select { |a| a.text.start_with?("AD ") }.
      map { |a| "https://enr.boenyc.gov/#{a["href"]}" }.
      sort

    unofficial_results = assembly_district_urls.flat_map do |url|
      assembly_district_id = Integer(url[/AD(\d{2})/, 1])

      ed_rows = Nokogiri::HTML(RestClient.get(url).body).
        css("table tr").
        select { |tr| tr.at("td")&.text.to_s.start_with?("ED ") }

      ed_rows.map do |row|
        election_district_results(row: row, ad: assembly_district_id)
      end
    end

    CSV.open("unofficial_results/results_2024.csv", "wb") do |csv|
      csv << %w(elect_dist republican democratic year)

      unofficial_results.each do |h|
        csv << [
          h[:ad] * 1000 + h[:ed],
          h[:trump],
          h[:harris],
          2024
        ]
      end
    end
  end

  def parse_int(str)
    return 0 if str == "-"
    Integer(str)
  end

  def election_district_results(row:, ad:)
    td_values = row.css("td").map { |td| td.text.strip }

    {
      ed: parse_int(td_values[0].split(" ").last),
      ad: ad,
      pct_reporting: Float(td_values[1].chomp("%")),
      trump: parse_int(td_values[5]) + parse_int(td_values[7]),
      harris: parse_int(td_values[3]) + parse_int(td_values[9])
    }
  end
end

NycUnofficialResultsScraper.new.scrape!
