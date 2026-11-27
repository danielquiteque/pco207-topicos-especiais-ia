# A transição energética no Sistema Interligado Nacional (2016–2025)

**Projeto de Ciência de Dados em R** · Daniel Quiteque

Análise de **438 mil registros horários** de dados abertos do ONS (Operador Nacional do Sistema Elétrico) para responder: *como a expansão eólica e solar mudou a forma como o Brasil gera eletricidade?* O projeto combina análise exploratória, testes estatísticos e **machine learning**: previsão com XGBoost e clustering com k-means.

## Conteúdo da pasta

```
Projeto_Transicao_Energetica_R/
├── README.md                              ← este arquivo
├── Projeto_Transicao_Energetica.Rproj     ← abra no RStudio
│
├── 1_apresentacao/
│   ├── A_2ª Apresentação_09_Nov/          ← 2ª apresentação (10 min, 11 slides)
│   │   └── apresentacao_10_minutos.pptx / .pdf
│   ├── B_final_completa/                  ← versão completa do projeto (33 slides, com ML)
│   │   └── apresentacao_final_33_slides.pptx / .pdf
│   └── C_avaliacao_PCA_10min/             ← AVALIAÇÃO 27/11: PCA, HCPC e FAMD (13 slides)
│       └── apresentacao_PCA_10min.pptx / .pdf
│
├── 2_relatorio_tecnico/
│   ├── relatorio_tecnico.pdf                ← relatório para leitura (sem código)
│   └── (versão HTML com código: gere com Knit em 4_codigo_R/analise_energia_ons.Rmd)
│
├── 3_dados/
│   ├── dicionario_dados.md                  ← descrição de todas as variáveis
│   ├── brutos/                              ← 10 CSVs originais do ONS (2016–2025)
│   └── processados/                         ← bases limpas: diária, mensal e anual
│
├── 4_codigo_R/
│   ├── instalar_pacotes.R                   ← 1. instala os pacotes
│   ├── baixar_dados.R                       ← 2. baixa os dados do ONS (opcional: já estão na pasta)
│   ├── gerar_dados_processados.R            ← 3. gera as bases processadas
│   ├── pca_energia.R                        ← PCA, HCPC e FAMD (avaliação de 27/11)
│   ├── analise_energia_ons.Rmd              ← 4. relatório completo em R Markdown (inclui ML)
│   └── analise_energia_ons.R                ← o mesmo código, em script .R puro
│
└── figuras/                                 ← os 30 gráficos em PNG
```

**As apresentações:**

| | 2ª apresentação (09/11) | Versão completa | Avaliação de PCA (27/11) |
|---|---|---|---|
| Slides | 11 | 33 | 13 |
| Duração | ~9 min | ~29 min | ~9 min |
| Conteúdo | 6 perguntas, com um gráfico cada | Todos os gráficos, testes e machine learning | PCA, HCPC e FAMD, com a álgebra e as bibliotecas usadas |

## Como reproduzir

1. Instale o **R** (≥ 4.3) e o **RStudio**.
2. Abra `Projeto_Transicao_Energetica.Rproj`. O diretório de trabalho passa a ser esta pasta.
3. No console, rode os scripts de preparação:
   ```r
   source("4_codigo_R/instalar_pacotes.R")
   source("4_codigo_R/gerar_dados_processados.R")
   ```
4. Abra `4_codigo_R/analise_energia_ons.Rmd` e clique em **Knit**. A renderização leva cerca de 2 minutos.

Para gerar o relatório **sem o código** (versão de leitura), rode:
`rmarkdown::render("4_codigo_R/analise_energia_ons.Rmd", params = list(mostrar_codigo = FALSE))`

## Perguntas e respostas

| Pergunta | Método | Resposta |
|---|---|---|
| Quanto a matriz mudou? | Barras 100% e regressão | Eólica + solar: de **5,7% para 29,6%** da geração |
| O que acontece quando falta água? | Linhas e correlação | Na crise de 2021 a térmica saltou para **142 TWh**; r = −0,55 |
| Onde a mudança aconteceu? | Barras divergentes | O Nordeste virou exportador: de −2,0 para **+6,3 GW** |
| Quando o sol e o vento geram? | Heatmap | Sol de dia, vento à noite: as fontes **se complementam** |
| O que isso muda na operação? | Curva do pato | Rampa de cerca de **32 GW** entre 12h e 19h |
| Os resultados são válidos? | Testes de hipótese | As 3 hipóteses confirmadas, **p < 0,001** |
| Dá para prever o consumo de amanhã? | **XGBoost** (ML supervisionado) | Erro médio de **1,47%**, contra 3,73% da referência |
| Que tipos de dia existem? | **k-means** (ML não supervisionado) | 4 tipos; **97%** dos dias de 2025 têm curva do pato |

## PCA, HCPC e FAMD (avaliação de 27/11/2026)

Script: `4_codigo_R/pca_energia.R` · gráficos em `figuras/pca/`.

- **Dados:** 120 meses (2016–2025) × 19 variáveis: geração de cada fonte (hidráulica, térmica, eólica e solar) em cada região, mais a carga de cada região. As variáveis são padronizadas (`scale.unit = TRUE`).
- **PC1 (44,7%) – transição:** solar, eólica do NE e cargas crescem juntas. Os meses andam de 2016 (esquerda) para 2025 (direita).
- **PC2 (22,6%) – hidrologia:** térmicas (+) contra hidráulica do SE e do N (−). Separa os meses secos dos úmidos; 2021, o ano da crise hídrica, é o pico.
- **PC3 (9,1%):** hidráulica do Sul contra a do Norte e do Nordeste.
- **HCPC (4 grupos):** 4 regimes que viraram eras: hídrico clássico (2016–19) → térmico (secas) → hídrico com Norte forte (2020–23) → renovável (2023–25).
- **FAMD:** com a estação do ano como variável ativa, os mesmos dois eixos reaparecem, e a estação se alinha ao eixo da água.

## Métodos

- **Gráficos:** 30 gráficos com ggplot2 e R base: barras, histograma, densidade, Q-Q, boxplot, violino, ridgeline, dispersão, bolhas, matriz de correlação, linhas, área, facetas, heatmap, lollipop, dumbbell, barras divergentes, decomposição de série temporal, ACF, diagnóstico de regressão, cotovelo do k-means e importância de variáveis.
- **Estatística:** Shapiro-Wilk, correlação de Pearson e Spearman, regressão linear com sazonalidade, regressão múltipla, teste t de Welch, Wilcoxon e ANOVA.
- **Machine learning:**
  - **Previsão da carga do dia seguinte:** referência ingênua, regressão linear, random forest (`ranger`) e XGBoost (`xgboost`), com divisão treino/teste no tempo (2016–2023 / 2024–2025) e métricas MAE, RMSE e MAPE.
  - **Engenharia de features:** defasagens (lags), média móvel, calendário e **alvo relativo**, que contorna a incapacidade das árvores de extrapolar.
  - **Enriquecimento:** feriados nacionais fixos e móveis (calculados a partir da Páscoa), com ablação para medir o ganho.
  - **Clustering:** k-means dos perfis horários da carga líquida, com o número de grupos escolhido pelo método do cotovelo.

## Fonte dos dados

ONS – *Balanço de Energia nos Subsistemas*, base horária. <https://dados.ons.org.br> · licença CC-BY.
