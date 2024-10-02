# Set locale
invisible(Sys.setlocale("LC_ALL", "pt_BR.utf8"))

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
  "renata.gracie@fiocruz.br",
  "christovam.barcellos@fiocruz.br",
  "izabio2005@gmail.com"
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
date_time <- format(now(), "%A, %e de %B de %Y, às %R (%Z)")
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
  annotate("rect", xmin=min(res_uv$time, na.rm = TRUE),xmax=max(res_uv$time, na.rm = TRUE),ymin=-Inf,ymax=3,alpha=0.3,fill="green") +
  annotate("rect", xmin=min(res_uv$time, na.rm = TRUE),xmax=max(res_uv$time, na.rm = TRUE),ymin=3,ymax=6,alpha=0.3,fill="yellow") +
  annotate("rect", xmin=min(res_uv$time, na.rm = TRUE),xmax=max(res_uv$time, na.rm = TRUE),ymin=6,ymax=8,alpha=0.3,fill="orange") +
  annotate("rect", xmin=min(res_uv$time, na.rm = TRUE),xmax=max(res_uv$time, na.rm = TRUE),ymin=8,ymax=11,alpha=0.3,fill="red") +
  annotate("rect", xmin=min(res_uv$time, na.rm = TRUE),xmax=max(res_uv$time, na.rm = TRUE),ymin=11,ymax=Inf,alpha=0.3,fill="purple") +
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

## Vento
res_vento <- tbl(con, schema) |>
  filter(sensor == 36) |>
  filter(time >= time_uct) |>
  collect() |>
  mutate(
    time = as_datetime(time, tz = "America/Sao_Paulo"),
    name = "Vento"
  )

res_rajada <- tbl(con, schema) |>
  filter(sensor == 37) |>
  filter(time >= time_uct) |>
  collect() |>
  mutate(
    time = as_datetime(time, tz = "America/Sao_Paulo"),
    name = "Rajada"
  )

max_vento <- res_vento |>
  filter(value == max(value, na.rm = TRUE)) |>
  slice_tail(n = 1)

max_rajada <- res_rajada |>
  filter(value == max(value, na.rm = TRUE)) |>
  slice_tail(n = 1)

plot_vento <- ggplot(data = bind_rows(res_vento, res_rajada), aes(x = time, y = value, color = name)) +
  geom_line() + 
  labs(title = "Vento e rajada", x = "Data", y = "km/h", color = NULL) +
  theme_bw() +
  theme(legend.position = "bottom", legend.direction = "horizontal") +
  scale_x_datetime(date_labels = "%b %d", date_breaks = "1 day")  

plot_vento <- add_ggplot(plot_vento, width = 7, height = 5)

## Wifi
res_wifi <- tbl(con, schema) |>
  filter(sensor == 25) |>
  filter(time >= time_uct) |>
  collect() |>
  mutate(time = as_datetime(time, tz = "America/Sao_Paulo"))

plot_wifi <- ggplot(data = res_wifi, aes(x = time, y = value)) +
  geom_line() + 
  labs(title = "Sinal Wi-Fi da estação", x = "Data", y = "%") +
  geom_smooth() +
  theme_bw() +
  scale_x_datetime(date_labels = "%b %d", date_breaks = "1 day")

plot_wifi <- add_ggplot(plot_wifi, width = 7, height = 5)

## Bateria
res_bat <- tbl(con, schema) |>
  filter(sensor == 1) |>
  filter(time >= time_uct) |>
  collect() |>
  mutate(time = as_datetime(time, tz = "America/Sao_Paulo"))

plot_bat <- ggplot(data = res_bat, aes(x = time, y = value)) +
  geom_line() + 
  labs(title = "Bateria da estação", x = "Data", y = "%") +
  theme_bw() +
  scale_x_datetime(date_labels = "%b %d", date_breaks = "1 day")

plot_bat <- add_ggplot(plot_bat, width = 7, height = 5)

# Database disconnect
dbDisconnect(con)

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
      Máxima: {max_press$value}hPa ({max_press$time})\n
      Mínima: {min_press$value}hPa ({min_press$time})

      {plot_vento}
      Vento máximo: {max_vento$value}Km/h ({max_vento$time})\n
      Rajada máxima: {max_rajada$value}Km/h ({max_rajada$time})

      {plot_uv}
      Máxima: {max_uv$value}uv ({max_uv$time})\n

      {plot_nrio}
      Máxima: {max_nrio$value}mca ({max_nrio$time})\n
      Mínima: {min_nrio$value}mca ({min_nrio$time})

      {plot_chuva}
      Máxima: {max_chuva$value}mm ({max_chuva$time})

      {plot_wifi}

      {plot_bat}
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
