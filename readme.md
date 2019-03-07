### Patterns of local/foreign tourism in Madrid

#### R Scripts

##### Scraping & dataset creation

* `scrap_restaurants_madrid.R`: Scraps the list of restaurants from the [TripAdvisor Madrid list](https://tripadvisor.com/Restaurants-g187514-Madrid.html), saving restaurant-level data, i.e. name, rank, URL, address, total number of reviews, number of reviews in English and Spanish, and type/price range.

* `scrap_reviews_madrid.R`: Using the list of restaurants from above, extracts all the reviews in Spanish and English and saves each whole page as raw text, alogn with the restaurant URL and the language.

* `clean_review_data.R` : Takes the reviews raw data and cleans it up, putting each review in separated rows, removing duplicated ones (translations) and extracting the review and visit dates from the text.

* `geocoding.R`: Geocodes the exact location of each restaurant following their address, using [`ggmap`](https://github.com/dkahle/ggmap), and locates the coordinate points in each *barrio* of Madrid.

* `data_aggregation.R`: Aggregates review and restaurant data by *barrio* in three different points in time (Dec18, Jun17 & Nov15), along with the number of AirBnB listings two months before, and the number of hotels and hostels (only current data).

*Note: all these scripts must be run in this particular order.*

##### Analyses & plotting

* `reviews_eda.R` :
* `spatial_plots.R` :


----------------------------------------------------------
**TODO a 5 de marzo 2019**
- Spatial overlay & aggregation AirBnB data
  * Num de listings en cada periodo a nivel de barrio. (All listings? Subsets?)
- Aggregation at the level of barrios of restaurants:
  * Reviews Spanish / English (a 31/12/18, 30/06/17 & 30/11/15 - ~2 meses despues)
  * Aggregations of control variables:
    > num total de restaurantes (log)
    > num total de reviews (log)
    > num hoteles 4/5 estrellas
    > num total de hoteles + hostales etc
    > distance from Sol
  * Plot ALL THESE VARS!
- Run analyses, plots etc
- Write report (& appendix on tripadvisor data)
----------------------------------------------------------


Using TripAdvisor reviews and AirBnB listings data to track spatial dynamics of tourism in Madrid.

AirBnB data from: http://insideairbnb.com/get-the-data.html (3 periods: 7 november 2018, 8 april 2017, 2 october 2015)

GIS: http://www.madrid.org/iestadis
Turismo: Apartamentos turísticos

Turismo: Camping

Turismo: Hostales 1 estrella

Turismo: Hostales 2 estrellas

Turismo: Hostales 3 estrellas

Turismo: Hoteles 1 estrella

Turismo: Hoteles 2 estrellas

Turismo: Hoteles 3 estrellas
Turismo: Hoteles 4 estrellas
Turismo: Hoteles 5 estrellas
Turismo: Pensiones 1 estrella
Turismo: Pensiones 2 estrellas
Turismo: Pensiones 3 estrellas
Turismo: Pensiones casa de huespedes
