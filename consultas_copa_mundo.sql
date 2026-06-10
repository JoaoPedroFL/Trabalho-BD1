-- ============================================================
--  15 CONSULTAS ANALÍTICAS – BANCO DE DADOS COPA DO MUNDO
--  Tabelas: WorldCups | WorldCupMatches | WorldCupPlayers
--
--  ATENÇÃO: colunas com espaço no nome exigem aspas duplas
--  ex: "Home Team Goals", "Team Initials", "Runners-Up"
-- ============================================================


-- ============================================================
-- CONSULTA 01
-- Ranking das Copas com maior média de gols por partida –
-- identificando as edições historicamente mais goleadoras.
-- Técnicas: ORDER BY + LIMIT + cálculo derivado
-- ============================================================
SELECT
    wc.Year,
    wc.Country,
    wc.GoalsScored,
    wc.MatchesPlayed,
    ROUND(wc.GoalsScored * 1.0 / wc.MatchesPlayed, 2) AS avg_goals_per_match
FROM WorldCups wc
ORDER BY avg_goals_per_match DESC
LIMIT 10;


-- ============================================================
-- CONSULTA 02
-- Estádios com ao menos 5 partidas: média, máximo e mínimo
-- de público – os "caldeirões" históricos da Copa do Mundo.
-- Técnicas: AVG/MAX/MIN/COUNT + GROUP BY + HAVING + ORDER BY
-- ============================================================
SELECT
    m.Stadium,
    m.City,
    COUNT(m.MatchID)             AS total_matches,
    ROUND(AVG(m.Attendance), 0)  AS avg_attendance,
    MAX(m.Attendance)            AS max_attendance,
    MIN(m.Attendance)            AS min_attendance
FROM WorldCupMatches m
WHERE m.Attendance IS NOT NULL
GROUP BY m.Stadium, m.City
HAVING COUNT(m.MatchID) >= 5
ORDER BY avg_attendance DESC
LIMIT 10;


-- ============================================================
-- CONSULTA 03
-- Top 5 Copas com maior amplitude de gols entre a partida
-- mais goleada e a menos goleada – torneios dos extremos.
-- Técnicas: INNER JOIN + MAX/MIN/AVG + GROUP BY + ORDER BY + LIMIT
-- ============================================================
SELECT
    wc.Year,
    wc.Country,
    MAX(m."Home Team Goals" + m."Away Team Goals")  AS highest_scoring_match,
    MIN(m."Home Team Goals" + m."Away Team Goals")  AS lowest_scoring_match,
    MAX(m."Home Team Goals" + m."Away Team Goals") -
    MIN(m."Home Team Goals" + m."Away Team Goals")  AS amplitude,
    ROUND(AVG(m."Home Team Goals" + m."Away Team Goals"), 2) AS avg_goals_per_match
FROM WorldCups wc
INNER JOIN WorldCupMatches m ON wc.Year = m.Year
GROUP BY wc.Year, wc.Country
ORDER BY amplitude DESC
LIMIT 5;


-- ============================================================
-- CONSULTA 04
-- Estádios que sediaram jogos de mata-mata por Copa:
-- quais arenas concentraram mais partidas decisivas.
-- Técnicas: LEFT OUTER JOIN + COUNT + GROUP BY + ORDER BY
-- ============================================================
SELECT
    m.Stadium,
    m.City,
    m.Year,
    COUNT(m.MatchID) AS knockout_matches
FROM WorldCupMatches m
LEFT OUTER JOIN WorldCups wc ON m.Year = wc.Year
WHERE m.Stage IN (
    'Final', 'Semi-finals', 'Quarter-finals', 'Round of 16',
    'Third place', 'Match for third place', 'Play-off for third place'
)
GROUP BY m.Stadium, m.City, m.Year
ORDER BY m.Year, knockout_matches DESC;


-- ============================================================
-- CONSULTA 05
-- Gols marcados em cada Final: quais decisões foram mais
-- eletrizantes e quem marcou mais na partida do título.
-- Técnicas: INNER JOIN + GROUP BY + ORDER BY
-- ============================================================
SELECT
    wc.Year,
    wc.Country,
    wc.Winner,
    m."Home Team Name"                               AS home_team,
    m."Away Team Name"                               AS away_team,
    m."Home Team Goals"                              AS home_goals,
    m."Away Team Goals"                              AS away_goals,
    m."Home Team Goals" + m."Away Team Goals"        AS total_goals_final
FROM WorldCups wc
INNER JOIN WorldCupMatches m
    ON wc.Year = m.Year AND m.Stage = 'Final'
ORDER BY total_goals_final DESC;


