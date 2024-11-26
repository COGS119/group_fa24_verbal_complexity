library(here)
library(tidyverse)
library(jsonlite)

processed_data_directory <- here("..","data","processed_data")
file_name <- "verbal_complexity"

#read experiment data
exp_data <- read_csv(here(processed_data_directory,paste0(file_name,"-alldata.csv"))) %>%
  rename(participant_id=participant)

#double check that participant ids are unique
counts_by_random_id <- exp_data %>%
  group_by(random_id,participant_id) %>%
  count()
#output to track participants
write_csv(counts_by_random_id,here(processed_data_directory,paste0(file_name,"-participant-list.csv")))

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
  group_by(participant_id) %>%
  mutate(
    trial_number=seq(n())
  ) %>%
  relocate(
    trial_number,.after="trial_index"
  )

#store processed and prepped data
write_csv(processed_data,here(processed_data_directory,paste0(file_name,"-processed-data.csv")))
