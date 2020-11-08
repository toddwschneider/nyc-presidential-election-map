required_packages = c("tidyverse", "janitor")
installed_packages = rownames(installed.packages())
packages_to_install = required_packages[!(required_packages %in% installed_packages)]

if (length(packages_to_install) > 0) {
  install.packages(
    packages_to_install,
    dependencies = TRUE,
    repos = "https://cloud.r-project.org",
  )
}

library(tidyverse)

results_url_2016 = "https://vote.nyc/sites/default/files/pdf/election_results/2016/20161108General%20Election/00000100000Citywide%20President%20Vice%20President%20Citywide%20EDLevel.csv"

results_file_2016 = "certified_results/results_2016.csv"

download.file(results_url_2016, results_file_2016)

election_results_2016 = read_csv(results_file_2016, guess_max = 10e3) %>%
  janitor::clean_names() %>%
  mutate(
    elect_dist = as.numeric(paste0(ad, ed)),
    candidate = str_replace(unit_name, " \\(.+?\\)$", "")
  ) %>%
  group_by(elect_dist) %>%
  summarize(
    republican = sum(tally * grepl("Trump", candidate)),
    democratic = sum(tally * grepl("Clinton", candidate)),
    green = sum(tally * grepl("Stein", candidate)),
    libertarian = sum(tally * grepl("Johnson", candidate)),
    .groups = "drop"
  ) %>%
  mutate(year = 2016)

# TODO get official 2020 results once they are available
#      for now, use the unofficial results scraped by scrape_unofficial_results.rb
election_results_2020 = read_csv("unofficial_results/results_2020.csv")

bind_rows(election_results_2016, election_results_2020) %>%
  write_csv("nyc_election_results_by_district.csv")
