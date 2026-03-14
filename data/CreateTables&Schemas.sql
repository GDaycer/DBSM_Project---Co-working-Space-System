CREATE DATABASE CoworkingSpaceSystem
GO

USE CoworkingSpaceSystem
GO

-- CREATE SCHEMAS

EXEC('CREATE SCHEMA Membership')

EXEC('CREATE SCHEMA Operations')

EXEC('CREATE SCHEMA Billing')

EXEC('CREATE SCHEMA Activity')

-- CREATE TABLES

CREATE TABLE Membership.Plans (
    plan_id INT IDENTITY(1,1) PRIMARY KEY,
    plan_name NVARCHAR(100) NOT NULL,
    price_monthly DECIMAL(10, 2) NOT NULL,
    max_hours_meeting_room INT DEFAULT 0,
    description NVARCHAR(500)
);


CREATE TABLE Membership.Members (
    member_id INT IDENTITY(1,1) PRIMARY KEY,
    first_name NVARCHAR(100) NOT NULL,
    last_name NVARCHAR(100) NOT NULL,
    email NVARCHAR(150) UNIQUE NOT NULL,
    phone_number NVARCHAR(20),
    company_name NVARCHAR(150),
    join_date DATETIME DEFAULT GETDATE(),
    status NVARCHAR(20) CHECK (status IN ('ACTIVE', 'INACTIVE', 'SUSPENDED', 'PENDING')),
    plan_id INT NOT NULL,
    CONSTRAINT FK_Member_Plan FOREIGN KEY (plan_id) REFERENCES Membership.Plans(plan_id)
);


CREATE TABLE Membership.Credits (
    credit_id INT IDENTITY(1,1) PRIMARY KEY,
    member_id INT NOT NULL,
    credit_type NVARCHAR(50) NOT NULL, -- e.g., "Printing", "MeetingRoom"
    available_balance DECIMAL(10, 2) DEFAULT 0.00,
    last_updated DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Credit_Member FOREIGN KEY (member_id) REFERENCES Membership.Members(member_id)
);

CREATE TABLE Operations.Areas (
    area_id INT IDENTITY(1,1) PRIMARY KEY,
    area_name NVARCHAR(100) NOT NULL,
    max_capacity INT NOT NULL
);


CREATE TABLE Operations.ResourceTypes (
    resource_type_id INT IDENTITY(1,1) PRIMARY KEY,
    type_name NVARCHAR(100) NOT NULL
);


CREATE TABLE Operations.Desks (
    desk_id INT IDENTITY(1,1) PRIMARY KEY,
    desk_name NVARCHAR(50) NOT NULL,
    desk_type NVARCHAR(50), 
    is_active BIT DEFAULT 1,
    area_id INT NOT NULL,
    CONSTRAINT FK_Desk_Area FOREIGN KEY (area_id) REFERENCES Operations.Areas(area_id)
);


CREATE TABLE Operations.Resources (
    resource_id INT IDENTITY(1,1) PRIMARY KEY,
    resource_name NVARCHAR(100) NOT NULL,
    capacity INT DEFAULT 1,
    hourly_rate DECIMAL(10, 2) NOT NULL,
    area_id INT NOT NULL,
    resource_type_id INT NOT NULL,
    CONSTRAINT FK_Resource_Area FOREIGN KEY (area_id) REFERENCES Operations.Areas(area_id),
    CONSTRAINT FK_Resource_Type FOREIGN KEY (resource_type_id) REFERENCES Operations.ResourceTypes(resource_type_id)
);


CREATE TABLE Operations.Reservations (
    reservation_id INT IDENTITY(1,1) PRIMARY KEY,
    member_id INT NOT NULL,
    desk_id INT NULL,      
    resource_id INT NULL,  
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    booked_entity_type NVARCHAR(20) NOT NULL CHECK (booked_entity_type IN ('DESK', 'RESOURCE')),
    status NVARCHAR(20) CHECK (status IN ('CONFIRMED', 'CANCELLED', 'COMPLETED')),
    
    CONSTRAINT FK_Reservation_Member FOREIGN KEY (member_id) REFERENCES Membership.Members(member_id),
    CONSTRAINT FK_Reservation_Desk FOREIGN KEY (desk_id) REFERENCES Operations.Desks(desk_id),
    CONSTRAINT FK_Reservation_Resource FOREIGN KEY (resource_id) REFERENCES Operations.Resources(resource_id),

    
    CONSTRAINT CHK_Reservation_Exclusive_Target CHECK (
        (booked_entity_type = 'DESK' AND desk_id IS NOT NULL AND resource_id IS NULL) OR
        (booked_entity_type = 'RESOURCE' AND resource_id IS NOT NULL AND desk_id IS NULL)
    )
);

CREATE TABLE Billing.Discount_Codes (
    discount_id INT IDENTITY(1,1) PRIMARY KEY,
    code NVARCHAR(50) UNIQUE NOT NULL,
    discount_value DECIMAL(10, 2) NOT NULL,
    discount_type NVARCHAR(20) CHECK (discount_type IN ('PERCENTAGE', 'FLAT')),
    start_date DATETIME NOT NULL,
    end_date DATETIME NOT NULL,
    is_active BIT DEFAULT 1
);

CREATE TABLE Billing.Invoices (
    invoice_id INT IDENTITY(1,1) PRIMARY KEY,
    member_id INT NOT NULL,
    discount_id INT NULL,
    issue_date DATETIME DEFAULT GETDATE(),
    due_date DATETIME NOT NULL,
    amount_due DECIMAL(10, 2) NOT NULL,
    tax_rate DECIMAL(5, 2) DEFAULT 0.0,
    status NVARCHAR(20) CHECK (status IN ('PAID', 'UNPAID', 'OVERDUE', 'CANCELLED')),
    payment_method NVARCHAR(50),
    CONSTRAINT FK_Invoice_Member FOREIGN KEY (member_id) REFERENCES Membership.Members(member_id),
    CONSTRAINT FK_Invoice_Discount FOREIGN KEY (discount_id) REFERENCES Billing.Discount_Codes(discount_id)
);

CREATE TABLE Billing.Transactions (
    transaction_id INT IDENTITY(1,1) PRIMARY KEY,
    invoice_id INT NOT NULL,
    transaction_date DATETIME DEFAULT GETDATE(),
    amount_paid DECIMAL(10, 2) NOT NULL,
    payment_method NVARCHAR(50) NOT NULL,
    status NVARCHAR(20) CHECK (status IN ('SUCCESS', 'FAILED', 'PENDING')),
    CONSTRAINT FK_Transaction_Invoice FOREIGN KEY (invoice_id) REFERENCES Billing.Invoices(invoice_id)
);

CREATE TABLE Activity.Logs (
    log_id INT IDENTITY(1,1) PRIMARY KEY,
    member_id INT NOT NULL,
    timestamp DATETIME DEFAULT GETDATE(),
    activity_type NVARCHAR(100) NOT NULL,
    details NVARCHAR(MAX),
    CONSTRAINT FK_Log_Member FOREIGN KEY (member_id) REFERENCES Membership.Members(member_id)
);
GO
