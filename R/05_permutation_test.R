#Creates a vector with length 10,000 to store all of the is_west coefficients
is_west_vector <- c(1:10000)

#Creates an `is_west` indicator variable. I then remove all variables not used in the logistic regression. Note the season variable is still kept so that when conferences are reassigned, the teams for each season are distributed evenly

perm_standings<- standings %>%
    mutate(is_west = ifelse(conference == 'West',1,0)) %>%
    mutate(made_playoffs = ifelse(playoffs == 'Yes',1,0)) %>%
    select(win_pct, is_west, made_playoffs,season)


for(i in 1:10000){
  #For each iteration, the data is grouped by season. The is_west column is then replaced by a new is_west column that randomly distributes 15 "1"s and 15 "0"s for each season 
  perm_standings <- perm_standings %>%
    group_by(season) %>%
    mutate(is_west = sample(is_west, size=30, replace = FALSE )) %>%
    ungroup()

  #A new logistic regression model is fitted to the altered data frame
  model <- glm(made_playoffs ~ win_pct +is_west, family = "binomial", data = perm_standings)
  
  #The is_west coefficient is stored in the vector
  is_west_vector[i] <- model$coefficients[3]
}

library(grid)
#Converts the is_west vector into a data frame
is_west_df <- as.data.frame(is_west_vector)

#Creates histogram showing the distribution of the randomly generated `is_west` variables. Additionally, the observed coefficient is added to the plot 
plot <- ggplot(is_west_df, aes(x=is_west_vector)) + 
  geom_histogram(bins = 30) +
  xlim(-3,3) +  
  xlab("`is_west` coefficients") +
  ylab("Frequency") +
  ggtitle("Distribution of Randomly Generated is_west Coefficents") + 
  geom_point(aes(x=-2.875, y=0), colour="blue", size = 3)  + 
  annotate(geom="text", x=-2.4, y=75, label="Actual Coefficent Observed",color="red", size = 3)+ 
  theme( panel.background = element_blank(), 
         panel.grid.major.y = element_line( size=.1, color="grey"),  
         axis.title = element_text(face="bold"), 
         plot.title = element_text(hjust = 0.5)) 
  
# Converts the plot to be interactive
ggplotly(plot, tooltip = c("count"))
