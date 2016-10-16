require 'sqlite3'

db = SQLite3::Database.new("diet.db")

create_table_cmd = <<-SQL
  CREATE TABLE IF NOT EXISTS foods(
    id INTEGER PRIMARY KEY,
    category VARCHAR(255),
    sub_category VARCHAR(255),
    name VARCHAR(255),
    style VARCHAR(255),
    serving_size VARCHAR(255),
    calories INT,
    protein REAL,
    fat REAL,
    carbs REAL
  )
SQL
# serving size allow grams, cups, scoops

db.execute(create_table_cmd)

def create_food(db, category, sub_category, name, style, serving_size, calories, protein, fat, carbs)
  db.execute("INSERT INTO foods (category, sub_category, name, style, serving_size, calories, protein, fat, carbs) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)", [category, sub_category, name, style, serving_size, calories, protein, fat, carbs])
end

# create_food(db, "Protein", "White Poultry", "Chicken Breast", "Boneless, Skinless", "100 grams", 165, 31.00, 3.60, 0.00)

# Enter foods into database
# Just do gets.chomp once but split by semicolons, store into array, then iterate through array into db
def enter_food(db)
	done = false
	until done
		puts "Would you like to add a food item to the foods database? (y/n)"
		print "\n> "
		response = gets.chomp
		if response == "n"
			done = true
			break
		else
			print "Food category: "
			category = gets.chomp.downcase
			print "Food sub-category: "
			sub_category = gets.chomp.downcase
			print "Food name: "
			name = gets.chomp.downcase
			print "Food style: "
			style = gets.chomp.downcase
			print "Serving size: "
			serving_size = gets.chomp.downcase
			print "Calories: "
			calories = gets.chomp.to_i
			print "Protein: "
			protein = gets.chomp.to_f
			print "Fat: "
			fat = gets.chomp.to_f
			print "Carbs: "
			carbs = gets.chomp.to_f
		end
		create_food(db, category, sub_category, name, style, serving_size, calories, protein, fat, carbs)
	end
end

enter_food(db)

# Set daily goals (cal, pro, fat, carbs)
daily_nutrition_goals = [2400, 180, 80, 240]

# Check if food name exists in foods table
def exists_check(db, food_name)
	db.execute("SELECT 1 FROM foods WHERE name = ?", [food_name]).length > 0
end

# Enter what you ate (food name, servings)
done = false
total_nutrition_array = []

until done
	puts "\nWhat did you eat today (food name)? Type 'done' to exit"
	print "\n> "
	food_item = gets.chomp.downcase
	if food_item == "done"
		done = true
		break
	elsif exists_check(db, food_item)
		print "\nHow many servings? "
		servings = gets.chomp.to_i
		nutrition = db.execute("SELECT calories, protein, fat, carbs FROM foods WHERE name = ?", [food_item])
		food_value_by_servings = []
		nutrition.each do |food|
			food.each do |nutrition_value|
				food_value_by_servings << nutrition_value * servings
			end
			# print "#{food_value_by_servings}\n" # debugging for checking correct calc.
		end
		# put the food nutrition into total_nutrition_array
		total_nutrition_array << food_value_by_servings
	else
		puts "Sorry, that item does not exist in the database."
	end
end

# Calculate total ingested nutrition from total_nutrition_array
total_nutrition = []
i = 0
if total_nutrition_array.length > 1 # for all food items,
	while i < total_nutrition_array.length - 1 # add this many times, takes care of edge case
		j = 0
		total_nutrition_array[i].each do |nutritional_value|
			# for each nutritional value in the food, add with corresponding value in next food
			total_nutrition << nutritional_value + total_nutrition_array[i+1][j]
			j += 1
		end
		i += 1
	end
else
	total_nutrition = total_nutrition_array[i]
end
print total_nutrition

difference_nutrition = []
i = 0
while i < total_nutrition.length
	difference_nutrition << daily_nutrition_goals[i] - total_nutrition[i]
	i += 1
end
puts "                            [Cal, Protein, Fat, Carbs]"
puts "Total nutrition of the day: #{total_nutrition}"
puts "Daily nutrition goals:      #{daily_nutrition_goals}"
puts "Difference:                 #{difference_nutrition}"

# If under goal, show how much under & recommend food items that will reach goal
# If over goal, show how much over & recommend what to cut out based on that day's diet for the next day

# Export to excel file?

# Machine learning photos
# Or if at restaurant, contact restaurant for nutritional values