/*
  Name       :LU DAI
  Unitcode   :FIT5137
  
*/

//1. MonR has gained some new information about a trendy new place. Therefore, insert all of the information provided in Table 1.
//First, create the Place and the relationship between cuisine and payment

load csv with headers from 'file:///places.csv' as row
merge (p:Place {placeID: toInteger(70000),
name : "Taco Jacks", 
street : "Carretera Central Sn",
city : "San Luis Potosi",
state : "SLP",
country : "Mexico",
alcohol : "No_Alcohol_Served",
smoking_area :"not permitted",
dress_code :"informal",
accessibility :"completely",
price :"medium",
franchise :  toBoolean('TRUE'),
area : "open",
otherServices :"Internet",
parking : "none"})
with p, row
merge (m:PayMethod{name:"any"})
merge (p)-[ :acceptedPayment]->(m)
with p, row
merge (c : Cuisine{name : "Mexican"})
merge (p)-[ :support]->(c)
with p, row
merge (b : Cuisine{name : "Burgers"})
merge (p)-[ :support]->(b)
with p,row
merge (o: OpeningDay {day:["Mon","Tue","Wed","Thu","Fri",""]})
with o, p,row
merge (p)-[:open {hours: "09:00-20:00"}]->(o)
with p,row
merge (y: OpeningDay {day:["Sat",""]})
with y, p,row
merge (p)-[:open {hours: "12:00-18:00"}]->(y)
with p,row
merge (z: OpeningDay {day:["Sun",""]})
with z, p,row
merge (p)-[:open {hours: "12:00-18:00"}]->(z)

//2.They have also realised that the user with user_id 1108, no longer prefers Fast_Food and also prefers to pay using debit_cards instead of cash. You are required to update user 1108’s favorite cuisines and favorite payment methods.

MATCH (u:User {userID: 1108})
MATCH (u)-[r:favCuisine]-(c:Cuisine{name:"Fast_Food"})
DELETE r；


MATCH (u:User {userID: 1108})
MATCH (u)-[r:favPayment]->(p:PayMethod{name:"cash"})
DELETE r；

MATCH (u:User {userID: 1108})
merge (u)-[r:favPayment]->(p:PayMethod{name:"bank_debit_cards"})
return u, r, p；



//3.The management has realised that the user with user_id 1063 was an error. Therefore delete the user 1063 from the database.
MATCH (u:User {userID: 1063})
detach delete u；
