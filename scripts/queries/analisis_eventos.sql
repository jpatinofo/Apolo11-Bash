SELECT mission,device_type,device_status, count(*) as total_events FROM events
--WHERE mission NOT IN ('UNKN')
GROUP BY mission, device_type, device_status
