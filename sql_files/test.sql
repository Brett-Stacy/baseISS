-- !preview conn=channel

SELECT
    CONCAT('H', TO_CHAR(HAUL_JOIN)) AS HAUL_JOIN,
    CONCAT('T', TO_CHAR(TRIP_JOIN)) AS TRIP_JOIN
FROM
    norpac.debriefed_haul
