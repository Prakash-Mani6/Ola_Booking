-- create table 
create table ola_booking
(
Date Date, 
Time Time, 
Booking_ID varchar (20) primary key,
Booking_Status varchar (25),
Customer_ID varchar (25),
Vehicle_Type varchar (25),
Pickup_Location varchar (25),
Drop_Location varchar (25),
V_TAT varchar (25),
C_TAT varchar (25),
Canceled_Rides_by_Customer varchar (50),
Canceled_Rides_by_Driver varchar (40),
Incomplete_Rides varchar (25),
Incomplete_Rides_Reason varchar (25),
Booking_Value bigint ,
Payment_Method varchar (25),
Ride_Distance varchar (25),
Driver_Ratings varchar (25),
Customer_Rating varchar (25)

);