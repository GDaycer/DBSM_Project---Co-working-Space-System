USE CoworkingSpaceSystem
GO

CREATE OR ALTER PROCEDURE Billing.pPaymentTransaction 
    @InvoiceID INT, 
    @AmountPaid DECIMAL(10,2), 
    @PaymentMethod NVARCHAR(50),
    @DiscountID INT = NULL,
    @Credit BIT = 0,
    @CreditType NVARCHAR(50) = NULL
AS
BEGIN

    BEGIN TRY
        BEGIN TRANSACTION;
        
        DECLARE @MemberID INT;
        
        SELECT @MemberID = member_id 
        FROM Billing.Invoices 
        WHERE invoice_id = @InvoiceID;

        IF @MemberID IS NULL
        BEGIN
            ;THROW 51020, 'Invoice not found', 1; 
        END

        IF @DiscountID IS NOT NULL
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM Billing.Discount_Codes WHERE discount_id = @DiscountID AND is_active = 1)
            BEGIN
                ;THROW 51001, 'Invalid or inactive discount code.', 1;
            END

            DECLARE @DiscountValue DECIMAL(10,2);
            DECLARE @DiscountType NVARCHAR(20);

            SELECT @DiscountValue = discount_value, @DiscountType = discount_type
            FROM Billing.Discount_Codes
            WHERE discount_id = @DiscountID;

            IF @DiscountType = 'FLAT'
            BEGIN
                UPDATE Billing.Invoices
                SET amount_due = CASE 
                                   WHEN (amount_due - @DiscountValue) < 0 THEN 0 
                                   ELSE (amount_due - @DiscountValue) 
                                 END, 
                    discount_id = @DiscountID
                WHERE invoice_id = @InvoiceID;
            END
            ELSE IF @DiscountType = 'PERCENTAGE'
            BEGIN
                UPDATE Billing.Invoices
                SET amount_due = amount_due - (amount_due * (@DiscountValue / 100)),
                    discount_id = @DiscountID
                WHERE invoice_id = @InvoiceID;
            END
        END

        IF @Credit = 1
        BEGIN
            IF @CreditType IS NULL
            BEGIN
                ;THROW 51001, 'Credit Type must be specified when using credit payment.', 1;
            END

            DECLARE @CurrentBalance DECIMAL(10, 2);
            DECLARE @CreditID INT;

            SELECT 
                @CreditID = credit_id,
                @CurrentBalance = available_balance 
            FROM Membership.Credits WITH (UPDLOCK, ROWLOCK) 
            WHERE member_id = @MemberID AND credit_type = @CreditType;

            IF @CreditID IS NULL
            BEGIN
                DECLARE @Msg NVARCHAR(200) = 'Member does not have a ' + @CreditType + ' credit account.';
                ;THROW 51002, @Msg, 1;
            END

            IF @CurrentBalance < @AmountPaid
            BEGIN
                ;THROW 51003, 'Insufficient credit balance.', 1;
            END
            ELSE
            BEGIN
                UPDATE Membership.Credits
                SET available_balance = available_balance - @AmountPaid,
                    last_updated = GETDATE()
                WHERE credit_id = @CreditID;
            END
        END



        INSERT INTO Billing.Transactions (invoice_id, amount_paid, payment_method, status, transaction_date)
        VALUES(@InvoiceID, @AmountPaid, @PaymentMethod, 'SUCCESS', GETDATE());


        DECLARE @CurrentAmountDue DECIMAL(10,2);
        DECLARE @TaxRate DECIMAL(5,2);          
        DECLARE @TotalRequired DECIMAL(10,2); 

        SELECT 
            @CurrentAmountDue = amount_due,
            @TaxRate = ISNULL(tax_rate, 0) 
        FROM Billing.Invoices 
        WHERE invoice_id = @InvoiceID;

        SET @TotalRequired = @CurrentAmountDue + (@CurrentAmountDue * (@TaxRate / 100));

        IF (@AmountPaid >= @TotalRequired)
        BEGIN
            UPDATE Billing.Invoices
            SET status = 'PAID', 
                amount_due = 0, 
                payment_method = @PaymentMethod
            WHERE invoice_id = @InvoiceID;
        END
        ELSE
        BEGIN 
            DECLARE @PrincipalPaid DECIMAL(10, 2);
            SET @PrincipalPaid = @AmountPaid / (1 + (@TaxRate / 100));

            UPDATE Billing.Invoices
            SET status = 'UNPAID', 
                amount_due = amount_due - @PrincipalPaid
            WHERE invoice_id = @InvoiceID;

            PRINT 'Partial payment accepted. Remaining Principal updated.';
        END

        COMMIT TRANSACTION;
        PRINT 'Payment processed successfully.';

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END
        ;THROW;
    END CATCH
