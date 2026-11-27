# ------------------------------------------------------------------
# Instala os pacotes usados no projeto (rodar UMA vez antes do .Rmd)
# ------------------------------------------------------------------
pacotes <- c(
  "rmarkdown", "knitr",   # relatório
  "tidyverse",            # dplyr, ggplot2, tidyr, forcats...
  "abjData",              # dataset: Atlas do Desenvolvimento Humano (PNUD)
  "scales",               # formatação de eixos
  "ggridges",             # ridgeline plot
  "corrplot",             # matriz de correlação
  "ranger",               # random forest
  "xgboost",              # gradient boosting
  "FactoMineR",           # PCA, HCPC, FAMD
  "factoextra",           # gráficos da PCA (fviz_*)
  "ggrepel"               # rótulos sem sobreposição
)

# Garante uma biblioteca de usuário gravável
lib <- Sys.getenv("R_LIBS_USER")
dir.create(lib, recursive = TRUE, showWarnings = FALSE)
.libPaths(c(lib, .libPaths()))

faltando <- setdiff(pacotes, rownames(installed.packages()))
if (length(faltando) > 0) {
  install.packages(faltando, lib = lib, repos = "https://cloud.r-project.org")
}

message("Pacotes prontos: ", paste(pacotes, collapse = ", "))
