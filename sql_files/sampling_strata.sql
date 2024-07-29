-- !preview conn=channel

SELECT
    CONCAT('H', TO_CHAR(HAUL_JOIN)) AS HAUL_JOIN,
    SAMPLING_STRATA,
    SAMPLING_STRATA_NAME,
    SAMPLING_STRATA_DEPLOYMENT_CATEGORY,
    SAMPLING_STRATA_SELECTION_RATE
FROM
    norpac.debriefed_haul_mv