END
GO
    -----------------------------------------------

CREATE OR ALTER PROCEDURE Membership.pUpdateMemberStatus
    @FirstName NVARCHAR(100),
    @LastName NVARCHAR(100),
    @NewStatus NVARCHAR(20)
AS
BEGIN


    IF @NewStatus NOT IN ('ACTIVE', 'INACTIVE', 'SUSPENDED', 'PENDING')
    BEGIN
        ;THROW 51004, 'Invalid status value. Allowed: ACTIVE, INACTIVE, SUSPENDED, PENDING.', 1;
    END

    DECLARE @MemberID INT;
    DECLARE @Count INT;

    SELECT @Count = COUNT(member_id) 
    FROM Membership.Members 
    WHERE first_name = @FirstName AND last_name = @LastName;

    IF @Count = 0
    BEGIN
        ;THROW 51005, 'Member not found.', 1;
    END

    IF @Count > 1
    BEGIN
        ;THROW 51006, 'Multiple members found with this name. Please use procedure pUpdateMemberStatusByID ', 1;
    END


    SELECT @MemberID = member_id 
    FROM Membership.Members 
    WHERE first_name = @FirstName AND last_name = @LastName;


    UPDATE Membership.Members
    SET status = @NewStatus
    WHERE member_id = @MemberID;

    PRINT CONCAT('Member status updated to ', @NewStatus);
END
GO

------------------------------------------------------

CREATE OR ALTER PROCEDURE Membership.pUpdateMemberStatusByID
    @MemberID INT,
    @NewStatus NVARCHAR(20)
AS
BEGIN


    IF @NewStatus NOT IN ('ACTIVE', 'INACTIVE', 'SUSPENDED', 'PENDING')
    BEGIN
        ;THROW 51007, 'Invalid status value. Allowed: ACTIVE, INACTIVE, SUSPENDED, PENDING.', 1;
    END

    
    IF NOT EXISTS (SELECT 1 FROM Membership.Members WHERE member_id = @MemberID) --Check if member exists
    BEGIN
        ;THROW 51008,'Member ID not found.', 1;
    END


    UPDATE Membership.Members
    SET status = @NewStatus
    WHERE member_id = @MemberID;

    PRINT CONCAT('Member ID ', @MemberID, ' status updated to ', @NewStatus);
END
GO	

------------------------------------------------------
CREATE OR ALTER FUNCTION Operations.fIsAvailable
(
    @AssetID INT,
    @AssetType NVARCHAR(20), --'DESK' or 'RESOURCE'
    @StartTime DATETIME,
    @EndTime DATETIME
)
RETURNS BIT
AS
BEGIN
    DECLARE @IsAvailable BIT = 1;
    DECLARE @DeskID INT = NULL;
    DECLARE @ResourceID INT = NULL;

    IF @AssetType = 'DESK' SET @DeskID = @AssetID;
    IF @AssetType = 'RESOURCE' SET @ResourceID = @AssetID;

    IF EXISTS (
        SELECT 1 
        FROM Operations.Reservations
        WHERE 
            status = 'CONFIRMED'
            AND((booked_entity_type = 'DESK' AND desk_id = @DeskID) OR (booked_entity_type = 'RESOURCE' AND resource_id = @ResourceID))
            AND(@StartTime < end_time AND @EndTime > start_time))
    BEGIN
        SET @IsAvailable = 0;
    END

    RETURN @IsAvailable;
