USE CoworkingSpaceSystem
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'CoWorking_Admin' AND type = 'R')
BEGIN
    CREATE ROLE Coworking_Admin;
END

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Coworking_Staff' AND type = 'R')
BEGIN
    CREATE ROLE Coworking_Staff;
END

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Coworking_Developer' AND type = 'R')
BEGIN
    CREATE ROLE Coworking_Developer;
END

  ---Admin Permissions---
GRANT EXECUTE ON SCHEMA::Billing TO Coworking_Admin;
GRANT EXECUTE ON SCHEMA::Membership TO Coworking_Admin;
GRANT EXECUTE ON SCHEMA::Operations TO Coworking_Admin;
GRANT EXECUTE ON SCHEMA::Activity TO Coworking_Admin;

GRANT SELECT ON SCHEMA::Billing TO Coworking_Admin;
GRANT SELECT ON SCHEMA::Membership TO Coworking_Admin;
GRANT SELECT ON SCHEMA::Operations TO Coworking_Admin;
GRANT SELECT ON SCHEMA::Activity TO Coworking_Admin;

GRANT SELECT ON Membership.vMemberDetails TO Coworking_Admin;
GRANT SELECT ON Billing.vOutstandingInvoices TO Coworking_Admin;
GRANT SELECT ON Operations.vTodaysReservations TO Coworking_Admin;

---Block Structure Changes---
DENY ALTER ON SCHEMA::Membership TO Coworking_Admin;
DENY ALTER ON SCHEMA::Operations TO Coworking_Admin;
DENY ALTER ON SCHEMA::Billing TO Coworking_Admin;
DENY ALTER ON SCHEMA::Activity TO Coworking_Admin;

DENY CREATE TABLE TO Coworking_Admin;
DENY CREATE VIEW TO Coworking_Admin;
DENY CREATE PROCEDURE TO Coworking_Admin;
DENY CREATE FUNCTION TO Coworking_Admin;

  ---Staff Permissions----
GRANT EXECUTE ON OBJECT::Membership.pRegisterMember TO Coworking_Staff;
GRANT EXECUTE ON OBJECT::Membership.pAddCredits TO Coworking_Staff;
GRANT EXECUTE ON OBJECT::Membership.pUpdateMemberStatus TO Coworking_Staff;
GRANT EXECUTE ON OBJECT::Membership.pUpdateMemberStatusByID TO Coworking_Staff;

GRANT EXECUTE ON OBJECT::Operations.pCreateReservation TO Coworking_Staff;
GRANT EXECUTE ON OBJECT::Operations.pCancelReservation TO Coworking_Staff;
GRANT EXECUTE ON OBJECT::Operations.pFindAvailableDesks TO Coworking_Staff;
GRANT EXECUTE ON OBJECT::Billing.pPaymentTransaction TO Coworking_Staff;

GRANT SELECT ON Membership.Members TO Coworking_Staff;
GRANT SELECT ON Operations.Desks TO Coworking_Staff;

DENY ALTER ON SCHEMA::Membership TO Coworking_Staff;
DENY ALTER ON SCHEMA::Operations TO Coworking_Staff;
DENY ALTER ON SCHEMA::Billing TO Coworking_Staff;
DENY ALTER ON SCHEMA::Activity TO Coworking_Staff;

DENY CREATE TABLE TO Coworking_Staff;
DENY CREATE VIEW TO Coworking_Staff;
DENY CREATE PROCEDURE TO Coworking_Staff;
DENY CREATE FUNCTION TO Coworking_Staff;

GRANT SELECT ON Membership.vMemberDetails TO Coworking_Staff;
GRANT SELECT ON Operations.vTodaysReservations TO Coworking_Staff;

--Developer Permissioms---
GRANT CONTROL ON SCHEMA::Membership TO Coworking_Developer;
GRANT CONTROL ON SCHEMA::Operations TO Coworking_Developer;
GRANT CONTROL ON SCHEMA::Billing TO Coworking_Developer;
GRANT CONTROL ON SCHEMA::Activity TO Coworking_Developer;


GRANT VIEW DEFINITION TO Coworking_Developer;
GRANT CREATE SCHEMA TO Coworking_Developer;

GRANT CREATE TABLE TO Coworking_Developer;
GRANT CREATE VIEW TO Coworking_Developer;
GRANT CREATE PROCEDURE TO Coworking_Developer;
GRANT CREATE FUNCTION TO Coworking_Developer;

