use CoworkingSpaceSystem
go

CREATE OR ALTER TRIGGER Membership.tUpdateCreditTimestamp --Change "last_updated" column whenever balance changes
ON Membership.Credits
AFTER UPDATE
AS
BEGIN

	IF UPDATE(available_balance)
	BEGIN
		UPDATE Membership.Credits
		SET last_updated = GETDATE()
		FROM Membership.Credits c
		INNER JOIN inserted i
		ON c.credit_id = i.credit_id;
	END
END
GO	

 ------------------------------------------------------------------ 

CREATE OR ALTER TRIGGER Membership.tLogMemberStatusChanges --Automatically inserts a log entry when a member's status changes
ON Membership.Members
AFTER UPDATE
AS
BEGIN

	IF UPDATE(status)
	BEGIN
		INSERT INTO Activity.Logs (member_id,activity_type,details,timestamp)
		SELECT
		i.member_id, 'STATUS_CHANGE', CONCAT('Status changed from ', d.status, ' to', i.status),GETDATE()

		FROM inserted i --Contains the row after the update
		INNER JOIN deleted d --Containts the row before the update
		ON i.member_id = d.member_id

		WHERE i.status <> d.status;  
	END
END
GO

 ------------------------------------------------------------------
CREATE OR ALTER TRIGGER Operations.tPreventPastBookings --Prevent the creation of reservations in the past
ON Operations.Reservations
AFTER INSERT, UPDATE
AS
BEGIN

    IF EXISTS (SELECT 1 FROM inserted WHERE end_time < GETDATE())
    BEGIN
        ;THROW 51007, 'Cannot create a reservation in the past.', 1;
    END
END
GO
 -----------------------------------------------------------------

CREATE OR ALTER TRIGGER Billing.trg_SuspendMemberOnOverdue --Automatically set a member's status to SUSPENDED once they have an OVERDUE invoice
ON Billing.Invoices
AFTER UPDATE
AS
BEGIN

    IF UPDATE(status)
    BEGIN

        UPDATE m
        SET m.status = 'SUSPENDED'
        FROM Membership.Members m
        INNER JOIN inserted i ON m.member_id = i.member_id
        INNER JOIN deleted d ON i.invoice_id = d.invoice_id

        WHERE i.status = 'OVERDUE'       --It should check if old status was not OVERDUE and NOW changed to OVERDUE
          AND d.status <> 'OVERDUE';   
          

		UPDATE m       --When they paid their OVERDUE invoice
        SET m.status = 'ACTIVE'
        FROM Membership.Members m
        INNER JOIN inserted i ON m.member_id = i.member_id
        INNER JOIN deleted d ON i.invoice_id = d.invoice_id

        WHERE i.status = 'PAID'        
          AND d.status <> 'PAID'
          AND m.status = 'SUSPENDED'   
          AND NOT EXISTS (   
                                        --Check if they have more than one overdue invoices
              SELECT 1 
              FROM Billing.Invoices inv 
              WHERE inv.member_id = m.member_id 
                AND inv.status = 'OVERDUE'
                AND inv.invoice_id <> i.invoice_id   --Update doesnt happen until they pay their other OVERDUE invoices
          );
    END
END
GO

