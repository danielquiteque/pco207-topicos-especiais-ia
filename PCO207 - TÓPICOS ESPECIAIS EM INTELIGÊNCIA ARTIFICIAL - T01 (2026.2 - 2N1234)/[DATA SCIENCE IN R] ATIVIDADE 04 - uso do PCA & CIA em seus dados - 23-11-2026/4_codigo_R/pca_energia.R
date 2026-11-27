# =============================================================================
# PCA, HCPC E FAMD DO SISTEMA ELÉTRICO BRASILEIRO (2016–2025)
# PCO207 – Introdução ao Data Science em R · Prof. Carlos Silveira (Unifei)
# Autor: Daniel Quiteque
# =============================================================================
#
# Pergunta: quais são os grandes "eixos" que explicam como o Sistema Interligado
# Nacional (SIN) variou mês a mês entre 2016 e 2025?
#
# Indivíduos : 120 meses (jan/2016 a dez/2025)
# Variáveis  : geração média mensal (GW) de cada fonte em cada subsistema
#              (hidráulica, térmica, eólica, solar) + carga de cada subsistema
# Fonte      : ONS – Balanço de Energia nos Subsistemas (dados abertos)
#
# Rode com o diretório de trabalho na RAIZ do projeto
# (abra Projeto_Transicao_Energetica.Rproj). Requer 3_dados/processados/
# subsistema_mensal.csv, gerado por 4_codigo_R/gerar_dados_processados.R.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# 1. PACOTES
# -----------------------------------------------------------------------------
library(tidyverse)   # manipulação (dplyr, tidyr) e gráficos (ggplot2)
library(FactoMineR)  # PCA(), HCPC(), FAMD()
library(factoextra)  # fviz_eig(), fviz_pca_*(), fviz_cluster(), fviz_famd_*()
library(corrplot)    # matriz variáveis × componentes
library(ggrepel)     # rótulos sem sobreposição

dir.create("figuras/pca", showWarnings = FALSE, recursive = TRUE)
salvar <- function(grafico, nome, w = 9, h = 5.5) {
  ggsave(file.path("figuras/pca", paste0(nome, ".png")), grafico,
         width = w, height = h, dpi = 300, bg = "white")
}
tema <- theme_minimal(base_size = 13) +
  theme(plot.title = element_text(face = "bold"), panel.grid.minor = element_blank())

# -----------------------------------------------------------------------------
# 2. DADOS: UMA LINHA POR MÊS, UMA COLUNA POR FONTE × SUBSISTEMA
# -----------------------------------------------------------------------------
mensal <- read_csv("3_dados/processados/subsistema_mensal.csv", show_col_types = FALSE)

sigla <- c("Sudeste/Centro-Oeste" = "SE", "Sul" = "S", "Nordeste" = "NE", "Norte" = "N")

largo <- mensal |>
  mutate(reg = sigla[subsistema]) |>
  select(mes, reg, Hid = hidraulica, Ter = termica, Eol = eolica, Sol = solar,
         Carga = carga) |>
  pivot_longer(Hid:Carga, names_to = "fonte", values_to = "gw") |>
  mutate(variavel = paste0(fonte, ".", reg)) |>
  select(mes, variavel, gw) |>
  pivot_wider(names_from = variavel, values_from = gw)

# Variáveis que (quase) não variam não carregam informação: a eólica do
# Sudeste fica sempre perto de zero. Ficam as que têm desvio padrão > 0,05 GW.
X <- largo |>
  select(-mes) |>
  select(where(~ sd(.x) > 0.05))

# Informações dos meses que NÃO entram no cálculo (só colorem os gráficos)
info <- largo |>
  transmute(mes,
            ano     = year(mes),
            estacao = if_else(month(mes) %in% c(11, 12, 1:4), "Úmida (nov–abr)", "Seca (mai–out)"),
            periodo = cut(ano, c(2015, 2019, 2022, 2025),
                          labels = c("2016–2019", "2020–2022", "2023–2025")))

dim(X)   # 120 meses × 19 variáveis

# -----------------------------------------------------------------------------
# 3. PCA
# -----------------------------------------------------------------------------
# scale.unit = TRUE: padroniza as variáveis (média 0, variância 1), porque
# a carga do Sudeste (~45 GW) teria peso muito maior que a solar do Sul (~1 GW).
pca <- PCA(X, scale.unit = TRUE, ncp = ncol(X), graph = FALSE)

