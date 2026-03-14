use CoworkingSpaceSystem
go

----Discount Codes----
EXEC Billing.pCreateDiscountCode 'Launch20', 20.00, 'PERCENTAGE', '2025-01-01','2025-12-31';
EXEC Billing.pCreateDiscountCode 'LAUNCH20', 20.00, 'PERCENTAGE', '2025-01-01', '2025-12-31';
EXEC Billing.pCreateDiscountCode 'SUMMER50', 50.00, 'FLAT', '2025-06-01', '2025-08-31';
EXEC Billing.pCreateDiscountCode 'STUDENT15', 15.00, 'PERCENTAGE', '2025-01-01', '2030-12-31';



----Adding Members----
EXEC Membership.pRegisterMember 'Elias', 'Vance', 'elias.vance@example.com', 1, '555-0101', 'TechSolutions';
EXEC Membership.pRegisterMember 'Marcus', 'Reed', 'marcus.reed@example.com', 1, '555-0102', NULL;
EXEC Membership.pRegisterMember 'Alice', 'Harper', 'alice.harper@example.com', 1, '555-0103', 'Harper Consulting';
EXEC Membership.pRegisterMember 'Robert', 'Boyd', 'robert.boyd@example.com', 1, '555-0104', 'BlueSky Construction';
EXEC Membership.pRegisterMember 'Charles', 'Davis', 'charles.davis@example.com', 1, '555-0105', 'Davis Design';

EXEC Membership.pRegisterMember 'Sarah', 'Chen', 'sarah.chen@example.com', 2, '555-0106', 'Chen Graphics';
EXEC Membership.pRegisterMember 'Diana', 'Park', 'diana.park@example.com', 2, '555-0107', 'Park Legal Group';
EXEC Membership.pRegisterMember 'Brian', 'Wright', 'brian.wright@example.com', 2, '555-0108', 'Wright Architect';
EXEC Membership.pRegisterMember 'Calvin', 'King', 'calvin.king@example.com', 2, '555-0109', 'Daily News Corp';

EXEC Membership.pRegisterMember 'Thomas', 'Stone', 'thomas.stone@example.com', 3, '555-0110', 'Stone Industries';
EXEC Membership.pRegisterMember 'Steven', 'Rhodes', 'steven.rhodes@example.com', 3, '555-0111', 'Rhodes Logistics';
EXEC Membership.pRegisterMember 'Natalie', 'Ross', 'natalie.ross@example.com', 3, '555-0112', 'Ross Security';

----Adding Desks----

EXEC Operations.pAddDeskToArea 'QZ-101', 'HOT', 'Quiet Zone';
EXEC Operations.pAddDeskToArea 'QZ-102', 'HOT', 'Quiet Zone';
EXEC Operations.pAddDeskToArea 'QZ-103', 'HOT', 'Quiet Zone';
EXEC Operations.pAddDeskToArea 'QZ-104', 'STANDING', 'Quiet Zone';
EXEC Operations.pAddDeskToArea 'QZ-105', 'STANDING', 'Quiet Zone';

EXEC Operations.pAddDeskToArea 'CH-201', 'HOT', 'Collab Hub';
EXEC Operations.pAddDeskToArea 'CH-202', 'HOT', 'Collab Hub';
EXEC Operations.pAddDeskToArea 'CH-203', 'HOT', 'Collab Hub';
EXEC Operations.pAddDeskToArea 'CH-301', 'STANDING', 'Collab Hub';

EXEC Operations.pAddDeskToArea 'PS-001', 'DEDICATED', 'Private Suites';
EXEC Operations.pAddDeskToArea 'PS-002', 'DEDICATED', 'Private Suites';
EXEC Operations.pAddDeskToArea 'PS-003', 'DEDICATED', 'Private Suites';
EXEC Operations.pAddDeskToArea 'PS-004', 'DEDICATED', 'Private Suites';

----Adding Resources----

EXEC Operations.pAddResource 'Focus Room A', 4, 25.00, 'Quiet Zone', 'Meeting Room';
EXEC Operations.pAddResource 'Focus Room B', 4, 25.00, 'Quiet Zone', 'Meeting Room';
EXEC Operations.pAddResource 'The Boardroom', 12, 60.00, 'Collab Hub', 'Meeting Room';
EXEC Operations.pAddResource 'Phone Booth 1', 1, 0.00, 'Collab Hub', 'Phone Booth';
EXEC Operations.pAddResource 'Phone Booth 2', 1, 0.00, 'Collab Hub', 'Phone Booth';
EXEC Operations.pAddResource 'Podcast Studio A', 3, 75.00, 'Private Suites', 'Podcast Studio';
EXEC Operations.pAddResource 'Grand Hall', 50, 150.00, 'Roof Garden', 'Event Hall';

----Adding Credits to Members----
EXEC Membership.pAddCredits 1, 'Printing', 10.00;     
EXEC Membership.pAddCredits 1, 'MeetingRoom', 20.00;  

EXEC Membership.pAddCredits 2, 'Printing', 5.00;      
EXEC Membership.pAddCredits 2, 'GuestPass', 2.00;    

EXEC Membership.pAddCredits 3, 'Printing', 15.00;     
EXEC Membership.pAddCredits 3, 'MeetingRoom', 10.00; 

EXEC Membership.pAddCredits 4, 'Printing', 10.00;     



EXEC Membership.pAddCredits 6, 'MeetingRoom', 50.00;  
EXEC Membership.pAddCredits 6, 'Printing', 20.00;     
EXEC Membership.pAddCredits 6, 'GuestPass', 5.00;    

EXEC Membership.pAddCredits 7, 'MeetingRoom', 40.00;  
EXEC Membership.pAddCredits 7, 'Catering', 50.00;    

EXEC Membership.pAddCredits 8, 'Printing', 50.00;     



EXEC Membership.pAddCredits 10, 'Catering', 200.00;  
EXEC Membership.pAddCredits 10, 'MeetingRoom', 100.00;
EXEC Membership.pAddCredits 10, 'Printing', 50.00;     

EXEC Membership.pAddCredits 11, 'MeetingRoom', 80.00; 
EXEC Membership.pAddCredits 11, 'GuestPass', 10.00;   

----Generating Monthly Invoices for Existing Members----
EXEC Billing.pGenerateMonthlyInvoices;

----Creating Ready Reservations----
EXEC Operations.pCreateReservation 1, 1, 'DESK', '2025-12-21 09:00:00', '2025-12-21 17:00:00';

EXEC Operations.pCreateReservation 3, 2, 'DESK', '2025-12-21 09:00:00', '2025-12-21 17:00:00';

EXEC Operations.pCreateReservation 4, 3, 'DESK', '2025-12-21 10:00:00', '2025-12-21 16:00:00';

EXEC Operations.pCreateReservation 7, 1, 'RESOURCE', '2025-12-22 10:00:00', '2025-12-22 12:00:00';

EXEC Operations.pCreateReservation 8, 3, 'RESOURCE', '2025-12-23 14:00:00', '2025-12-23 16:00:00';

EXEC Operations.pCreateReservation 10, 7, 'RESOURCE', '2025-12-31 18:00:00', '2025-12-31 23:59:00';

----Creating Done Transactions----
EXEC Billing.pPaymentTransaction 1, 150.00, 'Credit Card'; 
EXEC Billing.pPaymentTransaction 2, 150.00, 'PayPal';      
EXEC Billing.pPaymentTransaction 6, 300.00, 'Bank Transfer';
EXEC Billing.pPaymentTransaction