END
GO

  -----------------------------------------------------

CREATE OR ALTER PROCEDURE Operations.pCreateReservation 
    @MemberID INT,
    @AssetID INT, 
    @AssetType NVARCHAR(20), -- DESK or RESOURCE
    @StartTime DATETIME,
    @EndTime DATETIME
AS
BEGIN
    IF @StartTime <= GETDATE()
    BEGIN
        ;THROW 51009, 'Reservation start time must be in the future.', 1;
    END

    IF @EndTime <= @StartTime
    BEGIN
        ;THROW 51010, 'End time must be after start time.', 1;
    END

    IF EXISTS (SELECT 1 FROM Membership.Members WHERE member_id = @MemberID AND status = 'SUSPENDED')
    BEGIN
        ;THROW 51011, 'Action denied. Member account is SUSPENDED.', 1;
    END

    IF Operations.fIsAvailable(@AssetID, @AssetType, @StartTime, @EndTime) = 0
    BEGIN
        ;THROW 51012, 'Time slot is already booked for this asset.', 1;
    END

    DECLARE @DeskID INT = NULL;
    DECLARE @ResourceID INT = NULL;

    IF @AssetType = 'DESK' SET @DeskID = @AssetID;
    IF @AssetType = 'RESOURCE' SET @ResourceID = @AssetID;

    INSERT INTO Operations.Reservations (member_id, desk_id, resource_id, start_time, end_time, booked_entity_type, status)
    VALUES (@MemberID, @DeskID, @ResourceID, @StartTime, @EndTime, @AssetType, 'CONFIRMED');

    PRINT 'Reservation confirmed.';
END
GO

 --------------------------------------------------------------

CREATE OR ALTER PROCEDURE Operations.pCancelReservation --Cancel reservations
    @ReservationID INT
AS
BEGIN

    
    IF NOT EXISTS (SELECT 1 FROM Operations.Reservations WHERE reservation_id = @ReservationID AND status = 'CONFIRMED') --Check if reservation exists and is active
    BEGIN
        ;THROW 51030, 'Reservation not found or already cancelled/completed.', 1;
    END


    UPDATE Operations.Reservations
    SET status = 'CANCELLED'
    WHERE reservation_id = @ReservationID;

    PRINT CONCAT('Reservation ', @ReservationID, ' has been cancelled.');
END
GO

 ---------------------------------------------------------------------

CREATE OR ALTER PROCEDURE Operations.pFindAvailableDesks --Look for avaiable desks
    @StartTime DATETIME,
    @EndTime DATETIME,
    @AreaID INT = NULL  --If given NULl as a parameter, it searches ALL areas
AS

BEGIN

    SELECT 
        d.desk_id, 
        d.desk_name, 
        d.desk_type,
        a.area_name
    FROM Operations.Desks d
    JOIN Operations.Areas a ON d.area_id = a.area_id
    WHERE d.is_active = 1
      AND (@AreaID IS NULL OR d.area_id = @AreaID)       -- If @AreaID is provided, filter by it; otherwise ignore this line

      AND d.desk_id NOT IN ( --Exclude the reserved desk
          SELECT desk_id 
          FROM Operations.Reservations
          WHERE status = 'CONFIRMED'
            AND booked_entity_type = 'DESK'
            AND (@StartTime < end_time AND @EndTime > start_time)
            AND desk_id IS NOT NULL
      );
END
GO

 ----------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE Membership.pAddCredits --Add credits to member's wallet. Creates wallet if it does not exist
    @MemberID INT,
    @CreditType NVARCHAR(50), -- e.g. 'Printing', 'MeetingRoom'
    @Amount DECIMAL(10, 2)
