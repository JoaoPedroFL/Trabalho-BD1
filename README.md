# ⚽ Banco de Dados – Copa do Mundo FIFA

Projeto acadêmico com banco de dados relacional da Copa do Mundo e 15 consultas SQL analíticas.

## 🎓 2. Certificados DataCamp
Clique aqui para visualizar o Certificado de Nivelamento SQL
https://drive.google.com/drive/folders/1a6hV053YtCktDCEf7pic9rCFHWafse-h?usp=sharing


## 📁 Estrutura do Repositório

```
/
├── worldcup.db              # Banco de dados SQLite com os dados
├── consultas_copa_mundo.sql # 15 consultas SQL analíticas
└── README.md                # Este arquivo
```

## 🗄️ Tabelas

### `WorldCups` — 20 linhas
Dados gerais de cada edição da Copa do Mundo (1930–2014).

| Coluna | Tipo | Descrição |
|---|---|---|
| Year | INTEGER | Ano da Copa |
| Country | TEXT | País sede |
| Winner | TEXT | Campeão |
| Runners-Up | TEXT | Vice-campeão |
| Third | TEXT | Terceiro lugar |
| Fourth | TEXT | Quarto lugar |
| GoalsScored | INTEGER | Total de gols marcados |
| QualifiedTeams | INTEGER | Número de seleções |
| MatchesPlayed | INTEGER | Partidas disputadas |
| Attendance | REAL | Público total |

### `WorldCupMatches` — 4.572 linhas
Detalhes de cada partida disputada nas Copas.

| Coluna | Tipo | Descrição |
|---|---|---|
| Year | INTEGER | Ano da Copa |
| Datetime | TEXT | Data e hora da partida |
| Stage | TEXT | Fase (Group, Final, Semi-finals…) |
| Stadium | TEXT | Nome do estádio |
| City | TEXT | Cidade |
| Home Team Name | TEXT | Seleção mandante |
| Home Team Goals | INTEGER | Gols do mandante |
| Away Team Goals | INTEGER | Gols do visitante |
| Away Team Name | TEXT | Seleção visitante |
| Win conditions | TEXT | Condição de vitória (pênaltis, prorrogação) |
| Attendance | REAL | Público presente |
| Half-time Home Goals | INTEGER | Gols do mandante no 1º tempo |
| Half-time Away Goals | INTEGER | Gols do visitante no 1º tempo |
| Referee | TEXT | Árbitro principal |
| MatchID | INTEGER | Identificador único da partida |

### `WorldCupPlayers` — 37.784 linhas
Dados individuais de jogadores por partida.

| Coluna | Tipo | Descrição |
|---|---|---|
| RoundID | INTEGER | ID da rodada |
| MatchID | INTEGER | ID da partida (FK → WorldCupMatches) |
| Team Initials | TEXT | Sigla da seleção |
| Coach Name | TEXT | Nome do técnico |
| Line-up | TEXT | `S` = titular, `N` = substituto |
| Shirt Number | INTEGER | Número da camisa |
| Player Name | TEXT | Nome do jogador |
| Position | TEXT | Posição (GK, C…) |
| Event | TEXT | Eventos: `G`=gol, `Y`=amarelo, `R`=vermelho, `P`=pênalti |

## 🔗 Relacionamentos

```
WorldCups (Year)
    └── WorldCupMatches (Year, MatchID)
            └── WorldCupPlayers (MatchID)
```

## 📊 Consultas SQL

O arquivo `consultas_copa_mundo.sql` contém 15 consultas analíticas cobrindo:

| # | Tema | Técnicas |
|---|---|---|
| 01 | Copas mais goleadoras (média gols/partida) | `ORDER BY`, `LIMIT` |
| 02 | Estádios com maior público médio (≥5 jogos) | `INNER JOIN`, `AVG/MAX/MIN`, `HAVING` |
| 03 | Copas com maior amplitude de placar | `INNER JOIN`, `MAX-MIN`, `GROUP BY` |
| 04 | Estádios com mais jogos de mata-mata | `LEFT OUTER JOIN`, `COUNT`, `GROUP BY` |
| 05 | Finais mais goleadoras da história | `INNER JOIN`, `ORDER BY` |
| 06 | Técnicos em 2+ Copas do Mundo | `INNER JOIN`, `COUNT(DISTINCT)`, `HAVING` |
| 07 | Índice disciplinar por seleção (amarelos + vermelhos) | `CASE WHEN`, `GROUP BY`, `HAVING` |
| 08 | Evolução do público por década | `GROUP BY` com expressão, `SUM/AVG` |
| 09 | Ranking de saldo de gols histórico por seleção | `UNION ALL`, `SUM`, `GROUP BY` |
| 10 | Vice-campeãs que nunca venceram a Copa | Subconsulta `NOT IN`, `GROUP BY` |
| 11 | Árbitros com mais partidas apitadas | `COUNT(DISTINCT)`, `HAVING` |
| 12 | Artilheiros titulares da história | `CASE WHEN`, `HAVING`, `ORDER BY` |
| 13 | Cidades que sediaram múltiplas edições | `COUNT(DISTINCT)`, `HAVING` |
| 14 | Copas com maior crescimento de público | `LEFT OUTER JOIN` auto-join |
| 15 | Seleções com maior taxa de uso de reservas | `INNER JOIN`, `CASE WHEN`, `HAVING` |

## ⚙️ Como executar

```bash
# Abrindo o banco no terminal
sqlite3 worldcup.db

# Rodando o script completo
sqlite3 worldcup.db < consultas_copa_mundo.sql

# Rodando uma consulta específica
sqlite3 worldcup.db "SELECT * FROM WorldCups ORDER BY GoalsScored DESC;"
```