-- ============================================================
-- CONSULTA 06
-- Técnicos que comandaram seleções em 2 ou mais Copas –
-- os treinadores de maior longevidade no torneio.
-- Técnicas: INNER JOIN + COUNT(DISTINCT) + GROUP BY + HAVING + ORDER BY
-- ============================================================
SELECT
    p."Coach Name",
    p."Team Initials",
    COUNT(DISTINCT m.Year)    AS world_cups_coached,
    COUNT(DISTINCT p.MatchID) AS matches_coached,
    MIN(m.Year)               AS first_wc,
    MAX(m.Year)               AS last_wc
FROM WorldCupPlayers p
INNER JOIN WorldCupMatches m ON p.MatchID = m.MatchID
GROUP BY p."Coach Name", p."Team Initials"
HAVING COUNT(DISTINCT m.Year) >= 2
ORDER BY world_cups_coached DESC, matches_coached DESC
LIMIT 15;


-- ============================================================
-- CONSULTA 07
-- Seleções com maior índice disciplinar acumulado em toda
-- a história: amarelos valem 1 ponto, vermelhos valem 2.
-- Técnicas: COUNT com CASE WHEN + GROUP BY + HAVING + ORDER BY + LIMIT
-- ============================================================
SELECT
    p."Team Initials",
    COUNT(CASE WHEN p.Event LIKE '%Y%' THEN 1 END)  AS yellow_cards,
    COUNT(CASE WHEN p.Event LIKE '%R%' THEN 1 END)  AS red_cards,
    COUNT(CASE WHEN p.Event LIKE '%Y%' THEN 1 END) +
    COUNT(CASE WHEN p.Event LIKE '%R%' THEN 1 END) * 2  AS discipline_index
FROM WorldCupPlayers p
WHERE p.Event IS NOT NULL
GROUP BY p."Team Initials"
HAVING COUNT(CASE WHEN p.Event LIKE '%Y%' THEN 1 END) > 0
ORDER BY discipline_index DESC
LIMIT 15;


-- ============================================================
-- CONSULTA 08
-- Evolução do público por década: como o interesse global
-- na Copa do Mundo cresceu ao longo dos anos.
-- Técnicas: COUNT/SUM/AVG + GROUP BY com expressão de década + ORDER BY
-- ============================================================
SELECT
    (m.Year / 10) * 10          AS decade,
    COUNT(DISTINCT m.Year)      AS world_cups,
    SUM(m.Attendance)           AS total_attendance,
    ROUND(AVG(m.Attendance), 0) AS avg_attendance_per_match,
    COUNT(m.MatchID)            AS total_matches
FROM WorldCupMatches m
WHERE m.Attendance IS NOT NULL
GROUP BY (m.Year / 10) * 10
ORDER BY decade;


-- ============================================================
-- CONSULTA 09
-- Ranking histórico de saldo de gols por seleção em todas
-- as Copas (gols marcados menos gols sofridos).
-- Técnicas: UNION ALL em subconsulta + SUM + GROUP BY + ORDER BY + LIMIT
-- ============================================================
SELECT
    team,
    SUM(goals_scored)                       AS total_goals_scored,
    SUM(goals_conceded)                     AS total_goals_conceded,
    SUM(goals_scored) - SUM(goals_conceded) AS goal_difference,
    COUNT(*)                                AS total_matches
FROM (
    SELECT
        "Home Team Name"  AS team,
        "Home Team Goals" AS goals_scored,
        "Away Team Goals" AS goals_conceded
    FROM WorldCupMatches
    UNION ALL
    SELECT
        "Away Team Name"  AS team,
        "Away Team Goals" AS goals_scored,
        "Home Team Goals" AS goals_conceded
    FROM WorldCupMatches
) AS all_matches
GROUP BY team
ORDER BY goal_difference DESC
LIMIT 15;


-- ============================================================
-- CONSULTA 10
-- Seleções que foram vice-campeãs mas JAMAIS conquistaram
-- o título – os "eternos segundos lugares" da Copa.
-- Técnicas: subconsulta NOT IN + GROUP BY + ORDER BY
-- ============================================================
SELECT
    wc."Runners-Up"  AS team,
    COUNT(*)         AS times_runner_up,
    MIN(wc.Year)     AS first_runner_up,
    MAX(wc.Year)     AS last_runner_up
FROM WorldCups wc
WHERE wc."Runners-Up" NOT IN (SELECT Winner FROM WorldCups)
GROUP BY wc."Runners-Up"
ORDER BY times_runner_up DESC;


