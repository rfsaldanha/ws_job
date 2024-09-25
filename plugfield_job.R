# Packages
library(plugfieldapi)
library(duckdb)
library(lubridate)
library(dplyr)
library(cli)

cli_inform("{now()}")

# Time stamp

## Initial time stamp, keep it commented!
# last_end_time <- "17/09/2024 00:00:00"
# saveRDS(object = last_end_time, file = "last_end_time.rds")

## Load end time from previous run as start time of this run
start_time <- readRDS(file = "last_end_time.rds")
end_time <- format(now(tzone = "Brazil/East"), "%d/%m/%Y %H:%M:%S")

# Database connection
con <- dbConnect(duckdb(), "weather_stations.duckdb")

# Sensor ids
device_ids <- c(4893)
sensor_ids <- c(8, 35, 36, 37, 11, 18, 19, 22, 27, 28, 34, 23, 25, 26, 1)

# Plugfield login 
cli_alert("Attempting to login...")
login()

# Empty data tibble
res <- tibble()

# For each device...
cli_alert("Starting to retrieve data...")
for(d in device_ids){
  # For each sensor...
  cli_inform("Device: {d}")
  for(s in sensor_ids){
    cli_inform("Sensor: {s}")
    # Retrive data from API
    tmp <- data_sensor(
      deviceId = d, sensor = s, 
      time = start_time, timeMax = end_time
    ) |>
      # Format data for database
      rename(value = value_formatted) |>
      mutate(
        device = d,
        sensor = s
      ) |>
      relocate(device, sensor) |>
      relocate(time, .before = value)

    cli_alert_success("Data from device {d}, sensor {s} retrieved successfully.")
    
    res <- bind_rows(res, tmp)
    rm(tmp)
  }

  # Write data to database
  cli_alert("Writing new data from device {d} to database...")

  dbWriteTable(
    conn = con, 
    name = "sensor_data", 
    value = res, 
    append = TRUE
  )

  cli_alert_success("Done!")

}

# Disconnect from database
dbDisconnect(con)

# Save last end time
saveRDS(object = end_time, file = "last_end_time.rds")

# Final messages
cli_alert_success("Update was successfull.")
cli_inform("{now()}")
