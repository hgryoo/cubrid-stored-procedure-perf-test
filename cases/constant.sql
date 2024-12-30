SELECT count(a.event_nm) as cnt
FROM   ( SELECT /*+ NO_MERGE */ fn_string (athlete_code) as event_nm
         FROM   game
         WHERE  1 = 1
         LIMIT 1
       ) a
WHERE 1 = 1;