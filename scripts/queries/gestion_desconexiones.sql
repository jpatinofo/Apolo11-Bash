SELECT mission,device_type,device_status, count(*) as total_disconnections FROM events
WHERE mission NOT IN ('UNKN') and device_status IN ('unknown')
GROUP BY mission,device_type,device_status
