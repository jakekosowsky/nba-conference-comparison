#filters the data to only contain data from the 2016 Thunder
table <- team_v_team_margins %>%
  filter(season == 2016) %>%
  filter(bb_ref_team_name == "Oklahoma City Thunder")

kable(table)
