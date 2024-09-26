# Packages
library(weatherlinkapi)
library(DBI)
library(RPostgres)
library(lubridate)
library(dplyr)
library(cli)
library(rlang)
library(blastula)
library(glue)
library(here)
source("ws_job/emails.R")
schema <- "estacoes"

# sudo apt install tzdata-legacy

# Message and keep job start timestamp
cli_alert_info("Job start: {now()}")
now_ts <- format(now(tzone = "Brazil/East"), "%d/%m/%Y %H:%M:%S")

# Database connection
con <- tryCatch(
  {
    # dbConnect(duckdb(), "weatherlink.duckdb")
    dbConnect(
      RPostgres::Postgres(),
      dbname = "weatherlink", 
      host = "dbaas-db-7323920-do-user-737434-0.l.db.ondigitalocean.com",
      port = 25060, # or any other port specified by your DBA
      user = Sys.getenv("weather_user"),
      password = Sys.getenv("weather_password")
    )
  }, 
  error=function(e) {
    cli_alert_warning("Could not connect to database.")
    message(e)
    send_email_database_error(e, "Conexão com o banco de dados local da WeatherLink")
    cli_abort("This update was aborted.")
  }
)

# Station ids
station_ids <- c(195669)

# For each station...
for(d in station_ids){
  # Retrieve data from station
  cli_alert("Retrieving data from station {d}...")
  res <- tryCatch(
    {
      current_data(d)
    }, 
    error=function(e) {
      cli_alert_warning("Could not retrieve data from station {d}.")
      message(e)
      send_email_data_retrieve_error(e, glue("Estação {d} da WeatherLink"))
      cli_abort("This update was aborted.")
    }
  )
  cli_alert_success("Data from station {d} retrieved successfully.")
  
  # Write to database
  for(s in 1:length(res)){
    table_name <- paste0(schema,".","station_",d,"_sensor_",res[[s]]$lsid)

    # Check if data was already written
    last_update_file_name <- paste0("weatherlink_last_update_",table_name,".rds")
    update_database <- NA
    
    if(!file.exists(last_update_file_name)){
      update_database <- TRUE
    } else {
      last_update_data <- readRDS(last_update_file_name)

      if(hash(last_update_data) == hash(res[[s]])){
        update_database <- FALSE
      } else {
        update_database <- TRUE
      }
    }

    if(!update_database){
      cli_alert_danger("The current data from from station {d}, sensor {s} is the same of the last update. This sensor update will be skipped.")
      next
    } else {
      # Write to database
      cli_alert("Writing new data from device {d}, sensor {res[[s]]$lsid} to database...")
      db_write <- tryCatch(
        {
          dbWriteTable(
            conn = con, 
            name = table_name, 
            value = res[[s]], 
            append = TRUE
          )
        }, 
        error=function(e) {
          cli_alert_warning("Could not write data from station {d}, sensor {s} to database.")
          message(e)
          send_email_write_db_error(e, glue("Estação {d}, sensor {s} da WeatherLink"))
          cli_abort("This update was aborted.")
        }
      )

      # Save rds file
      saveRDS(
        object = res[[s]],
        file = paste0("weatherlink_last_update_",table_name,".rds")
      )
        
      cli_alert_success("Done.")
    }
  }
}

# Disconnect from database
dbDisconnect(con)

# Save last end time
saveRDS(object = now_ts, file = "last_update_time.rds")

# Final messages
cli_alert_info("End of update.")
cli_alert_info("Job end: {now()}")
