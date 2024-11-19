-- !preview conn=akfin

SELECT
    YEAR,
    TO_CHAR(HAUL_JOIN) AS HAUL_JOIN,
    EXTRAPOLATED_NUMBER
FROM norpac.debriefed_spcomp_mv
WHERE species_key='201'
