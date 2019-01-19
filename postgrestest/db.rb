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
=end

def create_quizlist_table()
  #create basic quizlist table
  $conn.exec("create table if not exists quizlist(id int primary key not null, title text not null, questions json not null)")
  #create first quiz answer table
  $conn.exec(createQuizAns(1))
  #prepare statements, inserquiz is to insert a new quiz into quizlist. insertans is to insert new answers into quizans#{id}
  $conn.prepare('insertquiz', 'insert into quizlist (id, title, questions) values ($1, $2, $3)')
  $conn.prepare('insertans', insertQuizAns(1))
  
  #create the first quiz
  $conn.exec_prepared('insertquiz', [1,'Which disney princess are you?', '{"Do you like to fight?": {"yes" : 1, "no" : 0 }}'])
  $conn.exec_prepared('insertans', [[1,1], "Mulan"])
  $conn.exec_prepared('insertans', [[0,0], "Bella"])
end 

def insertQuizAns(id)
  temp = "insert into quizans#{id} (search, result) values ($1, $2)"
  puts temp
  return temp
end

def createQuizAns(id)
  temp = "create table if not exists quizans#{id}(search int4range, result text)"
  puts temp
  return temp
end

db_use("quizapp")
