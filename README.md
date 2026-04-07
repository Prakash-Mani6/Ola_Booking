# Ola Booking Data Analysis Project

## Project Overview

The Ola Booking Data Analysis project aims to analyze ride-sharing data to understand customer behavior, ride patterns, service performance, and driver efficiency. This project uses a PostgreSQL database to perform various SQL queries to uncover key insights and answer specific business questions related to customer behavior, ride efficiency, service performance, and driver quality.

## Objectives

The main objectives of this project are:
- To analyze the ride-sharing data for different booking patterns.
- To identify the peak hours, most popular vehicle types, and repeat customers.
- To examine the impact of payment methods and discounts on total booking values.
- To analyze ride cancellations and incomplete rides to understand reasons and patterns.
- To compute performance metrics such as ride completion rates, average ride distance, and driver performance.
- To generate reports to aid business decision-making processes for improving service efficiency.

## Database Setup

This project utilizes a PostgreSQL database with the following table structure for `ola_booking`:

### `ola_booking` Table Schema
| Column Name                | Data Type     |
|----------------------------|---------------|
| Date                        | DATE          |
| Time                        | TIME          |
| Booking_ID                  | VARCHAR(20)   |
| Booking_Status              | VARCHAR(25)   |
| Customer_ID                 | VARCHAR(25)   |
| Vehicle_Type                | VARCHAR(25)   |
| Pickup_Location             | VARCHAR(25)   |
| Drop_Location               | VARCHAR(25)   |
| V_TAT                       | VARCHAR(25)   |
| C_TAT                       | VARCHAR(25)   |
| Canceled_Rides_by_Customer  | VARCHAR(50)   |
| Canceled_Rides_by_Driver    | VARCHAR(40)   |
| Incomplete_Rides            | VARCHAR(25)   |
| Incomplete_Rides_Reason     | VARCHAR(25)   |
| Booking_Value               | BIGINT        |
| Payment_Method              | VARCHAR(25)   |
| Ride_Distance               | VARCHAR(25)   |
| Driver_Ratings              | VARCHAR(25)   |
| Customer_Rating             | VARCHAR(25)   |

## Data Base setup 
```sql
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
```


### Solve Business Problem:
**Customer Behavior & Ride Patterns**
1.**Identify the top 3 peak booking hours based on ride volume.**
```sql
SELECT 
    EXTRACT(HOUR FROM Time) AS booking_hour, 
    COUNT(Booking_ID) AS total_bookings
FROM ola_booking
GROUP BY booking_hour
ORDER BY total_bookings DESC
LIMIT 3;
```

2.**Find the most common vehicle type booked by frequent customers.**
```sql
select count(booking_id)as total_booking ,vehicle_type from ola_booking
group by vehicle_type 
order by total_booking desc
limit 1
```

3.**Determine the percentage of repeat customers in the dataset.**
```sql
WITH customer_booking_count AS (
    SELECT 
        Customer_ID, 
        COUNT(Booking_ID) AS total_bookings
    FROM ola_booking
    GROUP BY Customer_ID
)
SELECT 
    (COUNT(CASE WHEN total_bookings > 1 THEN Customer_ID END) * 100.0 / COUNT(*)) AS repeat_customer_percentage
FROM customer_booking_count;

```
4.**Rank payment methods by their total booking value contribution.**
```sql
SELECT 
    Payment_Method, 
    SUM(Booking_Value) AS total_booking_value,
    RANK() OVER (ORDER BY SUM(Booking_Value) DESC) AS ranking
FROM ola_booking
GROUP BY Payment_Method
ORDER BY total_booking_value DESC;
```
5.**Calculate the average customer rating for each vehicle type in different cities.**
```sql
SELECT 
    AVG(CAST(NULLIF(Customer_Rating, 'null') AS FLOAT)) AS customer_avg_rating, 
    Vehicle_Type, 
    Pickup_Location
FROM ola_booking
WHERE Customer_Rating IS NOT NULL
GROUP BY Vehicle_Type, Pickup_Location
ORDER BY Pickup_Location, customer_avg_rating DESC;
```
**Ride Efficiency & Service Performance**
6.**Find the top 3 reasons for ride cancellations by customers and drivers.**
```sql
SELECT 
    Incomplete_Rides_Reason, 
    COUNT(*) AS cancellation_count
FROM ola_booking
WHERE Incomplete_Rides_Reason IS NOT NULL
GROUP BY Incomplete_Rides_Reason
ORDER BY cancellation_count DESC
LIMIT 3;
```
7.**Compute the ride completion rate for each city.**
```sql
SELECT 
    Pickup_Location AS City,
    COUNT(CASE WHEN Booking_Status = 'Completed' THEN Booking_ID END) * 100.0 / COUNT(Booking_ID) AS completion_rate
FROM ola_booking
GROUP BY Pickup_Location
ORDER BY completion_rate DESC;
```

