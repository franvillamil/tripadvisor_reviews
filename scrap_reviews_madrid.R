library(rvest)
library(stringr)
library(dplyr)
options(stringsAsFactors = FALSE, timeout = 4000000)

rest_list = read.csv("files/madrid/rest_data_madrid.csv")

# --- Reading reviews of each restaurant (english & spanish) ------------------

read_reviews = function(rest_url, language){

  if(language %in% c("english", "eng")){
    url = rest_url
  } else if (language %in% c("spanish", "spa")){
    url = gsub("tripadvisor.com", "tripadvisor.es", rest_url)
  }

  rest_page = html_session(url)

  # Get pages of reviews
  n_rev_pages = rest_page %>%
    html_node("#REVIEWS .pageNum.last.taLnk") %>%
    html_text() %>% as.integer()

  # If only one page, previous node is mossing
  if(is.na(n_rev_pages)){n_rev_pages = 1}

  reviews = c()
  page = c()

  for(np in 1:n_rev_pages){
    if(np != 1){
      next_page = rest_page %>%
        html_nodes(".nav.next") %>%
        html_attr("href")
      next_page = paste0(gsub("/Restaurant.*$", "", url), next_page[1])
      rest_page = jump_to(rest_page, next_page)
    }
    reviews = c(reviews, rest_page %>%
                  html_node(xpath = '//*[@id="taplc_location_reviews_list_resp_rr_resp_0"]/div') %>%
                  html_text() )
    page = c(page, np)
  }

  reviews_df = data.frame(
    url = rep(gsub("tripadvisor.es", "tripadvisor.com", url), length(reviews)),
    language = rep(language, length(reviews)),
    reviews = reviews, page = page)

  return(reviews_df)

}

# --- Scraping ----------------------------------------------------------------

reviews_data = data.frame()

for(i in 1:nrow(rest_list)){
  # status info
  print(paste0(i, "/", nrow(rest_list)))
  # random waiting time
  Sys.sleep(runif(1, 1, 6))
  # read reviews in both languages
  reviews_data = rbind(reviews_data,
                       read_reviews(rest_url = rest_list$url[i], language = "english"),
                       read_reviews(rest_url = rest_list$url[i], language = "spanish"))
  # every 100 restaurants, save
  if(i %in% seq(100, 10000, 100)){
    print(paste0("Saving backup (", i, ") ---------------------------------------"))
    write.csv(reviews_data, "files/madrid/reviews_data_madrid_backup.csv", row.names = FALSE)
  }

}

# Save the whole thing
write.csv(reviews_data, "files/madrid/reviews_data_madrid.csv", row.names = FALSE)
# And delete backups
file.remove("files/madrid/reviews_data_madrid_backup.csv")
