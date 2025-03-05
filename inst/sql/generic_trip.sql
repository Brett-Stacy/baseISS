-- !preview conn=akfin

SELECT
    YEAR,
    TO_CHAR(HAUL_JOIN) AS HAUL_JOIN,
    TO_CHAR(CRUISE) AS CRUISE,
    TO_CHAR(PERMIT) AS PERMIT,
    TO_CHAR(TRIP_SEQ) AS TRIP_SEQ
FROM norpac.debriefed_haul_mv
