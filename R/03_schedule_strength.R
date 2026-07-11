#Adds variable to the standings data frame that contains a team's point margins.
standings_added <- standings %>%
  mutate(team_margin = points_scored_per_game - points_allowed_per_game)

#The team_v_team_longer data frame does not contain the point margin for each opposing team; only the standings data frame does. I merge the team_v_team_longer data frame with the standings_added data frame to include this variable
standings_with_margin <- distinct(standings_added, season, team_short, team_margin)
team_v_team_margins <- left_join(team_v_team_longer, standings_with_margin, 
                                 by = c("Opposing Team" = "team_short", "season" = "season"))

#Cleans the wins and loses variables
team_v_team_margins <- team_v_team_margins %>%
  mutate(games = as.numeric(Wins)+as.numeric(Loses)) 

#Groups the data by season and primary team so that the function below applies to just one team on a given year 
team_v_team_margins <- team_v_team_margins %>%
  group_by(season, bb_ref_team_name) 

#Computes the average point margin for each team's opponents using the formula above
team_v_team_margins <- team_v_team_margins%>%
  mutate(weighted_games = games*team_margin) %>%
  mutate(total_weight = sum(weighted_games)) %>%
  mutate(total_games = sum(games))%>%
  mutate(average_point_margin = total_weight/total_games ) %>%
  ungroup()

#Shortens the data frame to contain one row per season/team combination
team_v_team_margins <- distinct(team_v_team_margins, season, bb_ref_team_name, average_point_margin) 

# The team_v_team_margins data set only contains the point margins of the opponent team and not of the primary team. I therefore merge the team_v_team_margins data set with the standings to add this variable
standings_with_margin <- distinct(standings_added, season, bb_ref_team_name, conference, team_margin, team_short)
team_v_team_margins <- left_join(team_v_team_margins, standings_with_margin, by = c("bb_ref_team_name", "season"))

# Renames the variables to match the plot
team_v_team_margins <- team_v_team_margins %>%
  rename(`Average Opponent Point Margin` = average_point_margin) %>%
  rename(`Team Point Margin` =  team_margin) %>%
  rename(Conference = conference)

#Adds a labels column to only include a label of "TEAM YEAR" if it is one of the teams labeled on the graphs. If it is not one the 3 teams then the labels variable is left blanks
team_v_team_margins <- team_v_team_margins %>%
  mutate(labels=ifelse(season %in% c(2019,2011) & team_short %in% c('CHI', 'LAL', 'DAL') & 
                         (`Average Opponent Point Margin` > 0.39 | `Average Opponent Point Margin` < -0.6),
                       paste(team_short, season),""))

#Plots all the points, adds 2 regression lines and formats the data
team_v_team_margins %>%
  ggplot(aes(x = `Team Point Margin` , y = `Average Opponent Point Margin`, color = Conference)) + 
  geom_point() + 
  geom_smooth(method="lm", se = FALSE) + 
  theme(legend.position="bottom" ,  
        panel.background = element_blank(), 
        panel.grid.major.y = element_line( size=.1, color="grey"), 
        axis.title = element_text(face="bold")) + 
  scale_color_manual(values = c("#002c60", "#ef3b24"))  + 
  geom_text(aes(label= labels), vjust=-0.3, hjust = -0.02, colour="black", size = 3) + 
  ggtitle("Team's Point Margin vs. Average Opponent Point Margin")
