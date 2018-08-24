library(dplyr)
library(stringr)

all_brews<-read.csv("all_brews.csv", stringsAsFactors = FALSE, na.strings = c("", ",  "))


##### ----- Cleaning original info -----

all_brews<-mutate(all_brews,
                  pull_date = as.POSIXct(pull_date),
                  brewery_type = str_remove(string = brewery_type,
                                            pattern = "Type: "),
                  phone = str_remove(string = all_brews$phone,
                                     pattern = "Phone: "),
                  address2 = str_remove(string = address2,
                                        pattern = " \\| Map")
) %>%
  mutate(address2 = case_when(is.na(address2) & str_detect(string = name,
                                                           pattern = "Brewery in Planning -|Brewery In Planning") ~
                                str_extract(string = name,
                                            pattern = "-.*") %>%
                                str_remove(pattern = ".*- "),
                              TRUE ~ address2),
         city = str_extract(string = address2,
                            pattern = "^.*,") %>%
           str_remove(pattern = ","),
         state = str_extract(string = address2,
                             pattern = ", ..") %>%
           str_remove(pattern = ", ") %>%
           toupper()
  ) %>%
  mutate_all(trimws, which = "both")
  


