library(here)
library(tidyverse)
library(jsonlite)

processed_data_directory <- here("..","data","processed_data")
file_name <- "verbal_complexity"

#read experiment data
exp_data <- read_csv(here(processed_data_directory,paste0(file_name,"-alldata.csv")))

#double check that participant ids are unique
counts_by_random_id <- exp_data %>%
  group_by(random_id) %>%
  count()

#extract practice response
practice <- exp_data %>% 
  filter(trial_index==4) %>%
  mutate(json = map(response, ~ fromJSON(.) %>% as.data.frame())) %>% 
  unnest(json) %>%
  select(random_id,image_description) %>%
  rename(practice_response=image_description)

#join
exp_data <- exp_data %>%
  left_join(practice)

#filter and select relevant data
processed_data <- exp_data %>%
  filter(condition=="study") %>%
  select(-c(success:failed_video),-file_name) %>%
  group_by(participant) %>%
  mutate(
    trial_number=seq(n())
  ) %>%
  relocate(
    trial_number,.after="trial_index"
  )

#store processed and prepped data
write_csv(processed_data,here(processed_data_directory,paste0(file_name,"-processed-data.csv")))

#quick look
# ggplot(filter(processed_data,word_count<60),aes(surprisal,word_count))+
#   geom_point()+
#   geom_smooth(method="loess")
