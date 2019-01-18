require 'pg'

$conn = PG.connect(dbname: 'postgres')

def db_use(name)
  $conn = PG.connect dbname: name
  create_quizlist_table() 
rescue PG::ConnectionBad => e 
  puts "making #{name}"
  $conn.exec("create database #{name}")
  $conn = PG.connect dbname: name
  create_quizlist_table() 
end

=begin
questions json
ex: {"do you like chicken?" : {"yes" : 1, "no" : 0, "maybe" : -1}} 
the question is a key and the value contains another json with all answers being the keys and the values being the weights of the answers
the final result is the culmination of all the weights after all questions have been answered. 

results json
ex: {"-3, -1" : "Jasmine", "0, 1" : "Bella", "2, 3" : "Cinderalla"}
I'm not a fan of this. We take a range of values and check if the final result is within the ranges, inclusive, when it finds the range
it is in, return the value. I feel like this is slow. Look into int4range and arrays in postgres. The problem I see in the int4range or arrayis that we might need to create a seperate table of quiz answers, which means the amount of total possible answers will be predefined. I don't like that for long term, but then again, this is a capstone.
=end

def create_quizlist_table()
  $conn.exec("create table if not exists quizlist(id int primary key not null, title text not null, questions json not null, results json not null)")
end 

db_use("quizapp")
