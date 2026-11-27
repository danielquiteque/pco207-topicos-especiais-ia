# ------------------------------------------------------------------
# Baixa os dados brutos do ONS (Operador Nacional do Sistema Elétrico)
# Conjunto: "Balanço de Energia nos Subsistemas" — base horária
# Portal: https://dados.ons.org.br/dataset/balanco-energia-subsistema
# Licença: Creative Commons Atribuição (CC-BY)
#
# Rode com o diretório de trabalho na RAIZ do projeto
# (abra Projeto_Transicao_Energetica.Rproj no RStudio).
# Os arquivos já vêm na pasta 3_dados/brutos: só baixa o que faltar.
# ------------------------------------------------------------------
anos    <- 2016:2025
destino <- file.path("3_dados", "brutos")
dir.create(destino, recursive = TRUE, showWarnings = FALSE)

base_url <- paste0("https://ons-aws-prod-opendata.s3.amazonaws.com/dataset/",
                   "balanco_energia_subsistema_ho/BALANCO_ENERGIA_SUBSISTEMA_")

for (ano in anos) {
  arquivo <- file.path(destino, paste0("BALANCO_ENERGIA_SUBSISTEMA_", ano, ".csv"))
  if (!file.exists(arquivo)) {
    message("Baixando ", ano, "...")
    download.file(paste0(base_url, ano, ".csv"), arquivo, mode = "wb", quiet = TRUE)
  }
}
message("Arquivos em ", normalizePath(destino))
