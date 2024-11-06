# NYC Presidential Election Results Map

Some resources to create an election district-level map of New York City with 2016–2024 presidential election results

**Note:** 2024 election results are unofficial until certified

## Data sources

- Election results data via [NYC Board of Elections](https://vote.nyc/page/election-results-summary)
- District shapefiles via [NYC Planning](https://www.nyc.gov/site/planning/data-maps/open-data/districts-download-metadata.page)

## Live map

[See here for a live interactive version of the map](https://toddwschneider.com/maps/nyc-presidential-election-results/)

[![nyc election map](https://toddwschneiderdotcom.twscontent.com/nyc-presidential-election-results/img/nyc_election_results_map_2024.png)](https://toddwschneider.com/maps/nyc-presidential-election-results/)

## Data processing

`fetch_election_results.R` downloads certified data from the vote.nyc website, loads it into an R session, does a bit of processing, combines with the unofficial results scraped above, and writes aggregated results to a file called `nyc_election_results_by_district.csv`

I've included my aggregated results file in this repo, in addition to the raw data files as I downloaded them from vote.nyc. You should be able to reproduce similar results by running the Ruby and R scripts, though the unofficial results in particular will update over time as more ballots get counted, in which case your results might not match up with mine

## Map

`map.html` is a web page that uses [Mapbox GL JS](https://docs.mapbox.com/mapbox-gl-js/api/) to display a map of NYC with an overlay of election results by district. By default it points at a copy of the aggregated election results csv that I have hosted, but you can replace the `ELECTION_RESULTS_URL` with your own URL if you'd like

If you want to use [Mapbox map styles](https://www.mapbox.com/maps), you'll need to sign up for a free Mapbox account and edit `map.html` with your [access token](https://docs.mapbox.com/help/how-mapbox-works/access-tokens/)

## Shapefiles/GeoJSON/TopoJSON

Election district boundaries are provided in this repo as [TopoJSON](https://github.com/topojson/topojson/wiki) format, which is what `map.html` uses, but if you're curious, you can use [ogr2ogr](https://gdal.org/programs/ogr2ogr.html), [geo2topo](https://github.com/topojson/topojson-server/blob/master/README.md#geo2topo), and [topojson](https://github.com/topojson/topojson) to convert between shapefile, GeoJSON, and TopoJSON formats. For example:

```sh
wget https://www1.nyc.gov/assets/planning/download/zip/data-maps/open-data/nyed_20c.zip
unzip nyed_20c.zip
ogr2ogr -f GeoJSON -t_srs crs:84 nyed_20c.geojson nyed_20c/nyed.shp
geo2topo -o nyed_20c.json -q 1e6 nyed_20c.geojson
```

Note that there are two TopoJSON files included, `nyed_16d` and `nyed_20c`, because election district boundaries change over time. As with the election results csv, `map.html` reads TopoJSON files that I have hosted, but you could rehost your own and then update the `DISTRICTS_TOPOJSON_2016_URL` and `DISTRICTS_TOPOJSON_2020_URL` variables

## Unofficial election night results

`scrape_unofficial_2024_results.rb` is a Ruby script that scrapes the [unofficial 2024 results pages](https://enr.boenyc.gov/) and writes the data to a csv

## Inspiration

Inspiration via DNAinfo, who produced a [similar map](https://dna.carto.com/viz/cbda32b6-a6b9-11e6-ad7f-0e05a8b3e3d7/public_map) in 2016 (unfortunately the [original link](https://www.dnainfo.com/new-york/numbers/clinton-trump-president-vice-president-every-neighborhood-map-election-results-voting-general-primary-nyc/) is now dead). The New York Times produced a [nationwide version](https://www.nytimes.com/interactive/2018/upshot/election-2016-voting-precinct-maps.html) in 2018

## Questions/issues

todd@toddwschneider.com, or open a GitHub issue
