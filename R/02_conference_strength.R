#Computes the number of wins and loses that the Western conference teams had against Eastern conference teams for every year
west_v_east_by_year <- west_east_data %>%
  group_by(season) %>%
  mutate(west_total_wins = sum(Wins)) %>%
  mutate(west_total_loses = sum(Loses)) 

#Creates variable indicating if the West has more wins then the East. I then summarize the data to only contains 16 rows; one for each year.
west_v_east_by_year <- west_v_east_by_year %>%
  mutate(west_more_wins = ifelse(west_total_wins >west_total_loses , 1 ,0)) %>%
  summarise('west_more wins' = mean(west_more_wins),west_total_wins = mean(west_total_wins),west_total_loses = mean(west_total_loses))

#Counts the number of years that the West had more wins in inter conference games and prints the result
sum(west_v_east_by_year$`west_more wins`)

#Computes a disparity variable indicating West wins - East wins. Removes all rows besides for the largest disparity
largest_disparity <- west_v_east_by_year %>%
  mutate(disparity = west_total_wins - west_total_loses) %>%
  top_n(1, disparity)

#Prints out the row with the largest disparity
kable(largest_disparity)

#Filters the data to only contain playoff teams
subset_standings <- standings %>%
  filter(playoffs == 'Yes') 

#For each season and conference, I filters the data to only contain playoff teams with the lowest winning percentage
subset_standings <- subset_standings %>%
  group_by(season, conference) %>%
  top_n(-1, win_pct) %>%
  ungroup() 

#For each conference I calculate the worst playoff team's average win percentage
subset_standings <- subset_standings %>%
  group_by(conference) %>%
  mutate(average_win_pct = mean(win_pct)) %>%
  summarize(average_win_pct = mean(average_win_pct))

kable(subset_standings)

#In the team_v_team_longer data frame, the primary teams playoff status is not included. To include this variable, the team_v_team_longer data frame is joined with the standings 
team_playoffs <- distinct(standings, season, bb_ref_team_name,playoffs)
team_v_team_longer <- left_join(team_v_team_longer, team_playoffs, 
                                by = c("season" = "season", "bb_ref_team_name" = "bb_ref_team_name"))

#Similarly, the opponent's playoff status is not included and therefore the team_v_team_longer data frame is again joined with the standings 
opposing_team_playoffs <- distinct(standings, season, team_short,playoffs)
team_v_team_longer <- left_join(team_v_team_longer, opposing_team_playoffs,
                                by = c("season" = "season", "Opposing Team" = "team_short"))

#Cleans the `playoffs` variable
team_v_team_longer_renamed <- team_v_team_longer %>%
  rename(Team_Playoffs = playoffs.x) %>%
  rename(Opposing_Team_Playoffs = playoffs.y) 

#Removes duplicates by only keeping match ups where West teams are the primary and are playing against East teams 
West_Vs_East <- team_v_team_longer_renamed %>%
  filter(team_conference != opposing_team_conference) %>%
  filter(team_conference == 'West') 

#Groups the data into four categories based on the following two features: whether the primary team made the playoffs and whether the opponent team made the playoffs. Summarizes the data to only contain 4 rows (each of the 4 permutations)
West_Vs_East <- West_Vs_East %>%
  group_by(Team_Playoffs, Opposing_Team_Playoffs ) %>%
  mutate(Wins = sum(as.numeric(Wins))) %>%
  mutate(Loses = sum(as.numeric(Loses))) %>%
  mutate(winning_percentage = Wins/(Loses+Wins)) %>%
  summarize(`Winning Percentage` = mean(winning_percentage))

#Prepares data for graphing
West_Vs_East <- West_Vs_East%>%
  mutate(Primary = ifelse(Team_Playoffs== 'Yes', 'Playoff Teams', 'Non-Playoff Teams')) %>%
  mutate(Against = ifelse(Opposing_Team_Playoffs == 'Yes', 'Vs. East Playoff Teams', 'Vs. East Non-Playoff Teams'))

#Creates chart containing the results of Western conference playoff teams
 playoffs <-West_Vs_East %>%
  filter(Primary == 'Playoff Teams') %>%
  ggplot(aes(x= Against, y= `Winning Percentage`, fill=Against)) + 
  geom_col() +
  labs(x = "") +
  ylim(0,1) +
  ggtitle("West Playoff Teams") +
  scale_fill_manual(values = c("#002c60", "#ef3b24")) +
  theme(plot.title = element_text(hjust = 0.5, vjust = -112),
        panel.background = element_blank(),
        panel.grid.major.y = element_line( size=.1, color="grey"),
        legend.position="none")

#Creates chart containing the results of the Western conference non_playoff teams
non_playoffs <-West_Vs_East %>%
  filter(Primary == 'Non-Playoff Teams') %>%
  ggplot(aes(x= Against, y= `Winning Percentage`, fill = Against)) + 
  geom_col() +
  labs(x = "") +
  ylim(0,1) +
  ggtitle("West Non-Playoff Teams") +
  scale_fill_manual(values = c("#002c60", "#ef3b24")) +
  theme(plot.title = element_text(hjust = 0.5, vjust = -112),
        panel.background = element_blank(),
        panel.grid.major.y = element_line( size=.1, color="grey"),
        legend.position="none") 

#Combines the plots into one and adds a title
plot <- ggarrange(playoffs, non_playoffs)   
annotate_figure(plot, top = text_grob("Performance of Western Conference Teams Versus Eastern Conference Teams", 
                                      size =16))
