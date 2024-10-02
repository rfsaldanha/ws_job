# Packages
library(DBI)
library(RPostgres)
library(dbplyr)
library(lubridate)
library(dplyr)
library(ggplot2)
library(blastula)
schema_plugfield <- dbplyr::in_schema("estacoes", "station_4893")
schema_weatherlink_sensor_772002 <- dbplyr::in_schema("estacoes", "station_195669_sensor_772002")
schema_weatherlink_sensor_772003 <- dbplyr::in_schema("estacoes", "station_195669_sensor_772003")
schema_weatherlink_sensor_772004 <- dbplyr::in_schema("estacoes", "station_195669_sensor_772004")
schema_weatherlink_sensor_772005 <- dbplyr::in_schema("estacoes", "station_195669_sensor_772005")

# Email config
img_string <- add_image(file = "ws_job/selo_obs_h.png", 250)
recipients <- c(
  "raphael.saldanha@fiocruz.br",
  "diego.ricardo@fiocruz.br",
  "vanderlei.pascoal@fiocruz.br",
  "heglaucio.barros@fiocruz.br",
  "renata.gracie@fiocruz.br",
  "christovam.barcellos@fiocruz.br",
  "izabio2005@gmail.com"
)

# Database connection
con_weatherlink <- dbConnect(
  RPostgres::Postgres(),
  dbname = "weatherlink", 
  host = "dbaas-db-7323920-do-user-737434-0.l.db.ondigitalocean.com",
  port = 25060,
  user = Sys.getenv("weather_user"),
  password = Sys.getenv("weather_password")
)

con_plugfield <- dbConnect(
  RPostgres::Postgres(),
  dbname = "plugfield", 
  host = "dbaas-db-7323920-do-user-737434-0.l.db.ondigitalocean.com",
  port = 25060,
  user = Sys.getenv("weather_user"),
  password = Sys.getenv("weather_password")
)

# Lista tabelas
# dbListObjects(con, Id(schema = 'estacoes'))


# Horário referência
date_time <- add_readable_time()
time_local <- now() - days(7)
time_uct <- as_datetime(time_local, tz = "UTC")

# Dados e gráficos

## Temperatura
res_temp_weatherlink <- tbl(con_weatherlink, schema_weatherlink_sensor_772005) |>
  select(time = ts, value = temp) |>
  filter(time >= time_uct) |>
  collect() |>
  mutate(
    time = as_datetime(time, tz = "America/Sao_Paulo"),
    value = (value - 32)/1.8,
    name = "Cametá"
  )

res_temp_plugfield <- tbl(con_plugfield, schema_plugfield) |>
  filter(sensor == 8) |>
  filter(time >= time_uct) |>
  select(time, value) |>
  collect() |>
  mutate(
    time = as_datetime(time, tz = "America/Sao_Paulo"),
    name = "Merajuba/Mocajuba"
  )

plot_temp <- ggplot(data = bind_rows(res_temp_weatherlink, res_temp_plugfield), aes(x = time, y = value, color = name)) +
  geom_line(alpha = .7) + 
  labs(title = "Temperatura", x = "Data", y = "ºC", color = NULL) +
  theme_bw() +
  scale_x_datetime(date_labels = "%b %d", date_breaks = "1 day") +
  theme(legend.position = "bottom", legend.direction = "horizontal")

plot_temp <- add_ggplot(plot_temp, width = 7, height = 5)

## Umidade
res_umid_weatherlink <- tbl(con_weatherlink, schema_weatherlink_sensor_772005) |>
  select(time = ts, value = hum) |>
  filter(time >= time_uct) |>
  collect() |>
  mutate(
    time = as_datetime(time, tz = "America/Sao_Paulo"),
    name = "Cametá"
  )

res_umid_plugfield <- tbl(con_plugfield, schema_plugfield) |>
  filter(sensor == 11) |>
  filter(time >= time_uct) |>
  select(time, value) |>
  collect() |>
  mutate(
    time = as_datetime(time, tz = "America/Sao_Paulo"),
    name = "Merajuba/Mocajuba"
  )



plot_umid <- ggplot(data = bind_rows(res_umid_weatherlink, res_umid_plugfield), aes(x = time, y = value, color = name)) +
  geom_line(alpha = .7) + 
  labs(title = "Umidade", x = "Data", y = "%", color = NULL) +
  theme_bw() +
  scale_x_datetime(date_labels = "%b %d", date_breaks = "1 day") +
  theme(legend.position = "bottom", legend.direction = "horizontal")

plot_umid <- add_ggplot(plot_umid, width = 7, height = 5)

