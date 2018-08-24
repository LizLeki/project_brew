#libraries dplyr & stringr loaded from sources

source("brew_cleaning.R")
source("census_data.R")


state21_df<-dplyr::select(census_demo,
                          GEO.display.label,
                          state_abbrev,
                          HD01_S023, #pop number 21+
                          HD02_S023  #pop percent 21+
) %>%
  rename(state_full = GEO.display.label)

state_level_df<-left_join(x = all_brews,
                          y = state21_df,
                          by = c("state" = "state_abbrev")
)


write.csv(state_level_df,
          "state_level_df.csv",
          row.names = FALSE)