round(pca$eig[1:6, ], 1)   # autovalores e variância explicada

# -----------------------------------------------------------------------------
# 3.0 A ÁLGEBRA POR TRÁS DA PCA (verificação "na mão", só com o R base)
# -----------------------------------------------------------------------------
# (1) Estatística: padronização z = (x − média) / desvio padrão
Z <- scale(X)                                     # 120 × 19
# (2) Matriz de correlação R = Zᵀ Z / (n − 1)        (19 × 19)
R <- crossprod(Z) / (nrow(Z) - 1)
all.equal(R, cor(X), check.attributes = FALSE)    # TRUE
# (3) Álgebra linear: autovalores e autovetores de R  (R v = λ v)
e <- eigen(R)
round(e$values[1:4], 2)                           # 8.49 4.30 1.73 1.35 = pca$eig
sum(e$values)                                     # 19 = número de variáveis
round(100 * e$values / sum(e$values), 1)[1:3]     # 44.7 22.6 9.1 (% da variância)
sum(e$vectors[, 1]^2)                             # 1: autovetor unitário
sum(e$vectors[, 1] * e$vectors[, 2])              # 0: autovetores ortogonais
# (4) Escores = projeção dos meses nos autovetores (Z v)
escores_mao <- Z %*% e$vectors[, 1:2]
abs(cor(escores_mao[, 1], pca$ind$coord[, 1]))    # 1: igual ao FactoMineR (sinal é arbitrário)
var(escores_mao[, 1])                             # 8.49 = λ1: variância do escore = autovalor
cor(escores_mao[, 1], escores_mao[, 2])           # 0: componentes não correlacionados

# 3.1 Scree plot: quanto cada componente explica
p_scree <- fviz_eig(pca, addlabels = TRUE, ylim = c(0, 55), barfill = "#2E6DB4",
                    barcolor = "#2E6DB4", linecolor = "#D55E00") +
  labs(title = "Variância explicada por componente",
       subtitle = "PC1 + PC2 = 67% · PC1 a PC4 = 84%",
       x = "Componente principal", y = "% da variância") + tema
salvar(p_scree, "01_scree")

# 3.2 Corrplot: correlação de cada variável com PC1, PC2 e PC3
col2 <- colorRampPalette(c("darkred", "white", "darkblue"))
cor_pc <- t(pca$var$cor[, 1:3])                 # componentes nas linhas
rownames(cor_pc) <- c("PC1", "PC2", "PC3")
# Ordena as variáveis pelo componente com que mais se correlacionam
# (primeiro as do PC1, depois as do PC2 e as do PC3), para formar blocos.
pc_dominante <- apply(abs(cor_pc), 2, which.max)
forca        <- apply(abs(cor_pc), 2, max)
ordem        <- order(pc_dominante, -forca)
# Destaca só as correlações fortes (|r| ≥ 0,5): as fracas viram 0 (círculo vazio)
cor_destaque <- cor_pc[, ordem]
cor_destaque[abs(cor_destaque) < 0.5] <- 0
png("figuras/pca/02_corrplot.png", width = 3000, height = 1150, res = 300)
corrplot(cor_destaque, is.corr = FALSE, col = col2(20), col.lim = c(-1, 1),
         tl.col = "black", tl.cex = 1.15, tl.srt = 90, cl.pos = "b", cl.cex = 0.8,
         cl.ratio = 0.22, mar = c(0, 0, 1.5, 6), addCoef.col = "white",
         number.cex = 0.62, number.digits = 1,
         title = "Correlações fortes (|r| ≥ 0,5) de cada variável com PC1, PC2 e PC3")
dev.off()

# 3.3 Círculo de correlações (PC1 × PC2)
# select.var: 11 variáveis representativas das duas histórias (evita rótulos sobrepostos)
vars_chave <- c("Sol.NE", "Sol.SE", "Carga.N", "Carga.SE", "Eol.NE",   # PC1: transição
                "Ter.SE", "Ter.N", "Ter.S", "Ter.NE", "Hid.SE", "Hid.N") # PC2: água
