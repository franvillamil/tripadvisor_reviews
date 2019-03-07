### Patterns of local/foreign tourism in Madrid

#### R Scripts

###### Scraping & dataset creation

* `scrap_restaurants_madrid.R` : (output = `rest_data_madrid.csv`)
* `scrap_reviews_madrid.R` : (output = `reviews_raw_madrid.csv`)
* `clean_review_data.R` : (output = `reviews_rest_madrid.csv`)
* `geocoding.R` : (output = `rest_madrid_geocoded.csv`)
* `data_aggregation.R` :

###### Analyses

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
