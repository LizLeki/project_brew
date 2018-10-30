library(stringr)
library(rvest)
library(RSelenium)
library(dplyr)

# ----- In Docker -----

#docker pull selenium/standalone-firefox
#docker run -d -p 4445:4444 selenium/standalone-firefox
#docker ps
#docker-machine ip

# ---- Connect to Image -----

remDr<-remoteDriver(remoteServerAddr = "192.168.99.100",
                    port = 4445L)

remDr$open()
remDr$getStatus()

# ---- Navigate to page and populate table -----

remDr$navigate("https://www.brewersassociation.org/directories/breweries/")

remDr$screenshot(display = TRUE)

country_button<-remDr$findElement(using = "css selector",value = "#country .dropdown-toggle")
country_button$clickElement()

US<-remDr$findElement(using = "xpath", value = "//*[@data-country-id='United States']")
US$clickElement()

##### ----- Scrape table -----

full_page<-read_html(remDr$getPageSource()[[1]]) 

##### ----- Format into data frames -----

#all information in a single string variable
full_table<-html_nodes(full_page, css = "div.brewery") %>%
  html_text() %>%
  dplyr::data_frame(full_string = .) %>%
  dplyr::mutate(date = Sys.Date())

table_list<-lapply(c("li.name", "li.brewery_type", "li.address", "li.telephone", "li.url"), function(.info){
  
  html_nodes(full_page, css = .info) %>%
    html_text() %>%
    data.frame() %>%
    data.table::setnames(old = ".",
                         new = str_remove(.info, "li.")
    )
})

full_data_index<-sapply(table_list, function(.df){
  nrow(.df) == nrow(full_table)
})

##### ----- Fill in missing data -----

#address line2 (city,state zip)
html_nodes(full_page, css = "div.brewery li") %>% 
  html_text() %>%
  dplyr::data_frame(all_info = .) -> long_df

line2_ind<-long_df$all_info %in% table_list[[3]]$address %>%
  which() + 1

address2<-data.frame(long_df[line2_ind,]) %>%
  transmute(address2 = all_info)

#which rows contain phone numbers?
phone_ind<-str_detect(string = full_table$full_string, pattern = "Phone")

#which rows contain websites?
url_ind<-str_detect(string = full_table$full_string,
                    pattern = regex("www\\.|\\.co|\\.net|\\.beer|\\.bar|\\.pub|\\.edu",
                                    ignore_case = TRUE)
)

kicked_urls<-table_list[[5]]$url[!(str_detect(string = table_list[[5]]$url,
                                              regex("www\\.|\\.co|\\.net|\\.beer|\\.bar|\\.pub|\\.edu",
                                                    ignore_case = TRUE)))]

table_list[[5]]<-table_list[[5]] %>%
  filter(!(url %in% kicked_urls))

##### The final table #####

fin_df<-purrr::reduce(table_list[full_data_index], cbind) %>%
  cbind(address2)

fin_df$phone[phone_ind]<-as.character(table_list[[4]]$telephone)
fin_df$website[url_ind]<-as.character(table_list[[5]]$url)
fin_df$pull_date<-Sys.Date()

length(as.character(table_list[[5]]$url[url_ind]))

sapply(fin_df, function(.col){sum(!is.na(.col))})
sapply(table_list, nrow)

##### ----- Export data -----

write.csv(fin_df, "all_brews.csv", row.names = FALSE)

write.csv(fin_df, paste0("table_iterations/", Sys.Date(), ".csv"), row.names = FALSE)
