--Leetcode Trips and users 

Create table  Trips (id int, client_id int, driver_id int, city_id int, status varchar(50), request_at varchar(50));
Create table Users (users_id int, banned varchar(50), role varchar(50));
Truncate table Trips;
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('1', '1', '10', '1', 'completed', '2013-10-01');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('2', '2', '11', '1', 'cancelled_by_driver', '2013-10-01');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('3', '3', '12', '6', 'completed', '2013-10-01');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('4', '4', '13', '6', 'cancelled_by_client', '2013-10-01');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('5', '1', '10', '1', 'completed', '2013-10-02');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('6', '2', '11', '6', 'completed', '2013-10-02');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('7', '3', '12', '6', 'completed', '2013-10-02');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('8', '2', '12', '12', 'completed', '2013-10-03');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('9', '3', '10', '12', 'completed', '2013-10-03');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('10', '4', '13', '12', 'cancelled_by_driver', '2013-10-03');
Truncate table Users;
insert into Users (users_id, banned, role) values ('1', 'No', 'client');
insert into Users (users_id, banned, role) values ('2', 'Yes', 'client');
insert into Users (users_id, banned, role) values ('3', 'No', 'client');
insert into Users (users_id, banned, role) values ('4', 'No', 'client');
insert into Users (users_id, banned, role) values ('10', 'No', 'driver');
insert into Users (users_id, banned, role) values ('11', 'No', 'driver');
insert into Users (users_id, banned, role) values ('12', 'No', 'driver');
insert into Users (users_id, banned, role) values ('13', 'No', 'driver');

select * from users;

select * from trips;

--client id and drive id will never be name as both are actually user id
with temp1 as (
    select t.client_id,t.driver_id,u.banned,
    case when u.banned = 'Yes' then 1 else 0 end as is_client_banned,
    t.request_at,t.status from trips t
    left join users u
    on t.client_id = u.users_id
),temp2 as (
    select t1.client_id,t1.driver_id,t1.is_client_banned,
    case when u.banned = 'Yes' then 1 else 0 end as is_driver_banned,
    t1.request_at,t1.status
    from temp1 t1
    left join users u
    on t1.driver_id = u.users_id
),temp3 as (
    select request_at,
    count(*) as total_ride_request,
    sum(case when is_client_banned = 0 and is_driver_banned = 0 then 0 else 1 end) as is_anyone_banned,
    sum(case when status like 'cancel%' and is_client_banned = 0 and is_driver_banned = 0 then 1 else 0 end) as is_ride_cancelled_by_unbanned_user
    from temp2
    group by request_at
    order by request_at
)
select t3.request_at,t3.total_ride_request,t3.is_anyone_banned,t3.is_ride_cancelled_by_unbanned_user,
t3.total_ride_request - t3.is_anyone_banned  as total_ride_request_by_unbanned_users,
case when t3.is_ride_cancelled_by_unbanned_user = 0 then 0 else
round(t3.is_ride_cancelled_by_unbanned_user/(t3.total_ride_request - t3.is_anyone_banned),2) end as "Cancellation Rate"
from temp3 t3
where t3.request_at between '2013-10-01' and '2013-10-03'
and (t3.total_ride_request - t3.is_anyone_banned) <> 0
;


----XXX Leetcode doesn't allow huge column name so below sql query is with shorter column name which is accepted by leetcode
with temp1 as (
    select t.client_id,t.driver_id,u.banned,
    case when u.banned = 'Yes' then 1 else 0 end as is_client_banned,
    t.request_at,t.status from trips t
    left join users u
    on t.client_id = u.users_id
),temp2 as (
    select t1.client_id,t1.driver_id,t1.is_client_banned,
    case when u.banned = 'Yes' then 1 else 0 end as is_driver_banned,
    t1.request_at,t1.status
    from temp1 t1
    left join users u
    on t1.driver_id = u.users_id
), temp3 as (
    select request_at,
    count(*) as total_ride_request,
    sum(case when is_client_banned = 0 and is_driver_banned = 0 then 0 else 1 end) as is_anyone_banned,
    sum(case when status like 'cancel%' and is_client_banned = 0 and is_driver_banned = 0 then 1 else 0 end) as unban_ride_cancel
    from temp2
    group by request_at
    order by request_at
)
select t3.request_at as Day,
case when t3.unban_ride_cancel = 0 then 0 else
round(t3.unban_ride_cancel/(t3.total_ride_request - t3.is_anyone_banned),2) end as "Cancellation Rate"
from temp3 t3
where t3.request_at between '2013-10-01' and '2013-10-03'
and (t3.total_ride_request - t3.is_anyone_banned) <> 0; --if only one entry is present in which user is banned and status is cancelled , query should return nothing

--Optimized Code
select t.request_at,
--sum(case when t.status like 'cancel%' then 1 else 0 end) as cancelled_trip,
--count(*) as total_trips,
round(sum(case when t.status like 'cancel%' then 1 else 0 end)/count(*),2) as "Cancellation Rate"
from trips t
inner join users c
on t.client_id = c.users_id
inner join users d
on t.driver_id = d.users_id
where c.banned='No' and d.banned='No' and 
t.request_at between '2013-10-01' and '2013-10-03'
group by t.request_at;

---exception case for the commented query
{"headers": {"Trips": 
	[			"id", "client_id", "driver_id", "city_id", "status", 				"request_at"], 
	{"Trips": [["1", 	"1", 		"10", 		"1", 		"cancelled_by_client", "2013-10-04"]]
	
	"Users": ["users_id", "banned", "role"]},
	{"Users": [["1", "No", "client"], 
			["10", "No", "driver"]]}}

---another solution
with temp1 as
(select c.request_at,c.client_id,c.driver_id,c.status,u1.banned as client_banned, u2.banned as driver_banned ,
case when c.status like 'cancelled%' then 1 else 0 end cancelled
from trips c
inner join users u1
on c.client_id = u1.users_id
inner join users u2
on c.driver_id = u2.users_id
where u1.banned = 'No' and u2.banned = 'No'
)
select request_at as Day,round(sum(cancelled)/count(1),2) as "Cancellation Rate"  from temp1
where request_at between '2013-10-01' and '2013-10-03'
group by request_at
order by request_at
;



