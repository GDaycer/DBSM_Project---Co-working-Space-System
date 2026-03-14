use CoworkingSpaceSystem
go

INSERT INTO Membership.Plans (plan_name, price_monthly, max_hours_meeting_room, description)
VALUES 
('Basic Access', 150.00, 5, 'Hot desking 9-5'),
('Premium Dedicated', 300.00, 20, '24/7 access, dedicated desk'),
('Corporate Suite', 500.00, 50, 'Private office access, unlimited coffee, 50h meeting room credit');


-- 2. Operations Areas
INSERT INTO Operations.Areas (area_name, max_capacity)
VALUES 
('Quiet Zone', 25), 
('Collab Hub', 40), 
('Private Suites', 10),
('Roof Garden', 20);



-- 3. Operations Resource Types
INSERT INTO Operations.ResourceTypes (type_name)
VALUES 
('Meeting Room'), 
('Phone Booth'), 
('Podcast Studio'),
('Event Hall');