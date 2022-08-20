# target libraries
library(targets)
library(tarchetypes)


# Set target-specific options such as packages.
## To install RAM: devtools::install_url("https://cran.r-project.org/src/contrib/Archive/RAM/RAM_1.2.1.tar.gz")
tar_option_set(packages = c("tidyverse", "bookdown", "readr", "dotwhisker", 
                            "ggpubr", "scales", "future", "future.apply", "furrr",
                            "data.table"))

#Define custom functions and other global objects.
# This is where you write source(\"R/functions.R\")
# if you keep your functions in external scripts.
source("R/asim_path_validation.R")
source("R/table_maker.R")
source("R/data_helpers.R")
source("R/rh_events.R")


data_targets <- tar_plan(
  ## ASIM Utility Coefficient Validation
  tar_target(asim_hbw, get_asim_hbw()),
  tar_target(utah_hbw, get_utah_hbw()),
  tar_target(wfrc_hbw, get_wfrc_hbw()),
  tar_target(nchrp_hbw, get_nchrp_hbw()),
  tar_target(asim_hbs, get_asim_hbs()),
  tar_target(utah_hbs, get_utah_hbs()),
  tar_target(wfrc_hbs, get_wfrc_hbs()),
  tar_target(nchrp_hbs, get_nchrp_hbs()),
  tar_target(asim_hbo, get_asim_hbo()),
  tar_target(utah_hbo, get_utah_hbo()),
  tar_target(wfrc_hbo, get_wfrc_hbo()),
  tar_target(nchrp_hbo, get_nchrp_hbo()),
  
  ## Ride Hail Event Handler data
  tar_target(all_all_wrh, "data/events/12.events-15pct-wRH-all-all.csv", format = "file"),
  tar_target(all_path_wrh, "data/events/12.events-15pct-wRH-all-path.csv", format = "file"),
  tar_target(rh_all_wrh, "data/events/12.events-15pct-wRH-rh-all.csv", format = "file"),
  tar_target(rh_path_wrh, "data/events/12.events-15pct-wRH-rh-path.csv", format = "file"),
  tar_target(none_wrh, "data/events/12.events-15pct-wRH-none.csv", format = "file"),
  tar_target(all_all_norh, "data/events/12.events-15pct-noRH-all-all.csv", format = "file"),
  tar_target(all_path_norh, "data/events/12.events-15pct-noRH-all-path.csv", format = "file"),
  tar_target(rh_all_norh, "data/events/12.events-15pct-noRH-rh-all.csv", format = "file"),
  tar_target(rh_path_norh, "data/events/12.events-15pct-noRH-rh-path.csv", format = "file"),
  tar_target(none_norh, "data/events/12.events-15pct-noRH-none.csv", format = "file"),
  
  ## Scenario List
  scenario_list = list(
    "All Modes - All Variables - W/ RH" = all_all_wrh,
    "All Modes - Path Variables - W/ RH" = all_path_wrh,
    "RH Modes - All Variables - W/ RH" = rh_all_wrh,
    "RH Modes - Path Variables - W/ RH" = rh_path_wrh,
    "No Modes - W/ RH" = none_wrh,
    "All Modes - All Variables - No RH" = all_all_norh,
    "All Modes - Path Variables - No RH" = all_path_norh,
    "RH Modes - All Variables - No RH" = rh_all_norh,
    "RH Modes - Path Variables - No RH" = rh_path_norh,
    "No Modes - No RH" = none_norh
  ),
  
  ## Important Columns
  cols = c("person",
           "vehicle",
           "time",
           "type",
           "mode",
           "legMode",
           "vehicleType",
           "arrivalTime",
           "departureTime",
           "departTime",
           "length",
           "numPassengers",
           "actType",
           "personalVehicleAvailable"
  ),
  
  events_list = future_map(scenario_list, read_events, cols)
)

analysis_targets <- tar_plan(
  tar_target(hbw_graph, ivtt_ratio_grapher("Home-Based Work", asim_hbw, utah_hbw,wfrc_hbw,nchrp_hbw)),
  tar_target(hbs_graph, ivtt_ratio_grapher("Home-Based School",asim_hbs,utah_hbs,wfrc_hbs,nchrp_hbs)),
  tar_target(hbo_graph, ivtt_ratio_grapher("Home-Based Other",asim_hbo,utah_hbo,wfrc_hbo,nchrp_hbo)),
  
  tar_target(mode_choice_table, all_join(events_list, mode_choice, "mode", "mode")),
  tar_target(num_passengers, all_join(events_list, rh_pass, "numPassengers", "num_passengers")),
  tar_target(wait_times, all_join(events_list, rh_times, "summary", "values")),
  tar_target(travel_times, all_join(events_list, rh_travel_times, "summary", "values")),
  tar_target(rh_to_transit, all_join(events_list, count_rh_transit_transfers, "transferType", "transfer_type")),
  
  tar_target(ridership, format_ridership_table(mode_choice_table)),
  tar_target(transfers, format_transfers_table(rh_to_transit)),
  tar_target(waits, format_waits_graph(wait_times))
)

tar_plan(
  data_targets,
  analysis_targets
)

#tar_read(waits)