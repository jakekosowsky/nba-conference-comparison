library(tidyverse)
library(knitr)
library(ggpubr)
library(plotly)

standings <- read_csv("combined_standings.csv")
team_v_team <- read_csv("combined_team_vs_team_records.csv")

# The first section revolves around cleaning the data and formatting it in a way where West-East win% can be calculated
#Note that throughout the script the term "primary team" refers to the column `bb_ref_team_name` in the team_v_team data

# Converts the team_v_team data frame into a longer format where each row now contains the primary team, an opponent and the record between the two
team_v_team_longer <- team_v_team %>%
  pivot_longer(3:32, names_to = c("Opposing Team")) 

# Removes row where team plays against themselves and separates out the record column into two new variables containing wins and loses
team_v_team_longer <- team_v_team_longer %>%
  filter(!is.na(value)) %>%
  separate(value, c('Wins', 'Loses'), '-')

# The team_v_team_longer data frame does not have the conference for the primary team. In these steps, I merge the team_v_team_longer data frame with the standings to obtain the conference variable
teams_with_conferences_long <-distinct(standings, bb_ref_team_name,conference)
team_v_team_longer <- left_join(team_v_team_longer, teams_with_conferences_long, by = c("bb_ref_team_name"))

# Similarly, the opponent's conference is not in the data frame, so I again merge the team_v_team_longer data with the standings to obtain this variable
teams_with_conferences_short <-  distinct(standings, team_short,conference)
team_v_team_longer <- left_join(team_v_team_longer, teams_with_conferences_short, by = c("Opposing Team" = "team_short"))

# Cleans the 'conference' variable names
team_v_team_longer <- team_v_team_longer %>%
  rename(team_conference = conference.x) %>%
  rename(opposing_team_conference = conference.y)

# filters data to only include match ups where West teams are playing against East teams. This is done to prevent double counting
west_east_data <- team_v_team_longer %>%
  filter(team_conference == 'West') %>%
  filter(opposing_team_conference == 'East')

#Cleans the Wins and Loses variable
west_east_data$Wins <- as.numeric(west_east_data$Wins)
west_east_data$Loses <- as.numeric(west_east_data$Loses)

# sums the total number of wins and loses for the West in inter conference games
wins <- sum(west_east_data$Wins)
loses <- sum(west_east_data$Loses)

# computes winning percentage for West in inter conference games and prints results
100*wins/(wins + loses)
