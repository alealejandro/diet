require 'sqlite3'

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

def create_food(category, sub_category, name, style, serving_size, calories, protein, fat, carbs)
  DB.execute("INSERT INTO foods (category, sub_category, name, style, serving_size, calories, protein, fat, carbs) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)", [category, sub_category, name, style, serving_size, calories, protein, fat, carbs])
end

# Enter new food item into database
def enter_food
	done = false
	until done
		puts
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
		create_food(category, sub_category, name, style, serving_size, calories, protein, fat, carbs)
	end
end

# Displays names of all foods in foods db
def display_foods
	foods_names = DB.execute("SELECT name FROM foods")
	puts 
	puts "Foods".center(40, '-')
	foods_names.each do |food_name|
		puts "#{food_name[0]}"
	end
	puts "-".center(40, '-')
end

# Check if food name exists in foods table
def exists_check(food_name)
	DB.execute("SELECT 1 FROM foods WHERE name = ?", [food_name]).length > 0
end

# Enter what you ate that day (food name, servings)
def ask_diet
	done = false
	total_nutrition_array = []

	until done
		display_foods
		puts "\nWhat did you eat today? Type 'done' to exit"
		print "\n> "
		food_item = gets.chomp.downcase

		if food_item == "done"
			done = true
			break
		elsif exists_check(food_item)
			print "\nServings? "
			servings = gets.chomp.to_i
			nutrition = DB.execute("SELECT calories, protein, fat, carbs FROM foods WHERE name = ?", [food_item])
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
	total_nutrition_array
end

def calc_total(ar)
	j = 0 
	# nutritional value (NV) 
	new_ar = []
	while j < 4
		i = 0
		# food item 
		new_ar[j] = 0
		while i < ar.length
			new_ar[j] += ar[i][j] 
			# add NV for all food items
			i += 1
		end
		# Repeat summation for all NVs
		j += 1
	end
	new_ar
end

# Ingested food vs. daily goals
def calc_diff(ingested_ar, goals_ar)
	difference_nutrition = []
	i = 0
	while i < ingested_ar.length
		difference_nutrition << goals_ar[i] - ingested_ar[i]
		i += 1
	end
	difference_nutrition
end

##### Driver code #####

DB = SQLite3::Database.new("diet.db")
DB.execute(create_table_cmd)

enter_food

# Set daily goals (cal, pro, fat, carbs)
daily_nutrition_goals = [2400, 180, 80, 240]
total_nutrition = calc_total(ask_diet)
calculated_difference = calc_diff(total_nutrition, daily_nutrition_goals)

puts "                            [Cal, Protein, Fat, Carbs]"
puts "Total nutrition of the day: #{total_nutrition}"
puts "Daily nutrition goals:      #{daily_nutrition_goals}"
puts "Difference:                 #{calculated_difference}"

# Extra features:

	# RECOMMENDATIONS
		# If under goal, show how much under & recommend food items that will reach goal
		# If over goal, show how much over & recommend what to cut out based on that day's diet for the next day

	# Export to excel file?

	# Each food item ingested as a % of daily goals?

	# Machine learning photo recognition
		# Or if at restaurant, contact restaurant for nutritional values