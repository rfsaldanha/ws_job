# Packages
library(plugfieldapi)
library(DBI)
library(RPostgres)
library(lubridate)
library(dplyr)
library(cli)
library(rlang)
library(glue)
library(ntfy)
schema <- "estacoes"

ntfy_topic <- "ocs_update_plugfield_mocajuba"

# Message and keep job start timestamp
cli_alert_info("Job start: {now()}")

# Time stamp

## Initial time stamp, keep it commented!
# last_end_time <- "13/01/2026 00:00:00"
# saveRDS(object = last_end_time, file = "plugfield_last_end_time.rds")

## Load end time from previous run as start time of this run
start_time <- readRDS(file = "plugfield_last_end_time.rds")
end_time <- format(now(tzone = "UTC"), "%d/%m/%Y %H:%M:%S")

# Database connection
con <- tryCatch(
  {
    dbConnect(
      RPostgres::Postgres(),
      dbname = "observatorio",
      host = "psql.icict.fiocruz.br",
      port = 5432,
      user = Sys.getenv("weather_user"),
      password = Sys.getenv("weather_password")
    )
  },
  error = function(e) {
    cli_alert_warning("Could not connect to database.")
    message(e)
    ntfy_send(
      message = glue("Could not connect to local database. {e}"),
      tags = tags$rotating_light,
      topic = ntfy_topic
    )
    cli_abort("This update was aborted.")
  }
)

# Sensor ids
# 4893 Cametá
# 10611 Maré meteo
# 10603 Maré ar
device_ids <- c(4893, 10611, 10603)

# Plugfield login
cli_alert("Attempting to login...")
login()

# For each device...
cli_alert("Starting to retrieve data...")
for (d in device_ids) {
  ## Check if device is updated
  last_device_update <- device_last_update(d)
  current_time <- as_datetime(end_time, format = "%d/%m/%Y %H:%M:%S")
  diff_time <- difftime(current_time, last_device_update, units = "mins")

  if (diff_time >= 15) {
    cli_alert_danger(
      "Last update from station {d} was at {last_device_update}."
    )
    ntfy_send(
      message = glue("Device offline."),
      tags = tags$rotating_light,
      topic = ntfy_topic
    )
    cli_abort("This update was aborted.")
  }

  # Empty data tibble
  res <- tibble()

  # For each sensor...
  if (d == 4893) {
    sensor_ids <- c(8, 35, 36, 37, 11, 18, 19, 22, 27, 28, 34, 23, 25, 26, 1)
  } else if (d == 10611) {
    sensor_ids <- c(
      8,
      35,
      348,
      347,
      11,
      18,
      19,
      22,
      27,
      28,
      23,
      25,
      1
    )
  } else if (d == 10603) {
    sensor_ids <- c(23, 73, 74, 72, 71, 75, 70)
  }

  for (s in sensor_ids) {
    cli_alert("Retrieving data from station {d}, sensor {s}...")
    tmp <- tryCatch(
      {
        data_sensor(
          deviceId = d,
          sensor = s,
          time = start_time,
          timeMax = end_time
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
      error = function(e) {
        cli_alert_warning(
          "Could not retrieve data from station {d}, sensor {s}."
        )
        message(e)
        ntfy_send(
          message = glue(
            "Could not retrieve data from station {d}, sensor {s}."
          ),
          tags = tags$rotating_light,
          topic = ntfy_topic
        )
        cli_abort("This update was aborted.")
      }
    )
    cli_alert_success(
      "Data from station {d}, sensor {s} retrieved successfully."
    )

    res <- bind_rows(res, tmp)
    rm(tmp)
  }

  # Write to database
  cli_alert("Writing new data from station {d} to database...")
  if (d == 4893) {
    table_name <- paste0("tb_estacao_1b")
  } else if (d == 10611) {
    table_name <- paste0("tb_estacao_3")
  }

  db_write <- tryCatch(
    {
      dbWriteTable(
        conn = con,
        name = Id(schema, table_name),
        value = res,
        append = TRUE
      )
    },
    error = function(e) {
      cli_alert_warning("Could not write data from station {d}.")
      message(e)
      ntfy_send(
        message = glue(
          "Could not write data from station {d}."
        ),
        tags = tags$rotating_light,
        topic = ntfy_topic
      )
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
