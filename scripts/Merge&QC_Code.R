#===============================================================================
# Sentinels Larval Crab Monitoring | Light Trap Abundance Data
# Merge data from different years and filter according to QAQC codes to produce
# master dataset
#
# Input:
#     2022_CountData_QC.csv
#     2023_CountData_QC.csv
#
# Output:
#     MASTER_QAQC_LT_counts.csv
#
# Heather Earle
# Created 11/2023
# Updated 
#===============================================================================

#clean up Enivronment
rm(list = ls(all = TRUE))
options(stringsAsFactors = FALSE)

library(tidyverse)




#==== FORMATTED COUNT DATA =====================================================

# Sentinels Count Data - all years available
counts22 <- read_csv("data/2022/2022_CountData_QC.csv")
counts23 <- read_csv("data/2023/2023_CountData_QC.csv")

#combine them
counts_all <- rbind(counts22, counts23)

###Bring in Stations data to get lats and longs
stations <- read.csv("data/Master_Stations.csv") %>% 
  dplyr::select( Site = Site, Lat, Lon)

#join datasets, now all entries have an associated lat and long
counts_master <- merge(counts_all,stations,by=c("Site"))


#==== QAQC DETERMINATIONS ======================================================

# MET - missing metadata (hours or nights fished)
# BAT - trap fished for over 25 hours
# HRS - timer on/off times were off by 1+ hr
# DNF - trap did not fish properly
# INC - trap did not fish for over 25% of nights in any given month from 
# ERR - protocols not followed properly and counts likely not accurate
#       Apr 15 to Sep 1

# These are assigned using code Assign_QAQC.R before importing here

# For annual reports and Hakai Data Catalogue, remove all MET, DNF, ERR, & INC
# entries:
counts_QC <- counts_master %>%  filter(Error_Code=="None" | Error_Code== "HRS" 
                                        | Error_Code == "BAT")

##Create spreadsheet w/ removed entries to keep track
counts_removed <- counts_master %>% filter (Error_Code =="DNF" | Error_Code =="MET" |
                                            Error_Code == "ERR" | Error_Code == "INC")


#==== MASTER for GITHUB ===================================================================


# Select columns for dataframe that will be on github/hakai catalogue
master_counts <- counts_QC %>%
  select(Code, Site, Lat, Lon, Year, Month, Date, 
         Nights_Fished, Hours_Fished, Weather, Subsample, 
         Metacarcinus_magister_megalopae,
         Metacarcinus_magister_instar, 
         TotalMmagister = TotalCmagister, 
         CPUE_Night, CPUE_Hour, Error_Code)

write_csv(master_counts, "data/Master_QAQC_LightTrap_Counts.csv")


#================================ END ==========================================
