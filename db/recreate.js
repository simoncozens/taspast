db.people.drop()
db.people.createIndex({"NAME_FULL_DISPLAY":1, "birth_year":1})
db.people.createIndex({"NAME_FULL_DISPLAY":1})