## Pressão
res_press_weatherlink <- tbl(con_weatherlink, schema_weatherlink_sensor_772003) |>
  select(time = ts, value = bar_sea_level) |>
  filter(time >= time_uct) |>
  collect() |>
  mutate(
    time = as_datetime(time, tz = "America/Sao_Paulo"),
    value = value*33.864,
    name = "Cametá"
  )

res_press_plugfield <- tbl(con_plugfield, schema_plugfield) |>
  filter(sensor == 23) |>
  filter(time >= time_uct) |>
  select(time, value) |>
  collect() |>
  mutate(
    time = as_datetime(time, tz = "America/Sao_Paulo"),
    name = "Merajuba/Mocajuba"
  )

plot_press <- ggplot(data = bind_rows(res_press_weatherlink, res_press_plugfield), aes(x = time, y = value, color = name)) +
  geom_line(alpha = .7) + 
  labs(title = "Pressão", x = "Data", y = "hPa", color = NULL) +
  theme_bw() +
  scale_x_datetime(date_labels = "%b %d", date_breaks = "1 day") +
  theme(legend.position = "bottom", legend.direction = "horizontal")

plot_press <- add_ggplot(plot_press, width = 7, height = 5)

## Chuva
res_chuva_weatherlink <- tbl(con_weatherlink, schema_weatherlink_sensor_772005) |>
  select(time = ts, value = rain_rate_last_mm) |>
  filter(time >= time_uct) |>
  collect() |>
  mutate(
    time = as_datetime(time, tz = "America/Sao_Paulo"),
    name = "Cametá"
  )

res_chuva_plugfield <- tbl(con_plugfield, schema_plugfield) |>
  filter(sensor == 35) |>
  filter(time >= time_uct) |>
  select(time, value) |>
  collect() |>
  mutate(
    time = as_datetime(time, tz = "America/Sao_Paulo"),
    name = "Merajuba/Mocajuba"
  )

plot_chuva <- ggplot(data = bind_rows(res_chuva_weatherlink, res_chuva_plugfield), aes(x = time, y = value, color = name)) +
  geom_line(alpha = .7) + 
  labs(title = "Chuva", x = "Data", y = "mm", color = NULL) +
  theme_bw() +
  scale_x_datetime(date_labels = "%b %d", date_breaks = "1 day") +
  theme(legend.position = "bottom", legend.direction = "horizontal")

plot_chuva <- add_ggplot(plot_chuva, width = 7, height = 5)

## Vento
res_vento_weatherlink <- tbl(con_weatherlink, schema_weatherlink_sensor_772005) |>
  select(time = ts, value = wind_speed_last) |>
  filter(time >= time_uct) |>
  collect() |>
  mutate(
    time = as_datetime(time, tz = "America/Sao_Paulo"),
    value = value * 1.609344,
    name = "Cametá"
  )

res_vento_plugfield <- tbl(con_plugfield, schema_plugfield) |>
  filter(sensor == 36) |>
  filter(time >= time_uct) |>
  select(time, value) |>
  collect() |>
  mutate(
    time = as_datetime(time, tz = "America/Sao_Paulo"),
    name = "Merajuba/Mocajuba"
  )

plot_vento <- ggplot(data = bind_rows(res_vento_weatherlink, res_vento_plugfield), aes(x = time, y = value, color = name)) +
  geom_line(alpha = .7) + 
  labs(title = "Vento", x = "Data", y = "mm", color = NULL) +
  theme_bw() +
  scale_x_datetime(date_labels = "%b %d", date_breaks = "1 day") +
    theme(legend.position = "bottom", legend.direction = "horizontal")

plot_vento <- add_ggplot(plot_vento, width = 7, height = 5)

# Database disconnect
dbDisconnect(con_weatherlink)
dbDisconnect(con_plugfield)

# E-mail
email <- compose_email(
  body = md(glue::glue(
      "{img_string}
      Relatório comparativo dos últimos sete dias das estações meteorológicas de Cametá e Merajuba/Mocajuba
      
      {plot_temp}

      {plot_umid}

      {plot_press}

      {plot_vento}

      {plot_chuva}
      ")),
  footer = md(glue::glue("{date_time}."))
)

# Send email
smtp_send(
  email = email,
  to = recipients,
  from = "raphael.saldanha@fiocruz.br",
  subject = "Relatório comparativo dos últimos sete dias das estações meteorológicas de Cametá e Merajuba/Mocajuba",
  credentials = creds_file("ws_job/smtp2go_creds"),
  verbose = FALSE
)
