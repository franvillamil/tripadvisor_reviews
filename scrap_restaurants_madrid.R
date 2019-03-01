if(!grepl("tripadvisor$", getwd())){stop("Working directory?")}
library(rvest)
library(stringr)
library(dplyr)
options(stringsAsFactors = FALSE, timeout = 4000000)

# --- Restaurant-specific function --------------------------------------------

read_restaurant = function(rest_url){

  # URL
  url = paste0("https://www.tripadvisor.com", rest_url)
  # Go to page
  rest_page = read_html(url)
  # Name
  name = rest_page %>%
    html_node(".h1") %>%
    html_text()
  # Rank
  rank = as.integer(gsub("\\#|,", "",
                         rest_page %>%
                           html_node(".popIndexValidation span") %>%
                           html_text() ))
  # Address
  address = rest_page %>%
    html_node(".address") %>%
    html_text()
  # Tags
  tags = rest_page %>%
    html_node(".header_links") %>%
    html_text()
  # Reviews
  reviews = gsub(",", "", rest_page %>%
                   html_node(".is-3") %>%
                   html_text() )
  reviews_all = gsub("\\(|\\)|,", "", rest_page %>%
                       html_node(".reviews_header_count") %>%
                       html_text()) %>% as.integer()
  if(!is.na(reviews)){
    reviews_eng = str_match(reviews, "English\\s\\((\\d+)\\)")[,2]
    reviews_eng = as.integer(gsub(",", "", reviews_eng))
    reviews_spa = str_match(reviews, "Spanish\\s\\((\\d+)\\)")[,2]
    reviews_spa = as.integer(gsub(",", "", reviews_spa))
  } else {
    reviews_eng = NA
    reviews_spa = NA
  }

  # Put together and return
  restaurant_data = data.frame(url = url, name = name, rank = rank,
                               address = address, tags = tags, reviews_all = reviews_all,
                               reviews_eng = reviews_eng, reviews_spa = reviews_spa)

  return(restaurant_data)

}

# --- Scraping restaurants in Madrid ------------------------------------------

home = html_session("https://www.tripadvisor.com/Restaurants-g187514-Madrid.html")

# DF to fill in
rest_data = data.frame()

# Max number of pages
pages = gsub("\\\n", "", home %>%
               html_nodes(".pageNum.taLnk") %>% html_text() )
pages = as.integer(pages[length(pages)])

# Start depending on which ones were made last time
already_done = list.files("files/madrid")
already_done = as.integer(gsub(paste0("rest_data_madrid_|(.csv$)"), "",
                               already_done[grepl(city, already_done)]))
if(length(already_done) > 0){
  first_page = already_done[already_done == max(already_done)] + 1
} else {first_page = 1}

# LOOP 1: Scrape page by page
for (i in first_page:pages){
  # status info
  print(paste0("Scraping page ", i, "/", pages, " -------------------------------------------"))
  # random waiting time
  Sys.sleep(runif(1, 1, 6))

  # Go to next page if in page 2+
  if(i != 1){
    next_page = paste0("https://www.tripadvisor.com",
                       home %>%
                         html_nodes(".nav.next") %>%
                         html_attr("href") )
    home = jump_to(home, next_page)
  }

  # Get restaurants in this page
  rest_url_list = home %>%
    html_nodes(".property_title") %>%
    html_attr("href")

  # LOOP 2: Scrape restaurants in a single page
  for (j in rest_url_list){
    print(str_sub(j, str_locate(j, "Reviews-")[2]+1, -1L-5))
    # random waiting time
    Sys.sleep(runif(1, 1, 3))
    rest_data = rbind(rest_data, read_restaurant(j))
  }

  # Save backup every 25 pages
  if(i %in% seq(0, 1000, 25)){
    filename_backup = paste0("files/madrid/rest_data_madrid_", i, ".csv")
    write.csv(rest_data, filename_backup, row.names = FALSE)
  }


}

# Save the whole thing if we made it here
filename = paste0("files/madrid/rest_data_madrid.csv")
write.csv(rest_data, filename, row.names = FALSE)
# And remove the backup files
backups = list.files("files/madrid")
backups = backups[grepl("madrid_\\d+.csv", backups)]
file.remove(paste0("files/madrid/", backups))
