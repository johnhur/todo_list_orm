require 'pry'
require 'pg'

HOSTNAME = :localhost
DATABASE = :testdb
#testing

class Todo
  attr_accessor :id, :task

  def self.create_todos_table
    c = PGconn.new(:host => HOSTNAME, :dbname => DATABASE)
    c.exec %q{
    CREATE TABLE todos (
      id SERIAL PRIMARY KEY,
      task TEXT
    );
    }
    c.close
  end

  def self.create(args)
    todo = Todo.new(args)
    todo.save
  end

  def self.all
    # TODO: get all 
    c = PGconn.new(:host => HOSTNAME, :dbname => DATABASE)
    results = []

    res = c.exec "SELECT * FROM todos order by id;"

    res.each do |todo|
      id = todo['id']
      task = todo['task']
      # puts "#{id}- #{task}"
      results << Todo.new({:id => id, :task => task})
    end
    c.close
    results
  end

  def initialize(args)
    connect

    if args.has_key? :id
      @id = args[:id]
    end

    if args.has_key? :task
      @task = args[:task]
    end
  end

  def save
    sql = "INSERT INTO todos (task"
    args = [task]

    if id.nil?
      sql += ") VALUES ($1)"
    else
      sql += ", id) VALUES ($1, $2)"
      args.push id
    end

    sql += ' RETURNING *;'

    res = @c.exec_params(sql, args)
    @id = res[0]['id']
    self
  end

  def delete
    # Write a method to delete the data from the database.  You should probably
    # also close the connection here after the query is complete.
    @c.exec_params("DELETE FROM todos WHERE id = $1;", [id])
    
  end

  def close
    @c.close
  end

  def to_s
    "#{@id}: #{@task}"
  end

  def update
    sql = "UPDATE todos set task = $1 where id = $2;"
    @c.exec_params(sql, [task, id])

  end


  private
    def connect
      @c = PGconn.new(:host => HOSTNAME, :dbname => DATABASE)
    end
end

#Todo.create_todos_table
# t = Todo.new(:id =>8, :task => "UPDATED TASK MOFO")
# t.update
# puts t.to_s

puts " 
Welcome to the todo app, what would you like to do?
n - make a new todo
l - list all todos 
u [id] - update a todo with a given id
d [id] - delete a todo with a given id, if no id is provided, all todos will be deleted
q - quit the application -->"
input = gets.chomp

until input == "q" do

  if input == "l" 
    puts Todo.all
    puts "What do you want to do now?"
    input = gets.chomp

  elsif input == "n" 
    puts "Enter new todo task"
    user_todo = gets.chomp
    t = Todo.new(:task => user_todo)
    t.save
    t.close
    puts "What do you want to do now?"
    input = gets.chomp

  elsif input == "u"  
    puts "What is the id of the task you want to update?"
    t_id = gets.chomp.to_i
    puts "Enter the new task you would like it to update to?"
    t_task = gets.chomp
    u = Todo.new({:id => t_id, :task => t_task})
    u.update
    puts "#{t_id} updated, what do you want to do now?"
    input = gets.chomp

  elsif input == "d"
    puts "What is the id of the task you want to delete?"
    d_id = gets.chomp.to_i
    d = Todo.new({:id => d_id})
    d.delete
    puts "#{d_id} deleted, what do you want to do now?"
    input = gets.chomp
  end

end


# puts Todo.all




# binding.pry
# puts todos
# e = todo.new({:rating => 6, :task => "TEST", :description => "A snowman name Olaf is comic relief"})
# e.save
# puts e
# e.delete
# e.close