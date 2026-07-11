#Creates `Made_Playoffs` variable to indicate if a team made the playoffs. All variables besides for win_pct and Made_playoffs are then removed
lr_standings <- standings %>%
  mutate(Made_Playoffs = ifelse(playoffs == 'Yes',1,0)) %>%
  select(win_pct, Made_Playoffs)

#Logistic regression model is fitted to the data
model <- glm(Made_Playoffs ~ win_pct, family = "binomial", data = lr_standings)

#Coefficients are printed
model$coefficients

#Evaluate the fitted model at a .500 winning percentage.
1/(1+exp(-(-20.88+ (0.50*42.4))))

#The same process is done as above to create a logistic regression model except now the is_west is added as a variable
lr_standings <- standings %>%
  mutate(Made_Playoffs = ifelse(playoffs == 'Yes',1,0)) %>%
  mutate(is_west = ifelse(conference == 'West', 1, 0)) %>%
  select(win_pct, Made_Playoffs, is_west)

#Model is fitted to data
model <- glm(Made_Playoffs ~ win_pct +is_west, family = "binomial", data = lr_standings)

#The formula from above describing logistic regression is applied except with one additional coefficient and variable


#Values are computed using the above formula. The variables "model$coefficients[1:3]" contain the three coefficients and 0.5 and 0 are plugged in for x1 and x2 respectively
east <- 1/(1+exp(-(model$coefficients[1]+ (0.50*model$coefficients[2])+(0*model$coefficients[3]))))

#The same thing is applied to the west. The only difference is x2 is now equal to 1
west  <- 1/(1+exp(-(model$coefficients[1]+ (0.50*model$coefficients[2])+(1*model$coefficients[3]))))

#Prints the is_west coefficient and each conference's playoff probability
paste("is_west coefficent:", model$coefficients[3])

paste("East Probability: ", 100*as.numeric(east), "%")

paste("West Probability: ", 100*as.numeric(west), "%")
