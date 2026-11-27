# Dicionário de dados

## Fonte

- **Origem:** ONS – Operador Nacional do Sistema Elétrico, conjunto *Balanço de Energia nos Subsistemas*, base horária
- **Portal:** <https://dados.ons.org.br/dataset/balanco-energia-subsistema>
- **Licença:** Creative Commons Atribuição (CC-BY)
- **Período:** 01/01/2016 a 31/12/2025
- **Download:** novembro de 2026, pelo script `4_codigo_R/baixar_dados.R`

## 1. Dados brutos: `brutos/BALANCO_ENERGIA_SUBSISTEMA_<ano>.csv`

Um arquivo por ano, separado por `;`, com 438.357 linhas no total. Cada linha é **uma hora em um subsistema**.

| Coluna | Tipo | Unidade | Descrição |
|---|---|---|---|
| `id_subsistema` | texto | – | Código do subsistema: `SE` (Sudeste/Centro-Oeste), `S` (Sul), `NE` (Nordeste), `N` (Norte), `SIN` (total nacional) |
| `nom_subsistema` | texto | – | Nome do subsistema |
| `din_instante` | data-hora | – | Início da hora (AAAA-MM-DD HH:MM:SS) |
| `val_gerhidraulica` | número | MWmed | Geração hidráulica |
| `val_gertermica` | número | MWmed | Geração térmica |
| `val_gereolica` | número | MWmed | Geração eólica |
| `val_gersolar` | número | MWmed | Geração solar **centralizada** (não inclui a geração distribuída dos telhados) |
| `val_carga` | número | MWmed | Carga, ou seja, a demanda atendida |
| `val_intercambio` | número | MWmed | Geração − carga: positivo = o subsistema exporta energia |

**MWmed** é a potência média na hora; numericamente, é igual à energia em MWh gerada naquela hora.

### Qualidade e tratamento

- **Solar ausente:** 216 valores ausentes, que ocorrem quando a geração era nula. Foram tratados como 0.
- **Carga zerada:** poucos registros de carga igual a 0, fisicamente impossíveis num subsistema inteiro. Foram tratados como `NA`, ou seja, erro de medição.
- **Cobertura:** o painel é completo, com 8.760 ou 8.784 horas por ano para cada subsistema.

## 2. Dados processados: `processados/`

Gerados por `4_codigo_R/gerar_dados_processados.R`.

### `sin_diario.csv`: médias diárias do SIN (3.653 linhas)

| Coluna | Unidade | Descrição |
|---|---|---|
| `data` | data | Dia |
| `hidraulica`, `termica`, `eolica`, `solar` | GW | Geração média do dia por fonte |
| `carga` | GW | Carga média do dia |
| `participacao_eolica_solar` | proporção (0–1) | (eólica + solar) / geração total |

### `subsistema_mensal.csv`: médias mensais por subsistema (480 linhas)

| Coluna | Unidade | Descrição |
|---|---|---|
| `subsistema` | – | Sudeste/Centro-Oeste, Sul, Nordeste ou Norte |
| `mes` | data | Primeiro dia do mês |
| `hidraulica`, `termica`, `eolica`, `solar` | GW | Geração média do mês por fonte |
| `carga` | GW | Carga média do mês |
| `intercambio` | GW | Intercâmbio médio: positivo = exporta |

### `sin_anual_fonte.csv`: energia anual do SIN por fonte (40 linhas)

| Coluna | Unidade | Descrição |
|---|---|---|
| `ano` | – | 2016 a 2025 |
| `fonte` | – | hidraulica, termica, eolica, solar |
| `twh` | TWh | Energia gerada no ano |
| `participacao` | proporção (0–1) | Fatia da fonte na geração do ano |
