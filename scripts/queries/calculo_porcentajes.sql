SELECT 
    mission,
    device_type,
    (total_events * 100.0 / total_events_all) as percentage
FROM
(
    SELECT 
        mission,
        device_type,
        count(*) as total_events,
        (
            SELECT count(*)
            FROM events
            WHERE mission NOT IN ('UNKN')
        ) as total_events_all

    FROM events
    WHERE mission NOT IN ('UNKN')
    GROUP BY mission, device_type
) as subquery
