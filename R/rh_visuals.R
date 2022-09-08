
# create tables/graphs used in results section--------------------------------------------------#
format_ridership_table <- function(mode_choice_table){
  ridership <- mode_choice_table %>%
    #instead of renaming, just fix the names in targets and rerun (will take like 1hr)
    rename(rename_list) %>% select(1,11,6,10,9,5,4,8,7,3,2) %>%
    pivot_longer(!mode,names_to = "Scenario Name", values_to = "ridership") %>%
    filter(mode %in% c("ride_hail","ride_hail_pooled","ride_hail_transit")) %>%
    pivot_wider("Scenario Name", names_from=mode,values_from=ridership) %>%
    mutate_all(~replace(., is.na(.), 0.000)) %>%
    #mutate(across(!"Scenario Name", ~paste0(.,"%")))
    mutate("Total" = ride_hail + ride_hail_pooled+ride_hail_transit) %>%
    rename("Ride Hail" = "ride_hail",
           "Pooled Ride Hail" = "ride_hail_pooled",
           "Ride Hail to Transit" = "ride_hail_transit") 
}

format_waits_graph <- function(wait_times){
  waittimes <- wait_times %>%
    group_by(ScenarioName) %>%
    mutate(mean = mean(rhReserveTime),
           max = max(rhReserveTime),
           min = min(rhReserveTime)) %>%
    mutate(ScenarioName = as.factor(ScenarioName)) %>%
    mutate(ScenarioName = case_when(
      ScenarioName == "All Modes - All Variables - W/ RH" ~ "AsimBeamAll:PPL",
      ScenarioName == "All Modes - Path Variables - W/ RH" ~ "AsimBeamAll:Path",
      ScenarioName == "RH Modes - All Variables - W/ RH" ~ "AsimBeamRideHail:PPL",
      ScenarioName == "RH Modes - Path Variables - W/ RH" ~ "AsimBeamRideHail:Path",
      ScenarioName == "No Modes - W/ RH" ~ "AsimRideHail",
      ScenarioName == "All Modes - All Variables - No RH" ~ "BeamAll:PPL",
      ScenarioName == "All Modes - Path Variables - No RH" ~ "BeamAll:Path",
      ScenarioName == "RH Modes - All Variables - No RH" ~ "BeamRideHail:PPL",
      ScenarioName == "RH Modes - Path Variables - No RH" ~ "BeamRideHail:Path"
    )) %>%
    mutate(BeamModel = ifelse(grepl("BeamRideHail",ScenarioName),"RideHail",ifelse(grepl("BeamAll",ScenarioName),"All","None")))
  waittimes$ScenarioName <- factor(waittimes$ScenarioName, 
                                   levels=c("AsimRideHail", "BeamRideHail:Path", "BeamRideHail:PPL", "AsimBeamRideHail:Path","AsimBeamRideHail:PPL",
                                            "BeamAll:Path","BeamAll:PPL","AsimBeamAll:Path", "AsimBeamAll:PPL"))
  
  ggplot(waittimes, aes(x = ScenarioName, y = rhReserveTime, fill = factor(BeamModel)), alpha = .3) + 
    geom_violin() + geom_boxplot(width = 0.3) +
    scale_fill_manual(values = c("dodgerblue1","gold1","lightpink1")) +
    geom_text(aes(label = round(mean,1), y = mean + 1), size = 2)  +  
    xlab("Scenario Name") +
    ylab("Wait Time (min)") +
    theme_bw() +
    labs(fill="Beam Mode Choice") +
    theme(axis.text.x = element_text(angle=90, hjust=1)) +
    geom_text(aes(label = round(max,1),  y = max + 1), size = 1.8) +
    geom_text(aes(label = round(min,1),  y = min - 1), size = 1.8)
}

rename_list = c(
  "AsimBeamAll:PPL" = "All Modes - All Variables - W/ RH",
  "AsimBeamAll:Path" = "All Modes - Path Variables - W/ RH",
  "AsimBeamRideHail:PPL" = "RH Modes - All Variables - W/ RH",
  "AsimBeamRideHail:Path" = "RH Modes - Path Variables - W/ RH",
  "AsimRideHail" = "No Modes - W/ RH",
  "BeamAll:PPL" = "All Modes - All Variables - No RH",
  "BeamAll:Path" = "All Modes - Path Variables - No RH",
  "BeamRideHail:PPL" = "RH Modes - All Variables - No RH",
  "BeamRideHail:Path" = "RH Modes - Path Variables - No RH",
  "NoRideHail" = "No Modes - No RH"
)

rename_list_graph = c(
  "AsimBeamAll:PPL" = "All Modes - All Variables - W/ RH",
  "AsimBeamAll:Path" = "All Modes - Path Variables - W/ RH",
  "AsimBeamRideHail:PPL" = "RH Modes - All Variables - W/ RH",
  "AsimBeamRideHail:Path" = "RH Modes - Path Variables - W/ RH",
  "AsimRideHail" = "No Modes - W/ RH",
  "BeamAll:PPL" = "All Modes - All Variables - No RH",
  "BeamAll:Path" = "All Modes - Path Variables - No RH",
  "BeamRideHail:PPL" = "RH Modes - All Variables - No RH",
  "BeamRideHail:Path" = "RH Modes - Path Variables - No RH",
  "NoRideHail" = "No Modes - No RH"
)

