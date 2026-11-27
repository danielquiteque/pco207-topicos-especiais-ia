# ------------------------------------------------------------------
# Gera as bases processadas (limpas e agregadas) a partir dos CSVs brutos
# do ONS. Rode com o diretório de trabalho na RAIZ do projeto.
#
# Saídas em 3_dados/processados/:
#   - sin_diario.csv            médias diárias do SIN (GWmed) por fonte e carga
#   - subsistema_mensal.csv     médias mensais por subsistema (GWmed)
#   - sin_anual_fonte.csv       energia anual (TWh) e participação por fonte
# ------------------------------------------------------------------
library(tidyverse)

arquivos <- list.files("3_dados/brutos", pattern = "\\.csv$", full.names = TRUE)
bruto <- map_dfr(arquivos, ~ read_delim(.x, delim = ";", show_col_types = FALSE,
                                        col_types = cols(.default = col_character())))

subsis <- c(SE = "Sudeste/Centro-Oeste", S = "Sul", NE = "Nordeste", N = "Norte",
            SIN = "SIN (total nacional)")

horario <- bruto %>%
  transmute(
    subsistema  = subsis[id_subsistema],
    instante    = ymd_hms(din_instante),
    hidraulica  = replace_na(as.numeric(val_gerhidraulica), 0),
    termica     = replace_na(as.numeric(val_gertermica), 0),
    eolica      = replace_na(as.numeric(val_gereolica), 0),
    solar       = replace_na(as.numeric(val_gersolar), 0),
    carga       = as.numeric(val_carga),
    intercambio = as.numeric(val_intercambio)
  ) %>%
  mutate(carga = if_else(carga <= 0, NA_real_, carga))   # carga zero = erro de medição

# 1. Médias diárias do SIN, em GW
sin_diario <- horario %>%
  filter(subsistema == "SIN (total nacional)") %>%
  group_by(data = as_date(instante)) %>%
  summarise(across(c(hidraulica, termica, eolica, solar, carga),
                   ~ round(mean(.x, na.rm = TRUE) / 1000, 3))) %>%
  mutate(participacao_eolica_solar = round((eolica + solar) /
                                             (hidraulica + termica + eolica + solar), 4))

# 2. Médias mensais por subsistema, em GW
subsistema_mensal <- horario %>%
  filter(subsistema != "SIN (total nacional)") %>%
  group_by(subsistema, mes = floor_date(as_date(instante), "month")) %>%
  summarise(across(c(hidraulica, termica, eolica, solar, carga, intercambio),
                   ~ round(mean(.x, na.rm = TRUE) / 1000, 3)), .groups = "drop")

# 3. Energia anual do SIN por fonte, em TWh
sin_anual_fonte <- horario %>%
  filter(subsistema == "SIN (total nacional)") %>%
  pivot_longer(c(hidraulica, termica, eolica, solar), names_to = "fonte", values_to = "mw") %>%
  group_by(ano = year(instante), fonte) %>%
  summarise(twh = sum(mw) / 1e6, .groups = "drop") %>%
  group_by(ano) %>%
  mutate(participacao = round(twh / sum(twh), 4), twh = round(twh, 2)) %>%
  ungroup()

dir.create("3_dados/processados", showWarnings = FALSE, recursive = TRUE)
write_csv(sin_diario,        "3_dados/processados/sin_diario.csv")
write_csv(subsistema_mensal, "3_dados/processados/subsistema_mensal.csv")
write_csv(sin_anual_fonte,   "3_dados/processados/sin_anual_fonte.csv")
message("Bases processadas salvas em 3_dados/processados/")
