USE [master]
GO
/****** Object:  Database [CoworkingSpaceSystem]    Script Date: 14.03.2026 15:01:47 ******/
CREATE DATABASE [CoworkingSpaceSystem]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'CoworkingSpaceSystem', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.GG2300006211\MSSQL\DATA\CoworkingSpaceSystem.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'CoworkingSpaceSystem_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.GG2300006211\MSSQL\DATA\CoworkingSpaceSystem_log.ldf' , SIZE = 73728KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF
GO
ALTER DATABASE [CoworkingSpaceSystem] SET COMPATIBILITY_LEVEL = 160
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [CoworkingSpaceSystem].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [CoworkingSpaceSystem] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [CoworkingSpaceSystem] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [CoworkingSpaceSystem] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [CoworkingSpaceSystem] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [CoworkingSpaceSystem] SET ARITHABORT OFF 
GO
ALTER DATABASE [CoworkingSpaceSystem] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [CoworkingSpaceSystem] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [CoworkingSpaceSystem] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [CoworkingSpaceSystem] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [CoworkingSpaceSystem] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [CoworkingSpaceSystem] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [CoworkingSpaceSystem] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [CoworkingSpaceSystem] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [CoworkingSpaceSystem] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [CoworkingSpaceSystem] SET  DISABLE_BROKER 
GO
ALTER DATABASE [CoworkingSpaceSystem] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [CoworkingSpaceSystem] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [CoworkingSpaceSystem] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [CoworkingSpaceSystem] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [CoworkingSpaceSystem] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [CoworkingSpaceSystem] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [CoworkingSpaceSystem] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [CoworkingSpaceSystem] SET RECOVERY FULL 
GO
ALTER DATABASE [CoworkingSpaceSystem] SET  MULTI_USER 
GO
ALTER DATABASE [CoworkingSpaceSystem] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [CoworkingSpaceSystem] SET DB_CHAINING OFF 
GO
ALTER DATABASE [CoworkingSpaceSystem] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [CoworkingSpaceSystem] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [CoworkingSpaceSystem] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [CoworkingSpaceSystem] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'CoworkingSpaceSystem', N'ON'
GO
ALTER DATABASE [CoworkingSpaceSystem] SET QUERY_STORE = ON
GO
ALTER DATABASE [CoworkingSpaceSystem] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
USE [CoworkingSpaceSystem]
GO
/****** Object:  User [StaffUser]    Script Date: 14.03.2026 15:01:47 ******/
CREATE USER [StaffUser] FOR LOGIN [StaffLogin] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [DeveloperUser]    Script Date: 14.03.2026 15:01:47 ******/
CREATE USER [DeveloperUser] FOR LOGIN [DeveloperLogin] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [AdminUser]    Script Date: 14.03.2026 15:01:47 ******/
CREATE USER [AdminUser] FOR LOGIN [AdminLogin] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  DatabaseRole [Coworking_Staff]    Script Date: 14.03.2026 15:01:48 ******/
CREATE ROLE [Coworking_Staff]
GO
/****** Object:  DatabaseRole [Coworking_Developer]    Script Date: 14.03.2026 15:01:48 ******/
CREATE ROLE [Coworking_Developer]
GO
/****** Object:  DatabaseRole [Coworking_Admin]    Script Date: 14.03.2026 15:01:48 ******/
CREATE ROLE [Coworking_Admin]
GO
ALTER ROLE [Coworking_Staff] ADD MEMBER [StaffUser]
GO
ALTER ROLE [Coworking_Developer] ADD MEMBER [DeveloperUser]
GO
ALTER ROLE [Coworking_Admin] ADD MEMBER [AdminUser]
GO
/****** Object:  Schema [Activity]    Script Date: 14.03.2026 15:01:48 ******/
CREATE SCHEMA [Activity]
GO
/****** Object:  Schema [Billing]    Script Date: 14.03.2026 15:01:48 ******/
CREATE SCHEMA [Billing]
GO
/****** Object:  Schema [Membership]    Script Date: 14.03.2026 15:01:48 ******/
CREATE SCHEMA [Membership]
GO
/****** Object:  Schema [Operations]    Script Date: 14.03.2026 15:01:48 ******/
CREATE SCHEMA [Operations]
GO
/****** Object:  UserDefinedFunction [Operations].[fIsAvailable]    Script Date: 14.03.2026 15:01:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

------------------------------------------------------
CREATE   FUNCTION [Operations].[fIsAvailable]
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
/****** Object:  Table [Membership].[Plans]    Script Date: 14.03.2026 15:01:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Membership].[Plans](
	[plan_id] [int] IDENTITY(1,1) NOT NULL,
	[plan_name] [nvarchar](100) NOT NULL,
	[price_monthly] [decimal](10, 2) NOT NULL,
	[max_hours_meeting_room] [int] NULL,
	[description] [nvarchar](500) NULL,
PRIMARY KEY CLUSTERED 
(
	[plan_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Membership].[Members]    Script Date: 14.03.2026 15:01:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Membership].[Members](
	[member_id] [int] IDENTITY(1,1) NOT NULL,
	[first_name] [nvarchar](100) NOT NULL,
	[last_name] [nvarchar](100) NOT NULL,
	[email] [nvarchar](150) NOT NULL,
	[phone_number] [nvarchar](20) NULL,
	[company_name] [nvarchar](150) NULL,
	[join_date] [datetime] NULL,
	[status] [nvarchar](20) NULL,
	[plan_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[member_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [Membership].[vMemberDetails]    Script Date: 14.03.2026 15:01:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   VIEW [Membership].[vMemberDetails]
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
/****** Object:  Table [Billing].[Invoices]    Script Date: 14.03.2026 15:01:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Billing].[Invoices](
	[invoice_id] [int] IDENTITY(1,1) NOT NULL,
	[member_id] [int] NOT NULL,
	[discount_id] [int] NULL,
	[issue_date] [datetime] NULL,
	[due_date] [datetime] NOT NULL,
	[amount_due] [decimal](10, 2) NOT NULL,
	[tax_rate] [decimal](5, 2) NULL,
	[status] [nvarchar](20) NULL,
	[payment_method] [nvarchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[invoice_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [Billing].[vOutstandingInvoices]    Script Date: 14.03.2026 15:01:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [Billing].[vOutstandingInvoices]
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
/****** Object:  Table [Operations].[Desks]    Script Date: 14.03.2026 15:01:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Operations].[Desks](
	[desk_id] [int] IDENTITY(1,1) NOT NULL,
	[desk_name] [nvarchar](50) NOT NULL,
	[desk_type] [nvarchar](50) NULL,
	[is_active] [bit] NULL,
	[area_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[desk_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Operations].[Reservations]    Script Date: 14.03.2026 15:01:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Operations].[Reservations](
	[reservation_id] [int] IDENTITY(1,1) NOT NULL,
	[member_id] [int] NOT NULL,
	[desk_id] [int] NULL,
	[resource_id] [int] NULL,
	[start_time] [datetime] NOT NULL,
	[end_time] [datetime] NOT NULL,
	[booked_entity_type] [nvarchar](20) NOT NULL,
	[status] [nvarchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[reservation_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [Operations].[vTodaysReservations]    Script Date: 14.03.2026 15:01:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE   VIEW [Operations].[vTodaysReservations]
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
GO
/****** Object:  Table [Activity].[Logs]    Script Date: 14.03.2026 15:01:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Activity].[Logs](
	[log_id] [int] IDENTITY(1,1) NOT NULL,
	[member_id] [int] NOT NULL,
	[timestamp] [datetime] NULL,
	[activity_type] [nvarchar](100) NOT NULL,
	[details] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[log_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [Billing].[Discount_Codes]    Script Date: 14.03.2026 15:01:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Billing].[Discount_Codes](
	[discount_id] [int] IDENTITY(1,1) NOT NULL,
	[code] [nvarchar](50) NOT NULL,
	[discount_value] [decimal](10, 2) NOT NULL,
	[discount_type] [nvarchar](20) NULL,
	[start_date] [datetime] NOT NULL,
	[end_date] [datetime] NOT NULL,
	[is_active] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[discount_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Billing].[Transactions]    Script Date: 14.03.2026 15:01:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Billing].[Transactions](
	[transaction_id] [int] IDENTITY(1,1) NOT NULL,
	[invoice_id] [int] NOT NULL,
	[transaction_date] [datetime] NULL,
	[amount_paid] [decimal](10, 2) NOT NULL,
	[payment_method] [nvarchar](50) NOT NULL,
	[status] [nvarchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[transaction_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Membership].[Credits]    Script Date: 14.03.2026 15:01:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Membership].[Credits](
	[credit_id] [int] IDENTITY(1,1) NOT NULL,
	[member_id] [int] NOT NULL,
	[credit_type] [nvarchar](50) NOT NULL,
	[available_balance] [decimal](10, 2) NULL,
	[last_updated] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[credit_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Operations].[Areas]    Script Date: 14.03.2026 15:01:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Operations].[Areas](
	[area_id] [int] IDENTITY(1,1) NOT NULL,
	[area_name] [nvarchar](100) NOT NULL,
	[max_capacity] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[area_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Operations].[Resources]    Script Date: 14.03.2026 15:01:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Operations].[Resources](
	[resource_id] [int] IDENTITY(1,1) NOT NULL,
	[resource_name] [nvarchar](100) NOT NULL,
	[capacity] [int] NULL,
	[hourly_rate] [decimal](10, 2) NOT NULL,
	[area_id] [int] NOT NULL,
	[resource_type_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[resource_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Operations].[ResourceTypes]    Script Date: 14.03.2026 15:01:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Operations].[ResourceTypes](
	[resource_type_id] [int] IDENTITY(1,1) NOT NULL,
	[type_name] [nvarchar](100) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[resource_type_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Activity].[Logs] ADD  DEFAULT (getdate()) FOR [timestamp]
GO
ALTER TABLE [Billing].[Discount_Codes] ADD  DEFAULT ((1)) FOR [is_active]
GO
ALTER TABLE [Billing].[Invoices] ADD  DEFAULT (getdate()) FOR [issue_date]
GO
ALTER TABLE [Billing].[Invoices] ADD  DEFAULT ((0.0)) FOR [tax_rate]
GO
ALTER TABLE [Billing].[Transactions] ADD  DEFAULT (getdate()) FOR [transaction_date]
GO
ALTER TABLE [Membership].[Credits] ADD  DEFAULT ((0.00)) FOR [available_balance]
GO
ALTER TABLE [Membership].[Credits] ADD  DEFAULT (getdate()) FOR [last_updated]
GO
ALTER TABLE [Membership].[Members] ADD  DEFAULT (getdate()) FOR [join_date]
GO
ALTER TABLE [Membership].[Plans] ADD  DEFAULT ((0)) FOR [max_hours_meeting_room]
GO
ALTER TABLE [Operations].[Desks] ADD  DEFAULT ((1)) FOR [is_active]
GO
ALTER TABLE [Operations].[Resources] ADD  DEFAULT ((1)) FOR [capacity]
GO
ALTER TABLE [Activity].[Logs]  WITH CHECK ADD  CONSTRAINT [FK_Log_Member] FOREIGN KEY([member_id])
REFERENCES [Membership].[Members] ([member_id])
GO
ALTER TABLE [Activity].[Logs] CHECK CONSTRAINT [FK_Log_Member]
GO
ALTER TABLE [Billing].[Invoices]  WITH CHECK ADD  CONSTRAINT [FK_Invoice_Discount] FOREIGN KEY([discount_id])
REFERENCES [Billing].[Discount_Codes] ([discount_id])
GO
ALTER TABLE [Billing].[Invoices] CHECK CONSTRAINT [FK_Invoice_Discount]
GO
ALTER TABLE [Billing].[Invoices]  WITH CHECK ADD  CONSTRAINT [FK_Invoice_Member] FOREIGN KEY([member_id])
REFERENCES [Membership].[Members] ([member_id])
GO
ALTER TABLE [Billing].[Invoices] CHECK CONSTRAINT [FK_Invoice_Member]
GO
ALTER TABLE [Billing].[Transactions]  WITH CHECK ADD  CONSTRAINT [FK_Transaction_Invoice] FOREIGN KEY([invoice_id])
REFERENCES [Billing].[Invoices] ([invoice_id])
GO
ALTER TABLE [Billing].[Transactions] CHECK CONSTRAINT [FK_Transaction_Invoice]
GO
ALTER TABLE [Membership].[Credits]  WITH CHECK ADD  CONSTRAINT [FK_Credit_Member] FOREIGN KEY([member_id])
REFERENCES [Membership].[Members] ([member_id])
GO
ALTER TABLE [Membership].[Credits] CHECK CONSTRAINT [FK_Credit_Member]
GO
ALTER TABLE [Membership].[Members]  WITH CHECK ADD  CONSTRAINT [FK_Member_Plan] FOREIGN KEY([plan_id])
REFERENCES [Membership].[Plans] ([plan_id])
GO
ALTER TABLE [Membership].[Members] CHECK CONSTRAINT [FK_Member_Plan]
GO
ALTER TABLE [Operations].[Desks]  WITH CHECK ADD  CONSTRAINT [FK_Desk_Area] FOREIGN KEY([area_id])
REFERENCES [Operations].[Areas] ([area_id])
GO
ALTER TABLE [Operations].[Desks] CHECK CONSTRAINT [FK_Desk_Area]
GO
ALTER TABLE [Operations].[Reservations]  WITH CHECK ADD  CONSTRAINT [FK_Reservation_Desk] FOREIGN KEY([desk_id])
REFERENCES [Operations].[Desks] ([desk_id])
GO
ALTER TABLE [Operations].[Reservations] CHECK CONSTRAINT [FK_Reservation_Desk]
GO
ALTER TABLE [Operations].[Reservations]  WITH CHECK ADD  CONSTRAINT [FK_Reservation_Member] FOREIGN KEY([member_id])
REFERENCES [Membership].[Members] ([member_id])
GO
ALTER TABLE [Operations].[Reservations] CHECK CONSTRAINT [FK_Reservation_Member]
GO
ALTER TABLE [Operations].[Reservations]  WITH CHECK ADD  CONSTRAINT [FK_Reservation_Resource] FOREIGN KEY([resource_id])
REFERENCES [Operations].[Resources] ([resource_id])
GO
ALTER TABLE [Operations].[Reservations] CHECK CONSTRAINT [FK_Reservation_Resource]
GO
ALTER TABLE [Operations].[Resources]  WITH CHECK ADD  CONSTRAINT [FK_Resource_Area] FOREIGN KEY([area_id])
REFERENCES [Operations].[Areas] ([area_id])
GO
ALTER TABLE [Operations].[Resources] CHECK CONSTRAINT [FK_Resource_Area]
GO
ALTER TABLE [Operations].[Resources]  WITH CHECK ADD  CONSTRAINT [FK_Resource_Type] FOREIGN KEY([resource_type_id])
REFERENCES [Operations].[ResourceTypes] ([resource_type_id])
GO
ALTER TABLE [Operations].[Resources] CHECK CONSTRAINT [FK_Resource_Type]
GO
ALTER TABLE [Billing].[Discount_Codes]  WITH CHECK ADD CHECK  (([discount_type]='FLAT' OR [discount_type]='PERCENTAGE'))
GO
ALTER TABLE [Billing].[Invoices]  WITH CHECK ADD CHECK  (([status]='CANCELLED' OR [status]='OVERDUE' OR [status]='UNPAID' OR [status]='PAID'))
GO
ALTER TABLE [Billing].[Transactions]  WITH CHECK ADD CHECK  (([status]='PENDING' OR [status]='FAILED' OR [status]='SUCCESS'))
GO
ALTER TABLE [Membership].[Members]  WITH CHECK ADD CHECK  (([status]='PENDING' OR [status]='SUSPENDED' OR [status]='INACTIVE' OR [status]='ACTIVE'))
GO
ALTER TABLE [Operations].[Reservations]  WITH CHECK ADD  CONSTRAINT [CHK_Reservation_Exclusive_Target] CHECK  (([booked_entity_type]='DESK' AND [desk_id] IS NOT NULL AND [resource_id] IS NULL OR [booked_entity_type]='RESOURCE' AND [resource_id] IS NOT NULL AND [desk_id] IS NULL))
GO
ALTER TABLE [Operations].[Reservations] CHECK CONSTRAINT [CHK_Reservation_Exclusive_Target]
GO
ALTER TABLE [Operations].[Reservations]  WITH CHECK ADD CHECK  (([booked_entity_type]='RESOURCE' OR [booked_entity_type]='DESK'))
GO
ALTER TABLE [Operations].[Reservations]  WITH CHECK ADD CHECK  (([status]='COMPLETED' OR [status]='CANCELLED' OR [status]='CONFIRMED'))
GO
/****** Object:  StoredProcedure [Billing].[pCreateDiscountCode]    Script Date: 14.03.2026 15:01:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 ------------------------------------------------------------------------

CREATE   PROCEDURE [Billing].[pCreateDiscountCode]
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
/****** Object:  StoredProcedure [Billing].[pGenerateMonthlyInvoices]    Script Date: 14.03.2026 15:01:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 --------------------------------------------------------------

CREATE   PROCEDURE [Billing].[pGenerateMonthlyInvoices]  --Generate monthly invoices. If invoice exists for a user, doesn't generate
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
/****** Object:  StoredProcedure [Billing].[pGetFinancialReport]    Script Date: 14.03.2026 15:01:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 ------------------------------------------------------------------

CREATE   PROCEDURE [Billing].[pGetFinancialReport] --Return a summary of finance
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
/****** Object:  StoredProcedure [Billing].[pPaymentTransaction]    Script Date: 14.03.2026 15:01:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [Billing].[pPaymentTransaction] 
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
/****** Object:  StoredProcedure [Membership].[pAddCredits]    Script Date: 14.03.2026 15:01:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 ----------------------------------------------------------------------------

CREATE   PROCEDURE [Membership].[pAddCredits] --Add credits to member's wallet. Creates wallet if it does not exist
    @MemberID INT,
    @CreditType NVARCHAR(50), -- e.g. 'Printing', 'MeetingRoom'
    @Amount DECIMAL(10, 2)
AS 
BEGIN 

    IF NOT EXISTS (SELECT 1 FROM Membership.Members WHERE member_id = @MemberID) --Check if member exists
    BEGIN 
        ;THROW 51012, 'Member ID not found.', 1;
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
/****** Object:  StoredProcedure [Membership].[pRegisterMember]    Script Date: 14.03.2026 15:01:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 ----------------------------------------------------------------

CREATE   PROCEDURE [Membership].[pRegisterMember] --Register new member
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
/****** Object:  StoredProcedure [Membership].[pUpdateMemberStatus]    Script Date: 14.03.2026 15:01:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    -----------------------------------------------

CREATE   PROCEDURE [Membership].[pUpdateMemberStatus]
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
/****** Object:  StoredProcedure [Membership].[pUpdateMemberStatusByID]    Script Date: 14.03.2026 15:01:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

------------------------------------------------------

CREATE   PROCEDURE [Membership].[pUpdateMemberStatusByID]
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
/****** Object:  StoredProcedure [Operations].[pAddDeskToArea]    Script Date: 14.03.2026 15:01:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 -----------------------------------------------------
CREATE   PROCEDURE [Operations].[pAddDeskToArea] --Add a desk by using area name
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
/****** Object:  StoredProcedure [Operations].[pAddResource]    Script Date: 14.03.2026 15:01:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


  ------------------------------------------------------------------------------

  CREATE   PROCEDURE [Operations].[pAddResource]
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
/****** Object:  StoredProcedure [Operations].[pCancelReservation]    Script Date: 14.03.2026 15:01:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 --------------------------------------------------------------

CREATE   PROCEDURE [Operations].[pCancelReservation] --Cancel reservations
    @ReservationID INT
AS
BEGIN

    
    IF NOT EXISTS (SELECT 1 FROM Operations.Reservations WHERE reservation_id = @ReservationID AND status = 'CONFIRMED') --Check if reservation exists and is active
    BEGIN
        ;THROW 51011, 'Reservation not found or already cancelled/completed.', 1;
    END


    UPDATE Operations.Reservations
    SET status = 'CANCELLED'
    WHERE reservation_id = @ReservationID;

    PRINT CONCAT('Reservation ', @ReservationID, ' has been cancelled.');
END
GO
/****** Object:  StoredProcedure [Operations].[pCreateReservation]    Script Date: 14.03.2026 15:01:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  -----------------------------------------------------

CREATE   PROCEDURE [Operations].[pCreateReservation] 
    @MemberID INT,
    @AssetID INT, 
    @AssetType NVARCHAR(20), -- DESK or RESOURCE
    @StartTime DATETIME,
    @EndTime DATETIME
AS
BEGIN
    IF @StartTime <= GETDATE()
    BEGIN
        ;THROW 51006, 'Reservation start time must be in the future.', 1;
    END

    IF @EndTime <= @StartTime
    BEGIN
        ;THROW 51007, 'End time must be after start time.', 1;
    END

    IF EXISTS (SELECT 1 FROM Membership.Members WHERE member_id = @MemberID AND status = 'SUSPENDED')
    BEGIN
        ;THROW 51004, 'Action denied. Member account is SUSPENDED.', 1;
    END

    IF Operations.fIsAvailable(@AssetID, @AssetType, @StartTime, @EndTime) = 0
    BEGIN
        ;THROW 51005, 'Time slot is already booked for this asset.', 1;
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
/****** Object:  StoredProcedure [Operations].[pFindAvailableDesks]    Script Date: 14.03.2026 15:01:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 ---------------------------------------------------------------------

CREATE   PROCEDURE [Operations].[pFindAvailableDesks] --Look for avaiable desks
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
USE [master]
GO
ALTER DATABASE [CoworkingSpaceSystem] SET  READ_WRITE 
GO
