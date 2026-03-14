USE CoworkingSpaceSystem
GO

CREATE OR ALTER VIEW Membership.vMemberDetails
AS
SELECT 
    m.member_id,
    m.first_name,
    m.last_name,
    m.email,
    m.phone_number,
    m.status AS member_status,
    p.plan_name,
    p.price_monthly
FROM Membership.Members m
INNER JOIN Membership.Plans p ON m.plan_id = p.plan_id;
GO


CREATE OR ALTER VIEW Billing.vOutstandingInvoices
AS
SELECT 
    bi.invoice_id,
    m.first_name + ' ' + m.last_name AS full_name,
    bi.amount_due,
    bi.due_date,
    bi.status AS invoice_status
FROM Billing.Invoices bi
INNER JOIN Membership.Members m ON bi.member_id = m.member_id
WHERE bi.status = 'UNPAID' OR bi.status = 'OVERDUE';
GO


CREATE OR ALTER VIEW Operations.vTodaysReservations
AS
SELECT 
    r.reservation_id,
    m.first_name,
    m.last_name,
    d.desk_name,
    r.start_time,
    r.end_time
FROM Operations.Reservations r
INNER JOIN Membership.Members m ON r.member_id = m.member_id
INNER JOIN Operations.Desks d ON r.desk_id = d.desk_id
WHERE DATEDIFF(day, r.start_time, GETDATE()) = 0;