8.**Identify the most in-demand vehicle type in each city during peak hours.**
```sql
WITH peak_hours AS (
    SELECT EXTRACT(HOUR FROM Time) AS booking_hour
    FROM ola_booking
    GROUP BY EXTRACT(HOUR FROM Time)
    ORDER BY COUNT(Booking_ID) DESC
    LIMIT 3  -- Adjust if you want more peak hours
)
SELECT 
    Pickup_Location AS City, 
    Vehicle_Type, 
    COUNT(Booking_ID) AS total_bookings
FROM ola_booking
WHERE EXTRACT(HOUR FROM Time) IN (SELECT booking_hour FROM peak_hours)
GROUP BY Pickup_Location, Vehicle_Type
ORDER BY City, total_bookings DESC;
```
9.**Determine the average ride distance for each vehicle type.**
```sql
SELECT 
    Vehicle_Type, 
    AVG(CAST(Ride_Distance AS FLOAT)) AS Avg_ride_distance_km
FROM ola_booking 
WHERE Ride_Distance IS NOT NULL
GROUP BY Vehicle_Type
ORDER BY Avg_ride_distance_km DESC;
```
**10.Compare the average V_TAT and C_TAT across different cities.**
```sql
SELECT 
    Pickup_Location, 
    AVG(CAST(NULLIF(V_TAT, 'null') AS FLOAT)) AS avg_V_TAT, 
    AVG(CAST(NULLIF(C_TAT, 'null') AS FLOAT)) AS avg_C_TAT
FROM ola_booking
WHERE V_TAT IS NOT NULL AND C_TAT IS NOT NULL
GROUP BY Pickup_Location
ORDER BY Pickup_Location;
```
**Driver Performance & Service Quality**
12.**Find the pickup locations with the highest ride cancellation rate.**
```sql
SELECT 
    Pickup_Location, 
    COUNT(CASE WHEN Booking_Status = 'Cancelled' THEN Booking_ID END) * 100.0 / COUNT(Booking_ID) AS cancellation_rate
FROM ola_booking
GROUP BY Pickup_Location
ORDER BY cancellation_rate DESC
LIMIT 10;
```

13.**Analyze the impact of discounts on the total number of bookings.**
```sql
SELECT 
    CASE 
        WHEN Discount_Applied > 0 THEN 'Discounted Rides' 
        ELSE 'Non-Discounted Rides' 
    END AS Discount_Category, 
    COUNT(Booking_ID) AS total_bookings
FROM ola_booking
GROUP BY Discount_Category;
```

14.**Determine the city with the highest total revenue from bookings.**
```sql
select sum(booking_value) as highest_total_revenue, Pickup_Location
from ola_booking
group by Pickup_Location
order by highest_total_revenue desc
limit 1
```

15.**Identify the top 5 locations with the most canceled rides and suggest improvements.**
```sql
SELECT 
    Pickup_Location, 
    COUNT(Booking_ID) AS total_canceled_rides
FROM ola_booking
WHERE Booking_Status = 'Cancelled'
GROUP BY Pickup_Location
ORDER BY total_canceled_rides DESC
LIMIT 5;
```
## Findings

Through the analysis, the following findings were uncovered:
1. **Peak Booking Hours**: The top 3 peak hours for bookings were identified, helping to understand when the most rides are requested.
2. **Common Vehicle Type**: The most common vehicle types were identified based on frequent customer bookings, providing insights into customer preferences.
3. **Repeat Customer Percentage**: The percentage of repeat customers was calculated to understand customer loyalty.
4. **Revenue Contributions by Payment Methods**: The ranking of payment methods based on their contribution to total revenue helps understand which methods are preferred by customers.
5. **Ride Completion Rates**: Completion rates for different cities were computed, revealing areas with higher cancellation or incomplete ride rates.
6. **Cancellation and Incomplete Ride Reasons**: The most common reasons for cancellations and incomplete rides were identified, aiding in the improvement of customer satisfaction.

## Reports

The project generated several analytical reports that include:
- **Peak Booking Hour Analysis**: Insights into the busiest hours for ride-sharing services.
- **Vehicle Preference by Customer**: Identification of the most frequently used vehicle types and popular locations.
- **Cancellation Analysis**: Identifying reasons behind ride cancellations and the most canceled locations.
- **Revenue Analysis**: Total revenue by city, highlighting the most profitable locations.
- **Driver and Customer Rating**: Performance metrics on driver ratings and customer ratings across various vehicle types.

## Conclusion

This project provides actionable insights that can be used to improve ride-sharing operations:
- **Improve Customer Satisfaction**: By addressing the reasons for ride cancellations and incomplete rides, customer experience can be improved.
- **Optimize Resources**: Knowing peak booking hours helps in optimizing vehicle allocation.
- **Focus on High Revenue Locations**: Identifying cities with the highest revenue potential can aid in better resource management and targeted marketing.
- **Enhance Driver Performance**: By monitoring driver ratings, service quality can be maintained and improved.

This analysis is essential for Ola to optimize their ride-sharing services, increase customer satisfaction, and drive overall revenue growth.



### Built With
- **PostgreSQL**: Database used for querying and analysis.
- **SQL**: Language used to write the queries and perform the data analysis.


