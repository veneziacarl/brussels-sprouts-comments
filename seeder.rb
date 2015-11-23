require 'pg'
require 'faker'


def db_connection
  begin
    connection = PG.connect(dbname: "brussels_sprouts_recipes")
    yield(connection)
  ensure
    connection.close
  end
end


TITLES = ["Roasted Brussels Sprouts",
  "Fresh Brussels Sprouts Soup",
  "Brussels Sprouts with Toasted Breadcrumbs, Parmesan, and Lemon",
  "Cheesy Maple Roasted Brussels Sprouts and Broccoli with Dried Cherries",
  "Hot Cheesy Roasted Brussels Sprout Dip",
  "Pomegranate Roasted Brussels Sprouts with Red Grapes and Farro",
  "Roasted Brussels Sprout and Red Potato Salad",
  "Smoky Buttered Brussels Sprouts",
  "Sweet and Spicy Roasted Brussels Sprouts",
  "Smoky Buttered Brussels Sprouts",
  "Brussels Sprouts and Egg Salad with Hazelnuts"]

#WRITE CODE TO SEED YOUR DATABASE AND TABLES HERE


db_connection do |conn|
  conn.exec('DROP TABLE IF EXISTS recipes')
  conn.exec('DROP TABLE IF EXISTS comments')
  conn.exec("CREATE TABLE recipes (id SERIAL PRIMARY KEY, title varchar(100))")
  conn.exec("CREATE TABLE comments (id SERIAL PRIMARY KEY, text varchar(255), recipe_id int)")

  TITLES.each do |t|
    conn.exec_params("INSERT INTO recipes (title) VALUES ($1)", [t]);
  end

  @recipes = conn.exec("SELECT recipes.title FROM recipes")

  conn.exec_params("INSERT INTO comments (text, recipe_id) VALUES ($1, $2)", [Faker::Lorem.sentence, 1])
  conn.exec_params("INSERT INTO comments (text, recipe_id) VALUES ($1, $2)", [Faker::Lorem.sentence, 1])
  conn.exec_params("INSERT INTO comments (text, recipe_id) VALUES ($1, $2)", [Faker::Lorem.sentence, 2])
  conn.exec_params("INSERT INTO comments (text, recipe_id) VALUES ($1, $2)", [Faker::Lorem.sentence, 5])

  @comments = conn.exec("SELECT comments.text FROM comments")


end

@recipes.each do |r|
  puts r['title']
end

# How many recipes are there in total?
puts "There are #{@recipes.to_a.length} recipes in total."

# How many comments are there in total?
puts "There are #{@comments.to_a.length} comments in total."

# How would you find out how many comments each of the recipes have?
db_connection do |conn|
  @recipes.each do |r|
    comment_count = conn.exec_params('SELECT count(*) FROM comments JOIN recipes ON comments.recipe_id = recipes.id WHERE recipes.title = ($1)', [r['title']])
    puts "#{r['title']} has #{comment_count[0]['count']} comment(s)."
  end
end

# What is the name of the recipe that is associated with a specific comment?
db_connection do |conn|
  cool_comment = 'testing for this super cool comment'
  conn.exec_params("INSERT INTO comments (text, recipe_id) VALUES ($1, $2)", [cool_comment, 8])
  found_recipe_title = conn.exec_params('SELECT recipes.title FROM comments JOIN recipes ON comments.recipe_id = recipes.id WHERE comments.text = ($1)', [cool_comment])
  puts "#{found_recipe_title[0]['title']} is the recipe that has that cool comment."
end

# Add a new recipe titled Brussels Sprouts with Goat Cheese. Add two comments to it.
db_connection do |conn|
  comment_one = 'this is the first unimaginative comment'
  comment_two = 'this is the second unimaginative comment'
  new_recipe = 'Brussels Sprouts with Goat Cheese'

  conn.exec_params("INSERT INTO recipes (title) VALUES ($1)", [new_recipe])
  conn.exec_params("INSERT INTO comments (text, recipe_id) VALUES ($1, $2)", [comment_one, 12])
  conn.exec_params("INSERT INTO comments (text, recipe_id) VALUES ($1, $2)", [comment_two, 12])

  verifying_new_recipe_add = conn.exec_params('SELECT recipes.title FROM comments JOIN recipes ON comments.recipe_id = recipes.id WHERE comments.text = ($1) OR comments.text = ($2)', [comment_one, comment_two])
  puts "Succesfully added #{verifying_new_recipe_add[0]['title']} recipe and comments!"
end