p_var <- fviz_pca_var(pca, axes = c(1, 2), col.var = "contrib",
                      select.var = list(name = vars_chave),
                      gradient.cols = c("#9ECAE1", "#2E6DB4", "#08306B"),
                      repel = TRUE, labelsize = 5.5, arrowsize = 0.8) +
  labs(title = "Círculo de correlações (PC1 × PC2)",
       subtitle = "Direita = transição (solar, eólica, carga) · vertical = água (térmica × hidráulica)",
       color = "Contribuição (%)") + tema
salvar(p_var, "03_circulo", w = 8, h = 7)

# 3.4 Biplot: meses coloridos pelo ano
# Só 5 setas (uma por "direção" da história), para os pontos (meses) ficarem visíveis
p_biplot <- fviz_pca_biplot(pca, axes = c(1, 2), geom.ind = "point", pointsize = 3,
                            col.ind = info$ano, gradient.cols = c("#C6DBEF", "#2E6DB4", "#08306B"),
                            select.var = list(name = c("Sol.NE", "Carga.N", "Eol.NE", "Ter.SE", "Hid.SE")),
                            col.var = "#B23A00", repel = TRUE, labelsize = 5.5, alpha.var = 0.9) +
  labs(title = "Biplot: os 120 meses e 5 variáveis-chave",
       subtitle = "Os meses andam da esquerda (2016, claro) para a direita (2025, escuro)",
       color = "Ano") + tema +
  scale_color_gradientn(colours = c("#C6DBEF", "#2E6DB4", "#08306B"), breaks = c(2016, 2019, 2022, 2025), name = "Ano")
salvar(p_biplot, "04_biplot_ano", w = 9, h = 6.5)

# 3.5 Trajetória: a média dos escores de cada ano
escores <- as_tibble(pca$ind$coord[, 1:3]) |> bind_cols(info)
traj <- escores |> group_by(ano) |> summarise(PC1 = mean(Dim.1), PC2 = mean(Dim.2))

p_traj <- ggplot(escores, aes(Dim.1, Dim.2)) +
  geom_hline(yintercept = 0, color = "grey70") + geom_vline(xintercept = 0, color = "grey70") +
  geom_point(aes(color = estacao), alpha = 0.55, size = 2) +
  geom_path(data = traj, aes(PC1, PC2), linewidth = 1, color = "grey20",
            arrow = arrow(length = unit(0.25, "cm"), type = "closed")) +
  geom_point(data = traj, aes(PC1, PC2), size = 3.5, color = "grey20") +
  geom_label_repel(data = traj, aes(PC1, PC2, label = ano), size = 3.8, seed = 1) +
  scale_color_manual(values = c("Seca (mai–out)" = "#D55E00", "Úmida (nov–abr)" = "#2E6DB4")) +
  labs(title = "A trajetória do sistema elétrico no plano PC1 × PC2",
       subtitle = "Pontos = meses (cor = estação) · linha = média de cada ano",
       x = sprintf("PC1 – transição (%.1f%%)", pca$eig[1, 2]),
       y = sprintf("PC2 – hidrologia (%.1f%%)", pca$eig[2, 2]), color = NULL) +
  tema + theme(legend.position = "top")
salvar(p_traj, "05_trajetoria", w = 9, h = 6.5)

# 3.6 Indivíduos por estação, com elipses de confiança
p_estacao <- fviz_pca_ind(pca, axes = c(1, 2), geom.ind = "point", pointsize = 2,
                          habillage = factor(info$estacao), addEllipses = TRUE,
                          ellipse.level = 0.95, palette = c("#D55E00", "#2E6DB4"),
                          mean.point = TRUE) +
  labs(title = "Meses secos × meses úmidos",
       subtitle = "A estação separa os meses no eixo vertical (PC2 = hidrologia)") + tema
salvar(p_estacao, "06_estacao", w = 9, h = 6)

# -----------------------------------------------------------------------------
# 4. HCPC – AGRUPAMENTO HIERÁRQUICO SOBRE OS COMPONENTES PRINCIPAIS
# -----------------------------------------------------------------------------
# Usa os 5 primeiros componentes (88% da variância) e corta a árvore em
# 4 grupos (nb.clust = 4), número que equilibra ganho de inércia e interpretação.
pca5 <- PCA(X, scale.unit = TRUE, ncp = 5, graph = FALSE)
hc   <- HCPC(pca5, nb.clust = 4, graph = FALSE)

grupos <- hc$data.clust$clust
table(info$ano, grupos)                 # que anos caem em cada grupo
hc$desc.var$quanti                      # variáveis que caracterizam cada grupo

