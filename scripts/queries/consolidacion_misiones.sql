SELECT mission,device_status, count(*) as total_killed FROM events
WHERE mission NOT IN ('UNKN') and device_status IN ('killed')
GROUP BY mission, device_status
