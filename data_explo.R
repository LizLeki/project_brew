library(dplyr)
library(DT)
library(ggplot2)
library(viridis)
library(png)
library(grid)

state_df<-read.csv("state_level_df.csv", stringsAsFactors = FALSE)
us_shape<-fiftystater::fifty_states
beer_mug<-readPNG("beer-vector-art.png") %>%
  rasterGrob(interpolate = TRUE)


##### ----- Creating state summary table -----
state_summaries<-group_by(state_df, state) %>%
  summarise(state_full = tolower(unique(state_full)),
            brewery_count = n(),
            pop_over21 = mean(HD01_S023),
            drink_pop10k = pop_over21/10000,
            perc_pop_over21 = mean(HD02_S023),
            bar_count = sum(brewery_type == "Bar"),
            bars_per_drinkers = bar_count/drink_pop10k,
            brewpub_count = sum(brewery_type == "Brewpub"),
            brewpub_per_drinkers = brewpub_count/drink_pop10k,
            contract_count = sum(brewery_type == "Contract"),
            contract_per_drinkers = contract_count/drink_pop10k,
            large_count = sum(brewery_type == "Large"),
            large_per_drinkers = large_count/drink_pop10k,
            micro_count = sum(brewery_type == "Micro"),
            micro_per_drinkers = micro_count/drink_pop10k,
            planned_count = sum(brewery_type == "Planning"),
            planned_per_drinkers = planned_count/drink_pop10k,
            proprietor_count = sum(brewery_type == "Proprietor"),
            proprietor_per_drinkers = proprietor_count/drink_pop10k,
            regional_count = sum(brewery_type == "Regional"),
            regional_per_drinkers = regional_count/drink_pop10k
            )

state_summaries %>%
  mutate_if(is.numeric, round, digits = 3) %>%
  DT::datatable(rownames = FALSE,
              options = list(
                initComplete = JS("function(settings, json) {","$(this.api().table().header()).css({'background-color': '#2f658c', 'color':
                                '#fff'});",
                                "}")
              )
)


##### ----- Joining state-level data to geo data -----

us_shape<-left_join(x = us_shape,
                    y = state_summaries,
                    by = c("id" = "state_full"))
glimpse(us_shape)


##### ----- Summary plots -----

png(filename = "state_brewpubs.png",
    width = 1200,
    height = 1080)

ggplot(data = us_shape) +
  geom_polygon(aes(x = long, y = lat, group = group, fill = brewpub_per_drinkers),
               color = "black") +
  #scale_fill_continuous(name = "", low = "#ffffcc",high = "#ffb300") +
  scale_fill_viridis(name = "",
                     option = "inferno",
                     begin = .65,
                     direction = -1) +
  coord_equal() +
  labs(title = "United States Brewpubs",
       subtitle = "per 10k Residents age 21+",
       caption = "Source: https://github.com/LizLeki/project_brew") +
  theme_void() +
  theme(legend.key.size = unit(1, "in"), 
        legend.text = element_text(size = 20),
        plot.title = element_text(size = 40, hjust = .5),
        plot.subtitle = element_text(size = 25, hjust = .5),
        plot.caption = element_text(size = 12)
  ) +
  annotation_custom(beer_mug, xmin = -80, xmax = -60, ymax = 35, ymin = 25)

dev.off()


