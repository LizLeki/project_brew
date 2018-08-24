library(dplyr)
library(stringr)

abbrev<-read.csv("loc_abbrev.csv", stringsAsFactors = FALSE)

census_demo<-read.csv("DEC_10_DP_DPDP1/DEC_10_DP_DPDP1_with_ann.csv", stringsAsFactors = FALSE) %>%
  mutate_all(.funs = as.character)

census_key<-data.frame("variable" = names(census_demo),
                       "label" = NA)

for(.var in 1:length(census_demo)){
  census_key[.var,2]<-census_demo[1,.var]
}

census_demo<-census_demo[-1,]

census_demo<-mutate_all(census_demo,
                        .funs = funs(str_remove(string = .,
                                                pattern = "\\(.*\\)") %>%
                                       trimws(which = "both")
                                     )
) %>%
  mutate_at(.vars = vars(matches("HD.*")),
            .funs = as.numeric)


census_demo<-left_join(x = census_demo,
                       y = abbrev,
                       by = c("GEO.display.label" = "Location")
) %>%
  mutate(state_abbrev = Abbreviation) %>%
  dplyr::select(-Abbreviation)


rm(abbrev)