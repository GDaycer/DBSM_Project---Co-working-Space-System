 ----Create Logins----
USE [master]
GO

CREATE LOGIN [StaffLogin] WITH PASSWORD=N'staff12345', DEFAULT_DATABASE=[CoworkingSpaceSystem], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF;
CREATE LOGIN [AdminLogin] WITH PASSWORD=N'admin12345', DEFAULT_DATABASE=[CoworkingSpaceSystem], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF;
CREATE LOGIN [DeveloperLogin] WITH PASSWORD=N'developer12345', DEFAULT_DATABASE=[CoworkingSpaceSystem], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF;
GO

 ----Create Users for Database----
USE [CoworkingSpaceSystem]
GO

CREATE USER [StaffUser] FOR LOGIN [StaffLogin];
CREATE USER [AdminUser] FOR LOGIN [AdminLogin];
CREATE USER [DeveloperUser] FOR LOGIN [DeveloperLogin];
GO

 ----Assigning Roles----
USE [CoworkingSpaceSystem]
GO

ALTER ROLE [Coworking_Staff] ADD MEMBER [StaffUser];
ALTER ROLE [Coworking_Admin] ADD MEMBER [AdminUser];
ALTER ROLE [Coworking_Developer] ADD MEMBER [DeveloperUser];
GO