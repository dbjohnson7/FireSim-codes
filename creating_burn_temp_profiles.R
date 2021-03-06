# --------------------
# 
# Title: creating-burn-temp-profiles
# Author: Dana Johnson
# Date: 2020-Feb-3
#
# Purpose: This is code to plot the temperature profiles during simulated burns.
# Can I add this to Git?
# --------------------
# Import packages
library(tidyverse)
library(stringr)
library(ggplot2)
# --------------------

setwd("C:/Users/danab/Box Sync/WhitmanLab/Projects/WoodBuffalo/FireSim2019/data/burn-thermocouple-temp-logs/Raw_Temp_Data/")

# Read temperature data
df <-read.csv('../Temp-all-burns-decimated.csv')

# Fix column name
df <- rename(df, Core.ID = ï..Site_ID)

df$Burn_severity <- ordered(df$Burn_severity,levels=c("Low_Sev", "High_Sev"))
head(df)

# Change time to numeric
class(df$time_s)
df$time_s = as.numeric(df$time_s)

# Create names vector 
names.vec <- seq(1,19, by=1)

# Create output dataframe
output.df <- data.frame("Core.ID" = NULL, 
                            "Site" = NULL, 
                            "Core" = NULL,
                            "time_s" = NULL,
                            "Thermo_position" = NULL,
                            "Temp" = NULL,
                            "Burn_severity" = NULL,
                            "Leading_species" = NULL,
                            "ten_s" = NULL,
                            "time_min" = NULL,
                            "time_hr" = NULL)

# Subset the data by taking every tenth time point
for (i in seq_along(names.vec)) {
  df.x <- df %>%
    subset(Site == names.vec[[i]]) %>%
    subset(time_s < 21600) %>%
    mutate(ten_s = time_s/10) %>%
    filter(ten_s == as.integer(ten_s)) %>%
    mutate(time_min = time_s/60) %>%
    mutate(time_hr = time_min/60) 
  
  # Filter out negative temperature values as a quality control
  df.x <- df.x %>%
    subset(Temp >= 0)
  
  output.df <- rbind(output.df, df.x)
}


head(output.df)


# --------------------
# PLOT
# Format burn severity labels
labels <- c(High_Sev = "High Severity \nTreatment", Low_Sev = "Low Severity \nTreatment")

palette = c("orange2", "red3")

# Plot all the temperature profiles by site
p1 = ggplot(output.df, aes(x = time_hr, 
                          y = Temp, 
                          group=Core.ID, 
                          color = Burn_severity,
                          shape = Thermo_position)) +
  geom_point() +
  facet_wrap(~Site) +
  labs(x = "Time from start of burn (hours)",
       y = expression(paste("Soil temperature ( ",degree ~ C, ")")),
       shape = "Position of Thermocouple",
       color = "Burn treatment") + 
  theme(axis.title.x = element_text(size = 14),
        axis.title.y = element_text(size = 14)) + 
  scale_color_manual(values = palette,
                     breaks = c('Low_Sev','High_Sev'),
                     labels = c("Low severity","High severity")) +
  scale_shape_discrete(breaks = c('Low','Mid'),
                       labels = c("Core Base","Base of organic horizon"))

p1

#ggsave("../../../figures/time-vs-temp-all-cores-all-sites.png", plot = p1, width = 8, height = 6)





# Plot time vs soil temperature at SITE 2
# Subset site 2
df.2 <- subset(output.df, Site == c(1,3,7,12))

# Plot all the temperature profiles by site
p2 = ggplot(df.2, aes(x = time_hr, 
                           y = Temp, 
                           group=Core.ID, 
                           color = Thermo_position)) +
  geom_point() +
  facet_grid(Burn_severity~Site, labeller = labeller(Burn_severity = labels)) +
  labs(x = "Time from start of burn (hours)",
       y = expression(paste("Soil temperature ( ",degree ~ C, ")")),
       color = expression("Position of \nThermocouple")) + 
  theme(axis.title.x = element_text(size = 14),
        axis.title.y = element_text(size = 14)) + 
  scale_color_manual(values = palette,
                     breaks = c('Low','Mid'),
                     labels = c("Core Base","Base of org horizon"))

p2

#ggsave("../../../figures/time-vs-temp-sites-1-3-7-and-12.png", plot = p2, width = 8, height = 4)





# Create color palette
palette = c("green4", "grey20")

# Format burn severity labels
labels <- c(High_Sev = "High Severity \nTreatment", Low_Sev = "Low Severity \nTreatment")

# Plot
p2 = ggplot(df.2, aes(x = time_hr, 
                           y = Temp, 
                           group=Core.ID, 
                           color = Thermo_position)) +
  geom_point() +
  facet_wrap(~Burn_severity, labeller = labeller(Burn_severity = labels)) +
  labs(x = "Time from start of burn (hours)",
       y = expression(paste("Soil temperature ( ",degree ~ C, ")")),
       color = expression(paste("Position of \nThermocouple"))) + 
  theme(axis.title.x = element_text(size = 14),
        axis.title.y = element_text(size = 14),
        strip.text.x = element_text(size = 14)) + 
  scale_color_discrete(breaks = c('Low','Mid'),
                       labels = c("Core Base","Base of organic horizon")) +
  scale_color_manual(values = palette) 
  
p2


#ggsave("../../../figures/time-vs-temp-site-1.png", plot = p2, width = 8, height = 10)










#######################################
# All the temperature profiles together:


all_df <-read.csv('../Temp-all-burns.csv')


# Use only first couple hours of burn time
temp_df <- subset(all_df, time_s < 1100)

temp_df <- all_df
 
# Use an as.integer to take every Nth data point
temp_df <- temp_df %>%
  mutate(ten_s = time_s/60) %>%
  filter(ten_s==as.integer(ten_s))

temp_df <- temp_df %>%
  mutate(time_hr = time_s/360)
  



df <- read.csv('../Temp-all-burns-decimated.csv')
head(df)
df <- df %>%
  mutate(time_hr = time_s/360)
#df.19 <- subset(df, Site==04)
#df.19 <- subset(df.19, Core==03)

df <- subset(df,Burn_severity == 'Low_Sev')
head(df)

p = ggplot(data = df, aes(x = time_hr, y = Temp, group=Thermo_position,color = Thermo_position)) +
  geom_point() +
  #geom_point(data = temp_df, aes(x = time_hr, y = Thermo_mid, color = Site)) + 
  labs(
    x = "Time from start of burn (hours)",
    y = "Temperature of core (degrees Celsius)") + 
  theme(axis.title.x = element_text(size = 14)) + 
  theme(axis.title.y = element_text(size = 14)) 
p = p + scale_color_discrete(name="Position of Thermocouple", 
                             breaks = c('Low','Mid'),
                             labels = c("Base of core","O/A horizon interface"))
# Add title to plot
p = p + ggtitle("Core temperature during and after \nlow severity burn treatment") +
  theme(plot.title = element_text(color = "black", hjust = 0.5, size = 18))
p = p + facet_wrap(~Site)
P = p + geom_hline(yintercept=0,color ='black')
p = p + ylim(10,600)
#p = p + xlim(0,24)
p

write.csv(temp_df,'../Temp-all-burns-decimated.csv')
