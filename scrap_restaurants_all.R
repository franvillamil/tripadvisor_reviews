### NOTE:
# Cambiar el script y hacerlo como el scrap_restaurants_madrid
# Also, para guardar files, crear un folder con el nombre de la ciudad
# (primera palabra hasta '_', en lower case). Y pillar solo las vars esas.

library(rvest)
library(stringr)
library(dplyr)
options(stringsAsFactors = FALSE, timeout = 4000000)

url_list = c("https://www.tripadvisor.com/Restaurants-g187514-Madrid.html",
             "https://www.tripadvisor.com/Restaurants-g187497-Barcelona_Catalonia.html",
             "https://www.tripadvisor.com/Restaurants-g187454-Bilbao_Province_of_Vizcaya_Basque_Country.html",
             "https://www.tripadvisor.com/Restaurants-g187529-Valencia_Province_of_Valencia_Valencian_Country.html",
             "https://www.tripadvisor.com/Restaurants-g187438-Malaga_Costa_del_Sol_Province_of_Malaga_Andalucia.html",
             "https://www.tripadvisor.com/Restaurants-g187451-Gijon_Asturias.html",
             "https://www.tripadvisor.com/Restaurants-g187452-Oviedo_Asturias.html")

### Function: scrapping restaurant

read_restaurant = function(rest_page, local = "Spanish"){

  name = rest_page %>%
    html_node(".h1") %>%
    html_text()
  rank = as.integer(gsub("\\#|,", "",
                         rest_page %>%
                           html_node(".popIndexValidation span") %>%
                           html_text()
  ))
  address = rest_page %>%
    html_node(".address") %>%
    html_text()
  tags = rest_page %>%
    html_node(".header_links") %>%
    html_text()
  reviews = gsub(",", "", rest_page %>%
                   html_node(".is-3") %>%
                   html_text() )
  reviews_all = gsub("\\(|\\)|,", "", rest_page %>%
                       html_node(".reviews_header_count") %>%
                       html_text()) %>% as.integer()
  # keywords = rest_page %>%
  #   html_node("") %>%
  #   html_text()

  if(!is.na(reviews)){
    reviews_eng = str_match(reviews, "English\\s\\((\\d+)\\)")[,2]
    reviews_local = str_match(reviews, paste0(local, "\\s\\((\\d+)\\)"))[,2]
    reviews_fra = str_match(reviews, "French\\s\\((\\d+)\\)")[,2]
  } else {
    reviews_eng = NA
    reviews_local = NA
    reviews_fra = NA
  }

  reviews_eng = as.integer(gsub(",", "", reviews_eng))
  reviews_local = as.integer(gsub(",", "", reviews_local))
  reviews_fra = as.integer(gsub(",", "", reviews_fra))

  restaurant_data = data.frame(name = name, rank = rank, address = address,
                               reviews_raw = reviews, reviews_all = reviews_all, tags = tags,
                               reviews_eng = reviews_eng, reviews_spa = reviews_local, reviews_fra = reviews_fra)
  return(restaurant_data)

}

### SCRAPPING ### -------------------------------------------

# DF to fill in
rest_data = data.frame()

# URLs & HTML session
for(k in 1:length(url_list)){

  # Get URL
  url = url_list[k]
  # Extract city to save files
  city = str_sub(url, str_locate_all(url, "-")[[1]][,2][-1L]+1, -1L)
  city = gsub(".html", "", city)
  # If file already exists, skip. Otherwise, continue
  if(file.exists(paste0("tripadvisor_project/files/rest_data_", city, ".csv"))){next}
  print(paste0(city, " ============================================"))

  home = html_session(url)

  # Max number of pages
  pages = gsub("\\\n", "", home %>%
                 html_nodes(".pageNum.taLnk") %>% html_text() )
  pages = as.integer(pages[length(pages)])

  # Start depending on which ones were made last time
  already_done = list.files("tripadvisor_project/files/")
  already_done = as.integer(gsub(paste0("rest_data_", city, "_|(.csv$)"), "",
    already_done[grepl(city, already_done)]))
  if(length(already_done) > 0){
    first_page = already_done[already_done == max(already_done)] + 1
  } else {first_page = 1}

  # LOOP 1: Scrape page by page
  for (i in first_page:pages){
    # status info
    print(paste0("SCRAPING PAGE ", i, "/", pages, " -------------------------------------------"))
    # random waiting time
    Sys.sleep(runif(1, 1, 6))

    # go to next page if in page 2+
    if(i != 1){
      next_page = paste0("https://www.tripadvisor.com",
                         home %>%
                           html_nodes(".nav.next") %>%
                           html_attr("href") )
      home = jump_to(home, next_page)
    }

    # Get restaurants in this page
    rest_url = home %>%
      html_nodes(".property_title") %>%
      html_attr("href")

    # LOOP 2: Scrape restaurants in a single page
    for (j in rest_url){
      print(str_sub(j, str_locate(j, "Reviews-")[2]+1, -1L-5))
      # random waiting time
      Sys.sleep(runif(1, 1, 3))
      rest_page = read_html(paste0("https://www.tripadvisor.com", j))
      rest_data = rbind(rest_data, read_restaurant(rest_page))
    }

    # EVERY 10 PAGES, SAVE BACKUP
    if(i %in% seq(0,1000,10)){
      filename_backup = paste0("tripadvisor_project/files/rest_data_", city, "_", i, ".csv")
      write.csv(rest_data, filename_backup, row.names = FALSE)
    }


  }

  # Save the whole thing if we made it here
  filename = paste0("tripadvisor_project/files/rest_data_", city, ".csv")
  write.csv(rest_data, filename, row.names = FALSE)
  # And remove the backup files
  backups = list.files("tripadvisor_project/files")
  backups = backups[grepl(paste0(city, "_\\d+.csv"), backups)]
  file.remove(paste0("tripadvisor_project/files/", backups))

}
