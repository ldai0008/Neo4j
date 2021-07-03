/*
  Name       :LU DAI
  Unitcode   :FIT5137
  Student Id :30759277
*/

//1 First, import data from userProfile, and create User, Cuisine,and PayMethod nodes, 
//and create edges between User and Cuisine, User and PayMethod.

load csv with headers from 'file:///userProfile.csv' as row
merge (u:User {userID: toInteger(row._id), 
latitude :toFloat(row.`location latitude`),
longitude :toFloat(row.`location longitude`),
birthYear: toInteger(row.`personalTraits birthYear`),
weight :toFloat(row.`personalTraits weight`),
height :toFloat(row.`personalTraits height`),
maritalStatus : coalesce (row.`personalTraits maritalStatus`, "Unknown"),
interest :row.`personality interest`,
typeOfWorker :row.`personality typeOfWorker`,
favColor :row.`personality favColor`,
drinkLevel :row.`personality drinkLevel`,
budget :coalesce (row.`preferences budget`,"Unknown"),
smoker : coalesce (toBoolean(row.`preferences smoker`),"Unknown"), 
dressPreference:coalesce (row.`preferences dressPreference`,"Unknown"),
ambience:coalesce (row.`preferences ambience`,"Unknown"),
transport:coalesce (row.`preferences transport`,"Unknown"),
religion:row.`otherDemographics religion`,
employment:coalesce (row.`otherDemographics employment`,"Unknown")})
with u, row
unwind coalesce (split (row.favCuisines,', '),"Unknown") as favCuisines
merge (c : Cuisine{name:favCuisines})
merge (u)-[ :favCuisine]->(c)
with u, row
unwind coalesce (split(row.favPaymentMethod,', '),"Unknown") as favPaymentMethod
merge (p:PayMethod{name:favPaymentMethod})
merge (u)-[ :favPayment]->(p)

//2 Second, import the place file, create edges between Place and Cuisine, Place and PayMethod.

load csv with headers from 'file:///places.csv' as row
merge (p:Place {placeID: toInteger(row._id),
name : row.placeName, 
latitude :toFloat(row.`location latitude`),
longitude :toFloat(row.`location longitude`),
street : row.`address street`,
city : row.`address city`,
state : row.`address state`,
country : row.`address country`,
alcohol : row.`placeFeatures alcohol`,
smoking_area :row.`placeFeatures smoking_area`,
dress_code :row.`placeFeatures dress_code`,
accessibility :row.`placeFeatures accessibility`,
price :row.`placeFeatures price`,
franchise : (case
	when row.`placeFeatures franchise`= 't' then toBoolean('TRUE')
	when row.`placeFeatures franchise`= 'f' then toBoolean('False')
	else null
	end),
area : row.`placeFeatures area`,
otherServices :row.`placeFeatures otherServices`,
parking : row.`parkingArragements`})
with p, row
unwind coalesce (split(row.acceptedPaymentModes,', '),"Unknown") as acceptedPaymentMethod
merge (m:PayMethod{name:acceptedPaymentMethod})
merge (p)-[ :acceptedPayment]->(m)
with p, row
unwind coalesce (split (row.cuisines,', '),"Unknown") as cuisine
merge (c : Cuisine{name : cuisine})
merge (p)-[ :support]->(c)


//3 Create edges between user and place.

load csv with headers from 'file:///user_ratings.csv' as row
with row where row.rating_id is not null
match (u:User {userID: toInteger(row.user_id)})
match (p:Place {placeID:toInteger(row.place_id)})
merge (u) - [:Rates{
rating_place : toInteger(row.rating_place),
rating_food : toInteger(row.rating_food),
rating_service : toInteger(row.rating_service)
}]->(p)


//4 Create node of open hours and the edge between Place and OpeningHours

load csv with headers from 'file:///openingHours.csv' as row
with row where row.placeID is not null
with distinct row as newRow
with distinct newRow.days as day, newRow
merge (o: OpeningDay {day:split(day, ';')})
with o, newRow
match (p:Place {placeID: toInteger(newRow.placeID)})
merge (p)-[:open {hours: newRow.hours}]->(o)