USE RIDE_SYSTEM;

BEGIN TRANSACTION;

UPDATE request
SET status = 'accepted',
    accepted_at = GETDATE()
WHERE request_id = 109
  AND status = 'pending';

WAITFOR DELAY '00:00:20';

COMMIT TRANSACTION;

---------------
