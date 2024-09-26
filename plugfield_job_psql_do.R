# Packages
library(plugfieldapi)
library(DBI)
library(RPostgres)
library(lubridate)
library(dplyr)
library(cli)
library(rlang)
library(blastula)
library(glue)
source("ws_job/emails.R")
schema <- "estacoes"

# Message and keep job start timestamp
cli_alert_info("Job start: {now()}")

# Time stamp

## Initial time stamp, keep it commented!
# last_end_time <- "17/09/2024 00:00:00"
# saveRDS(object = last_end_time, file = "plugfield_last_end_time.rds")

## Load end time from previous run as start time of this run
start_time <- readRDS(file = "plugfield_last_end_time.rds")
end_time <- format(now(tzone = "Brazil/East"), "%d/%m/%Y %H:%M:%S")

# Database connection
con <- tryCatch(
  {
    # dbConnect(duckdb(), "weatherlink.duckdb")
    dbConnect(
      RPostgres::Postgres(),
      dbname = "plugfield", 
      host = "dbaas-db-7323920-do-user-737434-0.l.db.ondigitalocean.com",
      port = 25060, # or any other port specified by your DBA
      user = Sys.getenv("weather_user"),
      password = Sys.getenv("weather_password")
    )
  }, 
  error=function(e) {
    cli_alert_warning("Could not connect to database.")
    message(e)
    send_email_database_error(e, "Conexão com o banco de dados local da Plugfield")
    cli_abort("This update was aborted.")
  }
)

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
  for(s in sensor_ids){
    cli_alert("Retrieving data from station {d}, sensor {s}...")
    tmp <- tryCatch(
      {
        data_sensor(
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
      }, 
      error=function(e) {
        cli_alert_warning("Could not retrieve data from station {d}, sensor {s}.")
        message(e)
        send_email_data_retrieve_error(e, glue("Estação {d}, sensor {s} da Plugfield"))
        cli_abort("This update was aborted.")
      }
    )
    cli_alert_success("Data from station {d}, sensor {s} retrieved successfully.")
    
    res <- bind_rows(res, tmp)
    rm(tmp)
  }

  # Write to database
  cli_alert("Writing new data from station {d} to database...")
  table_name <- paste0("station_",d)
  
  db_write <- tryCatch(
    {
      dbWriteTable(
        conn = con, 
        name = Id(schema, table_name), 
        value = res, 
        append = TRUE
      )
    }, 
    error=function(e) {
      cli_alert_warning("Could not write data from station {d}.")
      message(e)
      send_email_write_db_error(e, glue("Estação {d} da Plugfield"))
      cli_abort("This update was aborted.")
    }
  )

}

# Disconnect from database
dbDisconnect(con)

# Save last end time
saveRDS(object = end_time, file = "plugfield_last_end_time.rds")

# Final messages
cli_alert_info("End of update.")
cli_alert_info("Job end: {now()}")
