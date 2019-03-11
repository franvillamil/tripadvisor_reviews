### AirBnB and changes in the clientele of local bars and restaurants

Online repository for a project on the effects of AirBnB on the clientele of local bars and restaurants.
In particular, focusing on the city of Madrid, the project analyzes whether the number of AirBnB listings in each neighbourhood, and its increase over time, is related to the number of international visitors to local bars and restaurants.
To get an approximate measure of international vs local visitors, I scrap all reviews from the 10,000+ bars and restaurants in Madrid listed on TripAdvisor, and calculate the share of reviews in Spanish vs English.
For the data on AirBnB listings, I rely on [Inside AirBnB](http://insideairbnb.com).
Below there are all the R scripts used to collect and manipulate the data, as well as the analyses included in the report.

[First results - PDF](./writing/report.pdf)

#### R Scripts

##### Scraping & dataset creation

* `scrap_restaurants_madrid.R`: Scraps the list of restaurants from the [TripAdvisor Madrid list](https://tripadvisor.com/Restaurants-g187514-Madrid.html), saving restaurant-level data, i.e. name, rank, URL, address, total number of reviews, number of reviews in English and Spanish, and type/price range.

* `scrap_reviews_madrid.R`: Using the list of restaurants from above, extracts all the reviews in Spanish and English and saves each whole page as raw text, alogn with the restaurant URL and the language.

* `clean_review_data.R` : Takes the reviews raw data and cleans it up, putting each review in separated rows, removing duplicated ones (translations) and extracting the review and visit dates from the text.

* `geocoding.R`: Geocodes the exact location of each restaurant following their address, using [`ggmap`](https://github.com/dkahle/ggmap), and locates the coordinate points in each *barrio* of Madrid.

* `data_aggregation.R`: Aggregates review and restaurant data by *barrio* in three different points in time (31/12/18, 30/06/17 & 30/11/15), along with the number of AirBnB listings two months before, and the number of hotels and hostels (only current data).

*Note: all these scripts must be run in this particular order.*

##### Analyses & plotting

* `reviews_eda.R` : preliminary code to explore the TripAdvisor data

* `spatial_plots.R` : preliminary code to plot the TripAdvisor data spatially

* `analyses.R` : analyses and plots of the results
