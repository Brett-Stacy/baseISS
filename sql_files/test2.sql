-- !preview conn=channel

SELECT
    CONCAT('H', TO_CHAR(HAUL_JOIN)) AS HAUL_JOIN,
    CONCAT('T', TO_CHAR(TRIP_JOIN)) AS TRIP_JOIN,
    TO_CHAR(CRUISE) AS CRUISE,
    PERMIT,
    TO_CHAR(TRIP_SEQ) AS TRIP_SEQ,
    YEAR
FROM
    norpac.debriefed_haul
