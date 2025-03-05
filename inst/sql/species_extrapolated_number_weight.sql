-- !preview conn=akfin

SELECT
    YEAR,
    TO_CHAR(HAUL_JOIN) AS HAUL_JOIN,
    EXTRAPOLATED_NUMBER,
    EXTRAPOLATED_WEIGHT
FROM norpac.debriefed_spcomp_mv
WHERE species_key='XXX'