modesP <- c(bike = "springgreen2", bike_transit = "springgreen4", car = "dodgerblue",hov2 = "skyblue",hov2_teleportation = "skyblue3",hov3 = "cadetblue1",hov3_teleportation = 'cadetblue3', ride_hail = "orchid",ride_hail_pooled = "plum1", ride_hail_transit = "violet",walk_transit = "coral1", drive_transit = "coral3", walk = "goldenrod2")
modesP2 <-c(nomode = "darkgrey",bike = "springgreen2", bike_transit = "springgreen4", car = "dodgerblue",hov2 = "skyblue",hov2_teleportation = "skyblue3",hov3 = "cadetblue1",hov3_teleportation = 'cadetblue3', ride_hail = "orchid",ride_hail_pooled = "plum1", ride_hail_transit = "violet",walk_transit = "coral1", drive_transit = "coral3", walk = "goldenrod2")
modesL1 <- c('Bike', 'Bike to Transit', 'Car', 'HOV2','HOV2 Passenger', 'HOV3', 'HOV3 Passenger', "Ride Hail", "Pooled Ride Hail", "Ride Hail to Transit", "Walk to Transit", 'Drive to Transit', "Walk")
modesL2 <- c('No Mode','Bike', 'Bike to Transit', 'Car', 'HOV2','HOV2 Passenger', 'HOV3', 'HOV3 Passenger', "Ride Hail", "Pooled Ride Hail", "Ride Hail to Transit", "Walk to Transit", 'Drive to Transit', "Walk")


pie_chart <- function(plans_sum){
  plans_sum <- plans_sum %>% filter(!is.na(legMode)) %>%
    mutate(ScenarioName = case_when(
      ScenarioName == "wRH-AllModes-AllVars" ~ "AsimBeamAll:PPL",
      ScenarioName == "wRH-AllModes-PathVars" ~ "AsimBeamAll:Path",
      ScenarioName == "noRH-AllModes-AllVars" ~ "BeamAll:PPL",
      ScenarioName == "noRH-AllModes-PathVars" ~ "BeamAll:Path"
    ))
  plans_sum$legMode <- factor(plans_sum$legMode, 
                                   levels=c("bike","car","hov2","hov2_teleportation","hov3","hov3_teleportation",
                                            "ride_hail","ride_hail_pooled","walk","walk_transit"))
  
  ggplot(plans_sum, aes(x=ScenarioName, y=share, group=legMode, fill=fct_inorder(legMode))) +
    geom_bar(position = "stack",stat = "identity") +
    geom_col(color = 1) +
    theme_bw() + 
    guides(fill = guide_legend(title = "Mode")) +
    theme(text = element_text(size = 8)) +
    scale_fill_manual(values = modesP, labels=modesL1) +
    xlab("Scenario Name") +
    ylab("Share") +
    theme(axis.text.x = element_text(angle=90, hjust=1))
}

make_plans_shift_chart <- function(plan_mode_shifts){
  plan_mode_shifts <-plan_mode_shifts %>%
    mutate(legMode = ifelse(legMode == "","nomode",legMode))
  plan_mode_shifts$legMode <- factor(plan_mode_shifts$legMode, 
                          levels=c("nomode","bike","bike_transit","car","hov2","hov2_teleportation","hov3","hov3_teleportation",
                                   "ride_hail","ride_hail_pooled","ride_hail_transit","walk","walk_transit","drive_transit"))
  
  
  ggplot(plan_mode_shifts, aes(x = factor(iteration-1), stratum = legMode, alluvium = id, fill = legMode, label = legMode)) +
    scale_fill_manual(values = modesP2, labels = modesL2) +
    geom_flow(color = "darkgray") +
    geom_stratum() +
    theme_bw() + 
    xlab("Iteration") +
    ylab("Number of Trips") +
    theme(legend.position="bottom")
}

switch_to_walk <- function(dayhours){
  dayhours$mode <- factor(dayhours$mode, 
                              levels=c("bike","bike_transit","car","hov2","hov2_teleportation","hov3","hov3_teleportation",
                                       "ride_hail","ride_hail_pooled","ride_hail_transit","walk","walk_transit","drive_transit"))
  
  ggplot(dayhours, aes(x = factor(hour),group = mode,fill = factor(mode), y = count)) +
    geom_bar(position = "stack", stat = "identity") +
    scale_fill_manual(values = modesP, labels=modesL1) +
    theme_bw() + 
    guides(fill = guide_legend(title = "Mode")) +
    xlab("Hour of Plan Day") +
    ylab("Number of Trips")
}
