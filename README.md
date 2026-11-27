# PCO207 – Tópicos Especiais em Inteligência Artificial

**Introdução ao Data Science em R** · Unifei · Prof. Carlos Silveira · Turma T01 (2026.2)
Aluno: Daniel Quiteque

## Estrutura

```
PCO207 - TÓPICOS ESPECIAIS EM INTELIGÊNCIA ARTIFICIAL - T01 (2026.2 - 2N1234)/
├── A0_1ªApresent_disciplina/      ← 1ª apresentação: a história dos dados
│   ├── 1a_apresentacao_dados_ONS.pptx / .pdf
│   └── balanco_energia_subsistema_2016_2025.csv   (dados usados, 438.357 linhas)
└── [DATA SCIENCE IN R] ATIVIDADE 04 - uso do PCA & CIA em seus dados - 23-11-2026/
    └── projeto final: código R, dados, figuras, relatório e apresentações
```

| Pasta | Conteúdo |
|---|---|
| **A0_1ªApresent_disciplina** | De onde vêm os dados (ONS), quantos são, o que cada variável mede, a qualidade da base e o plano até o projeto final. Inclui o CSV com todos os dados usados. |
| **Atividade 04 – uso do PCA & CIA em seus dados** | Projeto final: PCA, HCPC e FAMD com FactoMineR e factoextra sobre 10 anos de dados do Sistema Interligado Nacional. |

## Atividade 04 em resumo

- **Dados:** 120 meses (2016–2025) × 19 variáveis de geração (hidráulica, térmica, eólica e solar) e carga nas 4 regiões do Sistema Interligado Nacional, a partir de dados abertos do ONS.
- **Código principal:** `4_codigo_R/pca_energia.R`
  - verificação algébrica da PCA com `scale()`, `cor()`, `eigen()` e `%*%`;
  - PCA, corrplot, círculo de correlações, biplot e trajetória dos escores;
  - HCPC (4 regimes) e FAMD.
- **Resultados:**
  - **PC1 (44,7%) = transição renovável:** solar, eólica e carga crescem juntas.
  - **PC2 (22,6%) = hidrologia:** a térmica compensa a hidráulica; 2021 é o pico, por causa da crise hídrica.
  - **HCPC:** 4 regimes que se sucedem no tempo, do hídrico clássico ao renovável.

## Como rodar

1. Abra o arquivo `Projeto_Transicao_Energetica.Rproj`, dentro da pasta da Atividade 04, no RStudio.
2. Execute `source("4_codigo_R/instalar_pacotes.R")`.
3. Execute `source("4_codigo_R/pca_energia.R")`. Os gráficos são salvos em `figuras/pca/`.

Os dados brutos do ONS estão em `3_dados/brutos/` (licença CC-BY).