-- ============================================================
-- CONSULTA 11
-- Árbitros com maior número de partidas apitadas em
-- pelo menos uma Copa do Mundo.
-- Técnicas: COUNT/COUNT(DISTINCT) + GROUP BY + HAVING + ORDER BY + LIMIT
-- ============================================================
SELECT
    m.Referee,
    COUNT(DISTINCT m.Year) AS world_cups,
    COUNT(m.MatchID)       AS matches_refereed,
    MIN(m.Year)            AS first_year,
    MAX(m.Year)            AS last_year
FROM WorldCupMatches m
WHERE m.Referee IS NOT NULL AND m.Referee != ''
GROUP BY m.Referee
HAVING COUNT(m.MatchID) >= 5
ORDER BY matches_refereed DESC
LIMIT 10;


-- ============================================================
-- CONSULTA 12
-- Jogadores que entraram como titulares e marcaram
-- ao menos 3 gols em toda a história da Copa.
-- Técnicas: COUNT com CASE + GROUP BY + HAVING + ORDER BY + LIMIT
-- ============================================================
SELECT
    p."Player Name",
    p."Team Initials",
    COUNT(DISTINCT p.MatchID)                       AS matches_played,
    COUNT(CASE WHEN p.Event LIKE '%G%' THEN 1 END)  AS goals_scored
FROM WorldCupPlayers p
WHERE p."Line-up" = 'S'
GROUP BY p."Player Name", p."Team Initials"
HAVING COUNT(CASE WHEN p.Event LIKE '%G%' THEN 1 END) >= 3
ORDER BY goals_scored DESC
LIMIT 15;


-- ============================================================
-- CONSULTA 13
-- Cidades que sediaram partidas em múltiplas edições:
-- longevidade histórica como palco de Copa do Mundo.
-- Técnicas: COUNT(DISTINCT) + GROUP BY + HAVING + ORDER BY + LIMIT
-- ============================================================
SELECT
    m.City,
    COUNT(DISTINCT m.Stadium)   AS stadiums_used,
    COUNT(DISTINCT m.Year)      AS world_cups_hosted,
    COUNT(m.MatchID)            AS total_matches,
    ROUND(AVG(m.Attendance), 0) AS avg_attendance
FROM WorldCupMatches m
WHERE m.Attendance IS NOT NULL
GROUP BY m.City
HAVING COUNT(DISTINCT m.Year) >= 2
ORDER BY world_cups_hosted DESC, total_matches DESC
LIMIT 10;


-- ============================================================
-- CONSULTA 14
-- Copas com maior crescimento percentual de público em
-- relação à edição anterior – os saltos históricos de audiência.
-- Técnicas: LEFT OUTER JOIN (auto-join por ano anterior) +
--           cálculo percentual + ORDER BY
-- ============================================================
SELECT
    c_atual.Year,
    c_atual.Country,
    c_atual.Attendance                                     AS attendance_current,
    c_ant.Attendance                                       AS attendance_previous,
    c_ant.Year                                             AS previous_year,
    c_atual.Attendance - c_ant.Attendance                  AS absolute_growth,
    ROUND(
        (c_atual.Attendance - c_ant.Attendance) * 100.0
        / c_ant.Attendance, 1
    )                                                      AS pct_growth
FROM WorldCups c_atual
LEFT OUTER JOIN WorldCups c_ant
    ON c_ant.Year = (
        SELECT MAX(c2.Year)
        FROM WorldCups c2
        WHERE c2.Year < c_atual.Year
    )
WHERE c_ant.Year IS NOT NULL
ORDER BY pct_growth DESC;


-- ============================================================
-- CONSULTA 15
-- Seleções com maior taxa de utilização de reservas:
-- percentual de entradas de substitutos sobre o total,
-- apenas times com ao menos 10 partidas disputadas.
-- Técnicas: INNER JOIN + COUNT com CASE + GROUP BY + HAVING + ORDER BY + LIMIT
-- ============================================================
SELECT
    p."Team Initials",
    COUNT(DISTINCT p."Player Name")                        AS squad_size,
    COUNT(DISTINCT p.MatchID)                              AS matches_played,
    COUNT(CASE WHEN p."Line-up" = 'S' THEN 1 END)         AS starter_appearances,
    COUNT(CASE WHEN p."Line-up" = 'N' THEN 1 END)         AS sub_appearances,
    ROUND(
        COUNT(CASE WHEN p."Line-up" = 'N' THEN 1 END) * 100.0 /
        COUNT(*), 1
    )                                                      AS sub_usage_pct
FROM WorldCupPlayers p
INNER JOIN WorldCupMatches m ON p.MatchID = m.MatchID
GROUP BY p."Team Initials"
HAVING COUNT(DISTINCT p.MatchID) >= 10
ORDER BY sub_usage_pct DESC
LIMIT 15;
