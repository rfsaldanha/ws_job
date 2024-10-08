require(blastula)

img_string <- add_image(file = "ws_job/selo_obs_h.png", 250)

recipients_db <- c(
  "raphael.saldanha@fiocruz.br",
  "diego.ricardo@fiocruz.br",
  "heglaucio.barros@fiocruz.br",
  "lucas.carraro@fiocruz.br"
)

recipients_device <- c(
  "raphael.saldanha@fiocruz.br",
  "diego.ricardo@fiocruz.br"
)

send_email <- function(email, recipients, subject){
  smtp_send(
    email = email,
    to = recipients,
    from = "raphael.saldanha@fiocruz.br",
    subject = subject,
    credentials = creds_file("ws_job/smtp2go_creds"),
    verbose = FALSE
  )
}

send_email_database_error <- function(e, context){
  date_time <- add_readable_time()

  email <- compose_email(
    body = md(glue::glue(
        "{img_string}
        Olá,

        Ocorreu um erro na conexão com o banco de dados.

        Contexto: {context}

        -----

        {e}

        -----

        
        ")),
    footer = md(glue::glue("{date_time}."))
  )

  send_email(email, recipients_db, "Erro na conexão com o banco de dados")
}


send_email_data_retrieve_error <- function(e, context){
  date_time <- add_readable_time()

  email <- compose_email(
    body = md(glue::glue(
        "{img_string}
        Olá,

        Não foi possível buscar os dados da estação.

        Contexto: {context}

        -----
          
        {e}

        -----

        
        ")),
    footer = md(glue::glue("{date_time}."))
  )

  send_email(email, recipients_device, "Erro no acesso de dados da estação")
}

send_email_write_db_error <- function(e, context){
  date_time <- add_readable_time()

  email <- compose_email(
    body = md(glue::glue(
        "{img_string}
        Olá,

        Não foi possível escrever os dados do sensor no banco de dados.

        Contexto: {context}

        -----
          
        {e}

        -----

        
        ")),
    footer = md(glue::glue("{date_time}."))
  )

  send_email(email, recipients_db, "Erro ao escrever os dados da estação no banco de dados")
}


send_email_device_offline <- function(d, since){
  date_time <- add_readable_time()

  email <- compose_email(
    body = md(glue::glue(
        "{img_string}
        Olá,

        A estação {d} está sem comunicação deste {since} (UTC).
        ")),
    footer = md(glue::glue("{date_time}."))
  )

  send_email(email, recipients_device, "Estação sem comunicação")
}