/*
  Name       :LU DAI
  Unitcode   :FIT5137
  Student Id :30759277
*/

//1. How many reviews does “Chilis Cuernavaca” have?
match (u:User)-[r]->(p:Place{name: "Chilis Cuernavaca"})
return count(r)


//2. Show all place, cuisines, and service ratings for restaurants in “Morelos” state.
create index on:Place (state);

match (u:User)-[r]->(p:Place{state:"Morelos"})-[r2]->(c:Cuisine)
using index p:Place(state)
return p.name as place,c.name as cuisine,r.rating_place as place_rating,
r.rating_food as food_rating,r.rating_service as service_rating



//3. Can you recommend places that user 1003 has never been but user 1033 have been and gave ratings above 1?

match (u:User{userID:1033})-[r]->(p:Place)
where r.rating_place > 1
and r.rating_food > 1
and r.rating_service > 1
and not exists ((u:User{userID:1003})-->(p:Place))
return p

//4. List all restaurant names and locations that do not provide Mexican cuisines.
match (p:Place)-[r]->(c:Cuisine)
where c.name <>'Mexican'
return p.name as Place_name,
(case
when p.street = "?" then ""
else p.street + " " end) + 
(case
when p.state = "?" then ""
else p.state + " " end) + p.country as Place_location



//5. Count how many times each user provides ratings.
match (u:User)-->(p:Place)
return u.userID as UserID, count(p) as Number_of_rating

//6. Display a list of pairs of restaurants having more than three features in common.
match(p1:Place)
match(p2:Place)
where p1<>p2
with 0 as number,p1,p2
with number+
(case 
    when p1.alcohol = p2.alcohol then 1 else 0
    end ) + 
(case 
    when p1.smoking_area = p2.smoking_area then 1 else 0
    end ) + 
(case 
    when p1.dress_code = p2.dress_code then 1 else 0
    end )+ 
(case 
    when p1.accessibility = p2.accessibility then 1 else 0
    end )+ 
(case 
    when p1.price = p2.peice then 1 else 0
    end )+ 
(case 
    when p1.franchise = p2.franchise then 1 else 0
    end )+ 
(case 
    when p1.area = p2.area then 1 else 0
    end )+ 
(case 
    when p1.otherServices = p2.otherServices then 1 else 0
    end ) as number,p1,p2
where number > 3
return p1,p2


//7. Display International restaurants that are open on Sunday.

match (p:Place)-->(o:OpeningDay)
where 'Sun' in o.day
with p
match (p:Place)-->(c:Cuisine{name:'International'})
return p.name as Place_name


//8. What is the average food rating for restaurants in Victoria city?

match (u:User) -[r]->(p:Place)
where toUpper(p.city) = 'VICTORIA'
RETURN  avg(r.rating_food)

//9. What are the top 3 most popular cities based on the total average service ratings?

match (u:User) -[r]->(p:Place)
RETURN p.city, avg(r.rating_food) as Avg_food_rating
order by Avg_food_rating desc
limit 3

//10. For each place, rank other places that are close to each other by their locations. You will need to use the longitude and latitude to calculate the distance between places.
create index point_index for (n:Place) on (n.latitude, n.longitude);
match(p1:Place)
match(p2:Place)
where p1.placeID <> p2.placeID
with distance(
    Point({longitude:p1.longitude, latitude:p1.latitude}),
    Point({longitude:p2.longitude, latitude:p2.latitude})
) as distance, p1,p2
return p1.name, p2.name, distance
order by p1.name,distance