# Nomes dados a partir de hc$desc.var$quanti (variáveis que mais distinguem cada grupo)
nomes_regime <- c("1" = "1 · Hídrico clássico", "2" = "2 · Térmico (seca)",
                  "3" = "3 · Hídrico, Norte forte", "4" = "4 · Renovável")
cores_regime <- c("#6BAED6", "#E69F00", "#009E73", "#08306B")

p_hcpc <- fviz_cluster(hc, geom = "point", repel = TRUE, show.clust.cent = TRUE,
                       ellipse.type = "convex", palette = cores_regime, ggtheme = tema) +
  scale_color_manual(values = cores_regime, labels = nomes_regime, name = "Regime") +
  scale_fill_manual(values = cores_regime, labels = nomes_regime, name = "Regime") +
  scale_shape_manual(values = c(16, 17, 15, 3), labels = nomes_regime, name = "Regime") +
  labs(title = "HCPC: 4 regimes de operação do sistema",
       subtitle = "Agrupamento hierárquico (Ward) sobre os 5 primeiros componentes")
salvar(p_hcpc, "07_hcpc_mapa", w = 9, h = 6)

p_hcpc_anos <- tibble(ano = info$ano, grupo = nomes_regime[as.character(grupos)]) |>
  count(ano, grupo) |>
  ggplot(aes(factor(ano), grupo, fill = n)) +
  geom_tile(color = "white", linewidth = 1) +
  geom_text(aes(label = n), color = "white", fontface = "bold", size = 4.5) +
  scale_fill_gradient(low = "#9ECAE1", high = "#08306B", name = "Meses") +
  labs(title = "Em que anos cada regime aparece", x = NULL, y = NULL) +
  tema + theme(panel.grid = element_blank())
salvar(p_hcpc_anos, "08_hcpc_anos", w = 9, h = 4)

# -----------------------------------------------------------------------------
# 5. FAMD – VARIÁVEIS QUANTITATIVAS E QUALITATIVAS JUNTAS
# -----------------------------------------------------------------------------
# A FAMD combina a PCA (numéricas) com a MCA (categóricas). Aqui a estação do
# ano entra como variável ATIVA, junto com as 19 variáveis de geração e carga.
dados_famd <- X |> mutate(estacao = factor(info$estacao))
famd <- FAMD(dados_famd, ncp = 5, graph = FALSE)

round(famd$eig[1:4, ], 1)

# Centro (média) de cada estação nos dois primeiros eixos
centros <- as_tibble(famd$ind$coord[, 1:2]) |>
  mutate(estacao = info$estacao) |>
  group_by(estacao) |>
  summarise(x = mean(Dim.1), y = mean(Dim.2))
c_seca  <- filter(centros, startsWith(estacao, "Seca"))
c_umida <- filter(centros, startsWith(estacao, "Úmida"))

p_famd <- fviz_famd_ind(famd, axes = c(1, 2), geom = "point", habillage = "estacao",
                        addEllipses = TRUE, ellipse.alpha = 0.08, pointsize = 1.8,
                        palette = c("#D55E00", "#2E6DB4"), repel = TRUE, labelsize = 4) +
  annotate("segment", x = c_umida$x, y = c_umida$y, xend = c_seca$x, yend = c_seca$y,
           linewidth = 1.3, color = "grey15",
           arrow = arrow(length = unit(0.35, "cm"), type = "closed")) +
  annotate("label", x = c_seca$x - 0.5, y = c_seca$y + 0.4, hjust = 1, size = 4.8,
           label = sprintf("média dos meses secos: %s", format(round(c_seca$y, 1), decimal.mark = ",")),
           color = "#B23A00", fontface = "bold") +
  annotate("label", x = c_umida$x - 0.5, y = c_umida$y - 0.4, hjust = 1, size = 4.8,
           label = sprintf("média dos meses úmidos: %s", format(round(c_umida$y, 1), decimal.mark = ",")),
           color = "#1F4E8C", fontface = "bold") +
  labs(title = "FAMD: geração, carga e estação do ano juntas",
       subtitle = "A média de cada estação se desloca na vertical, ao longo do eixo da água",
       color = "Estação", fill = "Estação", shape = "Estação") + tema
salvar(p_famd, "09_famd", w = 9, h = 6)

message("Gráficos salvos em figuras/pca/")
