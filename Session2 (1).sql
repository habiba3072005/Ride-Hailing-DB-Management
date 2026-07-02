USE RIDE_SYSTEM;

UPDATE request
SET status = 'accepted',
    accepted_at = GETDATE()
WHERE request_id = 109
  AND status = 'pending';

SELECT request_id, status, accepted_at
FROM request
WHERE request_id = 101;

-------------------------------
--Two sessions tried to update the same ride request at the same time.
--Session 1 updated the request and kept the transaction open using WAITFOR DELAY.
--During this time, Session 1 held an exclusive lock on the row.
--When Session 2 tried to update the same row, it was blocked until Session 1 committed.
--After Session 1 committed, the request status became accepted, so Session 2 affected 0 rows.
--This prevents the same ride request from being accepted more than once.
