# project_brew
An exploration of craft breweries across the United States.

The most recent data pull was completed on August 22nd, 2018. This data can be found in all_brews.csv.

Brewery data scraped from the directory of the [Brewers Association](https://www.brewersassociation.org/directories/breweries/), using a combination of Docker and RSelenium.

### Workflow 
  
  1. Brewery data is acquired as described in data_pull.R
  2. Brewery data is cleaned in brew_cleaning.R
  3. Population data is imported and cleaned in census_data.R
  4. Brewery and population data is combined in data_combos.R
  5. Exploratory tables and visualizations are created in data_explo.R

<img src = "state_brewpubs.png" width = "700" height = "700" />
<img src = "state_planned.png" width = "700" height = "700" />

