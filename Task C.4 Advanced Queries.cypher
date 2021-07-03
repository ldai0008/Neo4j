/*
  Name       :LU DAI
  Unitcode   :FIT5137
  Student Id :30759277
*/

match (u1:User{userID:1001})-[r1]->(p1:Place)
with avg(r1.rating_food) as u1_food_mean,
avg(r1.rating_place) as u1_place_mean,
avg(r1.rating_service) as u1_service_mean
match (u2:User)-[r]->(p2:Place)
with p2.placeID as place_id,
avg(r.rating_food) as u2_food_mean,
avg(r.rating_place) as u2_place_mean,
avg(r.rating_service) as u2_service_mean,
u1_food_mean,u1_place_mean,u1_service_mean
match (u1:User{userID:1001})-[r1]->(p1:Place)
where place_id <> p1.placeID
return distinct sqrt(
    (u2_food_mean - u1_food_mean) * (u2_food_mean - u1_food_mean) + 
    (u2_place_mean - u1_place_mean) * (u2_place_mean - u1_place_mean) +
    (u2_service_mean - u1_service_mean) * (u2_service_mean - u1_service_mean)) as distance, place_id
    order by distance
    limit 3；
