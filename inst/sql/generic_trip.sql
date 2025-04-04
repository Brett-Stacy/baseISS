-- !preview conn=akfin

SELECT
    YEAR,
    TO_CHAR(HAUL_JOIN) AS HAUL_JOIN,
    TO_CHAR(CRUISE) AS CRUISE,
    TO_CHAR(PERMIT) AS PERMIT,
    TO_CHAR(TRIP_SEQ) AS TRIP_SEQ,
    SAMPLING_STRATA,
    SAMPLING_STRATA_NAME,
    SAMPLING_STRATA_DEPLOYMENT_CATEGORY,
    SAMPLING_STRATA_SELECTION_RATE
FROM norpac.debriefed_haul_mv
