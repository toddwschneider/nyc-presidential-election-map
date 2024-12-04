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

results_url_2020 = "https://vote.nyc/sites/default/files/pdf/election_results/2020/20201103General%20Election/00000100000Citywide%20President%20Vice%20President%20Citywide%20EDLevel.csv"

results_url_2024 = "https://vote.nyc/sites/default/files/pdf/election_results/2024/20241105General%20Election/00000100000Citywide%20President%20Vice%20President%20Citywide%20EDLevel.csv"

results_file_2016 = "certified_results/results_2016.csv"
results_file_2020 = "certified_results/results_2020.csv"
results_file_2024 = "certified_results/results_2024.csv"

download.file(results_url_2016, results_file_2016)
download.file(results_url_2020, results_file_2020)
download.file(results_url_2024, results_file_2024)

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

raw_certified_2020_results = read_csv(results_file_2020, col_names = FALSE, guess_max = 100e3)
col_names_2020 = janitor::make_clean_names(raw_certified_2020_results[1, 1:11])

election_results_2020 = raw_certified_2020_results[, 12:22] %>%
  set_names(col_names_2020) %>%
  mutate(
    elect_dist = as.numeric(paste0(ad, ed)),
    candidate = str_replace(unit_name, " \\(.+?\\)$", "")
  ) %>%
  group_by(elect_dist) %>%
  summarize(
    republican = sum(tally * grepl("Trump", candidate)),
    democratic = sum(tally * grepl("Biden", candidate)),
    green = sum(tally * grepl("Hawkins", candidate)),
    libertarian = sum(tally * grepl("Jorgensen", candidate)),
    .groups = "drop"
  ) %>%
  mutate(year = 2020)

raw_certified_2024_results = read_csv(results_file_2024, col_names = FALSE, guess_max = 100e3)
col_names_2024 = janitor::make_clean_names(raw_certified_2024_results[1, 1:11])

election_results_2024 = raw_certified_2024_results[, 12:22] %>%
  set_names(col_names_2024) %>%
  mutate(
    elect_dist = as.numeric(paste0(ad, ed)),
    candidate = str_replace(unit_name, " \\(.+?\\)$", "")
  ) %>%
  group_by(elect_dist) %>%
  summarize(
    republican = sum(tally * grepl("Trump", candidate)),
    democratic = sum(tally * grepl("Harris", candidate)),
    .groups = "drop"
  ) %>%
  mutate(year = 2024)

bind_rows(
  election_results_2016,
  election_results_2020,
  election_results_2024
) %>%
  mutate(
    green = replace_na(green, 0),
    libertarian = replace_na(libertarian, 0)
  ) %>%
  write_csv("nyc_election_results_by_district.csv")
