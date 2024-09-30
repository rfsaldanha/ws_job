# Packages
library(DBI)
library(RPostgres)
library(dbplyr)
library(lubridate)
library(dplyr)
library(ggplot2)
library(blastula)
schema <- dbplyr::in_schema("estacoes", "tb_estacao_1b")

# Email config
img_string <- add_image(file = "ws_job/selo_obs_h.png", 250)
recipients <- c(
  "raphael.saldanha@fiocruz.br",
  "diego.ricardo@fiocruz.br",
  "vanderlei.pascoal@fiocruz.br",
  "heglaucio.barros@fiocruz.br",
  "christovam.barcellos@fiocruz.br"
)

# Plugfield
con <- dbConnect(
  RPostgres::Postgres(),
  dbname = "observatorio", 
  host = "psql.icict.fiocruz.br",
  port = 5432,
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
res_temp <- tbl(con, schema) |>
  filter(sensor == 8) |>
  filter(time >= time_uct) |>
  collect() |>
  mutate(time = as_datetime(time, tz = "America/Sao_Paulo"))

max_temp <- res_temp |>
  filter(value == max(value, na.rm = TRUE)) |>
  slice_tail(n = 1)

min_temp <- res_temp |>
  filter(value == min(value, na.rm = TRUE)) |>
  slice_tail(n = 1)

plot_temp <- ggplot(data = res_temp, aes(x = time, y = value)) +
  geom_line() + 
  labs(title = "Temperatura", x = "Data", y = "ºC") +
  theme_bw() +
  scale_x_datetime(date_labels = "%b %d", date_breaks = "1 day")

plot_temp <- add_ggplot(plot_temp, width = 7, height = 5)

## Umidade
res_umid <- tbl(con, schema) |>
  filter(sensor == 11) |>
  filter(time >= time_uct) |>
  collect() |>
  mutate(time = as_datetime(time, tz = "America/Sao_Paulo"))

max_umid <- res_umid |>
  filter(value == max(value, na.rm = TRUE)) |>
  slice_tail(n = 1)

min_umid <- res_umid |>
  filter(value == min(value, na.rm = TRUE)) |>
  slice_tail(n = 1)

plot_umid <- ggplot(data = res_umid, aes(x = time, y = value)) +
  geom_line() + 
  labs(title = "Umidade", x = "Data", y = "%") +
  theme_bw() +
  scale_x_datetime(date_labels = "%b %d", date_breaks = "1 day")

plot_umid <- add_ggplot(plot_umid, width = 7, height = 5)

## Pressão
res_press <- tbl(con, schema) |>
  filter(sensor == 23) |>
  filter(time >= time_uct) |>
  collect() |>
  mutate(time = as_datetime(time, tz = "America/Sao_Paulo"))

max_press <- res_press |>
  filter(value == max(value, na.rm = TRUE)) |>
  slice_tail(n = 1)

min_press <- res_press |>
  filter(value == min(value, na.rm = TRUE)) |>
  slice_tail(n = 1)

plot_press <- ggplot(data = res_press, aes(x = time, y = value)) +
  geom_line() + 
  labs(title = "Pressão", x = "Data", y = "hPa") +
  theme_bw() +
  scale_x_datetime(date_labels = "%b %d", date_breaks = "1 day")

plot_press <- add_ggplot(plot_press, width = 7, height = 5)

## UV
res_uv <- tbl(con, schema) |>
  filter(sensor == 19) |>
  filter(time >= time_uct) |>
  collect() |>
  mutate(time = as_datetime(time, tz = "America/Sao_Paulo"))

max_uv <- res_uv |>
  filter(value == max(value, na.rm = TRUE)) |>
  slice_tail(n = 1)

plot_uv <- ggplot(data = res_uv, aes(x = time, y = value)) +
  geom_line() + 
  labs(title = "UV", x = "Data", y = "uv") +
  theme_bw() +
  scale_x_datetime(date_labels = "%b %d", date_breaks = "1 day")

plot_uv <- add_ggplot(plot_uv, width = 7, height = 5)



## Nível do rio
res_nrio <- tbl(con, schema) |>
  filter(sensor == 34) |>
  filter(time >= time_uct) |>
  collect() |>
  mutate(time = as_datetime(time, tz = "America/Sao_Paulo"))

max_nrio <- res_nrio |>
  filter(value == max(value, na.rm = TRUE)) |>
  slice_tail(n = 1)

min_nrio <- res_nrio |>
  filter(value == min(value, na.rm = TRUE)) |>
  slice_tail(n = 1)

plot_nrio <- ggplot(data = res_nrio, aes(x = time, y = value)) +
  geom_line() + 
  labs(title = "Nível do rio", x = "Data", y = "mca") +
  theme_bw() +
  scale_x_datetime(date_labels = "%b %d", date_breaks = "1 day")

plot_nrio <- add_ggplot(plot_nrio, width = 7, height = 5)

## Chuva
res_chuva <- tbl(con, schema) |>
  filter(sensor == 35) |>
  filter(time >= time_uct) |>
  collect() |>
  mutate(time = as_datetime(time, tz = "America/Sao_Paulo"))

max_chuva <- res_chuva |>
  filter(value == max(value, na.rm = TRUE)) |>
  slice_tail(n = 1)

plot_chuva <- ggplot(data = res_chuva, aes(x = time, y = value)) +
  geom_line() + 
  labs(title = "Chuva", x = "Data", y = "mm") +
  theme_bw() +
  scale_x_datetime(date_labels = "%b %d", date_breaks = "1 day")  

plot_chuva <- add_ggplot(plot_chuva, width = 7, height = 5)

# E-mail
email <- compose_email(
  body = md(glue::glue(
      "{img_string}
      Relatório dos últimos sete dias da estação meteorológica Merajuba - Mojacuba (Plugfield 1327)
      
      {plot_temp}
      Máxima: {max_temp$value}ºC ({max_temp$time})\n
      Mínima: {min_temp$value}ºC ({min_temp$time})

      {plot_umid}
      Máxima: {max_umid$value}% ({max_umid$time})\n
      Mínima: {min_umid$value}% ({min_umid$time})

      {plot_press}
      Máxima: {max_press$value}% ({max_press$time})\n
      Mínima: {min_press$value}% ({min_press$time})

      {plot_uv}
      Máxima: {max_uv$value}uv ({max_uv$time})\n

      {plot_nrio}
      Máxima: {max_nrio$value}mca ({max_nrio$time})\n
      Mínima: {min_nrio$value}mca ({min_nrio$time})

      {plot_chuva}
      Máxima: {max_chuva$value}mm ({max_chuva$time})\n
      ")),
  footer = md(glue::glue("{date_time}."))
)

# Send email
smtp_send(
  email = email,
  to = recipients,
  from = "raphael.saldanha@fiocruz.br",
  subject = "Relatório dos últimos sete dias da estação meteorológica Merajuba - Mojacuba",
  credentials = creds_file("ws_job/smtp2go_creds"),
  verbose = FALSE
)