AS 
BEGIN 

    IF NOT EXISTS (SELECT 1 FROM Membership.Members WHERE member_id = @MemberID) --Check if member exists
    BEGIN 
        ;THROW 51031, 'Member ID not found.', 1;
    END  

    IF EXISTS (SELECT 1 FROM Membership.Credits WHERE member_id = @MemberID AND credit_type = @CreditType) -- Check if this specific credit wallet exists for the user
    BEGIN   
        -- Update existing
        UPDATE Membership.Credits
        SET available_balance = available_balance + @Amount,last_updated = GETDATE()
        WHERE member_id = @MemberID AND credit_type =@CreditType;
    END

    ELSE
    BEGIN 
        -- Insert new
        INSERT INTO Membership.Credits (member_id, credit_type,available_balance)
        VALUES (@MemberID,@CreditType, @Amount);
    END

    PRINT CONCAT('Added ',@Amount,' to ', @CreditType,' credits for Member ', @MemberID);
END
GO

 --------------------------------------------------------------

CREATE OR ALTER PROCEDURE Billing.pGenerateMonthlyInvoices  --Generate monthly invoices. If invoice exists for a user, doesn't generate
AS
BEGIN
    DECLARE @GeneratedCount INT = 0;

   
    INSERT INTO Billing.Invoices (member_id, issue_date,due_date, amount_due, status,tax_rate) -- Insert NEW invoices
    SELECT 
        m.member_id,
        GETDATE(), -- Issue Date: Today
        DATEADD(day, 14, GETDATE()),       --Due Date: 14 days from now
        p.price_monthly,
        'UNPAID',
        5.00
    FROM Membership.Members m
    JOIN Membership.Plans p ON m.plan_id = p.plan_id
    WHERE m.status = 'ACTIVE'
       
      AND NOT EXISTS (  --Do not generate if an invoice already exists for this member THIS MONTH
          SELECT 1 
          FROM Billing.Invoices i
          WHERE i.member_id = m.member_id 
            AND MONTH(i.issue_date) = MONTH(GETDATE()) 
            AND YEAR(i.issue_date) = YEAR(GETDATE())
      );

    SET @GeneratedCount = @@ROWCOUNT;

    PRINT CONCAT('Batch Complete. generated ', @GeneratedCount, ' new invoices.');
END
GO

 ------------------------------------------------------------------

CREATE OR ALTER PROCEDURE Billing.pGetFinancialReport --Return a summary of finance
    @StartDate DATETIME,
    @EndDate DATETIME
AS
BEGIN


    DECLARE @TotalInvoiced DECIMAL(10,2);  --Total invoiced: What we asked for
    SELECT @TotalInvoiced = ISNULL(SUM(amount_due), 0)
    FROM Billing.Invoices
    WHERE issue_date BETWEEN @StartDate AND @EndDate;


    DECLARE @TotalCollected DECIMAL(10,2); --What we have in the bank
    SELECT @TotalCollected = ISNULL(SUM(amount_paid), 0)
    FROM Billing.Transactions
    WHERE transaction_date BETWEEN @StartDate AND @EndDate 
      AND status = 'SUCCESS';

    
    DECLARE @Unpaid DECIMAL(10,2); -- Unpaid debts from invoices
    SELECT @Unpaid = ISNULL(SUM(amount_due), 0)
    FROM Billing.Invoices
    WHERE issue_date BETWEEN @StartDate AND @EndDate 
      AND status IN ('UNPAID', 'OVERDUE');


    SELECT  --Results
        @StartDate AS Report_Start,
        @EndDate AS Report_End,
        @TotalInvoiced AS Total_Invoiced_Amount,
        @TotalCollected AS Total_Cash_Collected,
        @Unpaid AS Unpaid_Invoices_Amount;
END
GO
 ----------------------------------------------------------------

CREATE OR ALTER PROCEDURE Membership.pRegisterMember --Register new member
    @FirstName NVARCHAR(100),
    @LastName NVARCHAR(100),
    @Email NVARCHAR(150),
    @PlanID INT,
    @Phone NVARCHAR(20) = NULL,
    @Company NVARCHAR(150) = NULL
AS
BEGIN

    IF EXISTS (SELECT 1 FROM Membership.Members WHERE email = @Email) --Check if email already exists
    BEGIN
        ;THROW 51013, 'Email address already registered.', 1;
    END

    IF NOT EXISTS (SELECT 1 FROM Membership.Plans WHERE plan_id = @PlanID) --Check if written plan exists
    BEGIN
        ;THROW 51014, 'Plan ID does not exist.', 1;
    END


    INSERT INTO Membership.Members (first_name, last_name, email, phone_number, company_name, plan_id, status)
    VALUES (@FirstName, @LastName, @Email, @Phone, @Company, @PlanID, 'ACTIVE');
    
    DECLARE @NewID INT = SCOPE_IDENTITY(); --Returns the last created IDENTITY ID
    PRINT CONCAT('Member Registered Successfully. New Member ID: ', @NewID);
END
GO

 -----------------------------------------------------
CREATE OR ALTER PROCEDURE Operations.pAddDeskToArea --Add a desk by using area name
    @DeskName NVARCHAR(50),
    @DeskType NVARCHAR(50),
    @AreaName NVARCHAR(100)
AS
BEGIN

    DECLARE @AreaID INT;

    SELECT @AreaID = area_id    --Find the ID of the given area name
    FROM Operations.Areas 
    WHERE area_name = @AreaName; 

    IF @AreaID IS NULL
    BEGIN
        ;THROW 51015, 'Area Name not found.', 1;
    END

    INSERT INTO Operations.Desks (desk_name, desk_type, is_active, area_id)
    VALUES (@DeskName, @DeskType, 1, @AreaID);

    PRINT CONCAT('Desk "', @DeskName, '" added to area "', @AreaName, '".');
END
GO

 ------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE Billing.pCreateDiscountCode
    @Code NVARCHAR(50),
    @Value DECIMAL(10,2),
    @Type NVARCHAR(20), -- 'PERCENTAGE' or 'FLAT'
    @StartDate DATETIME,
    @EndDate DATETIME
AS
BEGIN

    
    IF @EndDate <= @StartDate  --End Date must be after Start Date
    BEGIN
        ;THROW 51016, 'End Date must be after Start Date.', 1;
    END


    IF @Type NOT IN ('PERCENTAGE', 'FLAT') --Validate the type
    BEGIN
        ;THROW 51017, 'Invalid Discount Type. Use PERCENTAGE or FLAT.', 1;
    END

    INSERT INTO Billing.Discount_Codes (code, discount_value, discount_type, start_date, end_date, is_active)
    VALUES (@Code, @Value, @Type, @StartDate, @EndDate, 1);

    PRINT 'Discount Code Created.';
END
GO


  ------------------------------------------------------------------------------

  CREATE OR ALTER PROCEDURE Operations.pAddResource
    @ResourceName NVARCHAR(100),
    @Capacity INT,
    @HourlyRate DECIMAL(10, 2),
    @AreaName NVARCHAR(100),
    @TypeName NVARCHAR(100)
AS
BEGIN
    DECLARE @AreaID INT;
    DECLARE @ResourceTypeID INT;

    SELECT @AreaID = area_id FROM Operations.Areas WHERE area_name = @AreaName;
    IF @AreaID IS NULL
    BEGIN
        ;THROW 51018, 'Area Name not found.', 1;
    END

    SELECT @ResourceTypeID = resource_type_id FROM Operations.ResourceTypes WHERE type_name = @TypeName;
    IF @ResourceTypeID IS NULL
    BEGIN
        ;THROW 51019, 'Resource Type not found.', 1;
    END

    INSERT INTO Operations.Resources (resource_name, capacity, hourly_rate, area_id, resource_type_id)
    VALUES (@ResourceName, @Capacity, @HourlyRate, @AreaID, @ResourceTypeID);

    PRINT CONCAT('Resource "', @ResourceName, '" added to area "', @AreaName, '".');
END
GO


