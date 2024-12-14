import pandas as pd
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.preprocessing import StandardScaler

# Load dataset
data_path = 'food.csv'
df = pd.read_csv(data_path)

# Check for null values
if df.isnull().sum().any():
    print("Dataset contains null values. Please clean the data.")
    exit()

# Set 'Food Items' as the index
df.set_index('Food Items', inplace=True)

# Separate out the 'Ingredients' column for final display
ingredients_column = df['Ingredients']
df = df.drop(columns=['Ingredients'])

# Normalize the data (important for cosine similarity)
df_normalized = df.apply(lambda x: (x - x.mean()) / x.std(), axis=0)

# Separate data into meal categories
meal_categories = ['Breakfast', 'Lunch', 'Dinner', 'Snack' , 'Side Dish']
meals = {meal: df[df[meal] == 1].drop(columns=meal_categories).copy() for meal in meal_categories}

# Normalize each meal category
df_normalized_meals = {
    meal: data.apply(lambda x: (x - x.mean()) / x.std(), axis=0) for meal, data in meals.items()
}

# Recommendation function
def recommend_food_items_based_on_preference(user_preferences, meal_type, num_recommendations=3):
    data = meals[meal_type]
    data_normalized = df_normalized_meals[meal_type]
    
    user_data = pd.DataFrame(user_preferences, index=[0])
    user_data_normalized = (user_data - data.mean()) / data.std()
    
    # Compute cosine similarity between user preferences and food items
    user_sim_scores = cosine_similarity(user_data_normalized, data_normalized)
    
    # Get similarity scores for the user preferences
    sim_scores = user_sim_scores.flatten()
    
    # Create a DataFrame of food items with their similarity scores to the user's preferences
    food_sim_df = pd.DataFrame({
        'Food Items': data.index,
        'Similarity': sim_scores
    })
    
    # Add the Ingredients column back for display
    food_sim_df['Ingredients'] = ingredients_column.loc[food_sim_df['Food Items']].values
    
    # Sort food items based on similarity in descending order
    food_sim_df = food_sim_df.sort_values(by='Similarity', ascending=False)
    
    # Recommend the top `num_recommendations` food items
    return food_sim_df.head(num_recommendations)

# Example user_preferences dictionary
user_preferences = {
    'Calories': [200],
    'Fats': [5],
    'Proteins': [15],
    'Carbohydrates': [30],
}

# User interaction and nutrient tracking
total_nutrients = {'Calories': 0, 'Fats': 0, 'Proteins': 0, 'Carbohydrates': 0}
selected_dishes = {}

for meal_type in meal_categories:
    print(f"\nRecommendations for {meal_type}:")
    recommended_foods = recommend_food_items_based_on_preference(user_preferences, meal_type, num_recommendations=3)
    print(recommended_foods[['Food Items', 'Similarity', 'Ingredients']])
    
    # Ask user to select one dish
    dish = input(f"Select one dish from the above recommendations for {meal_type}: ")
    while dish not in recommended_foods['Food Items'].values:
        dish = input(f"Invalid selection. Please choose a dish from the above recommendations for {meal_type}: ")
    
    selected_dishes[meal_type] = dish
    
    # Add selected dish's nutrients to totals
    for nutrient in total_nutrients.keys():
        total_nutrients[nutrient] += df.loc[dish, nutrient]

# Output selected dishes and total nutrient calculation
print("\nYour selected dishes:")
for meal_type, dish in selected_dishes.items():
    print(f"{meal_type}: {dish}")

print("\nNutrient Comparison:")
print(f"Preferred - Calories: {user_preferences['Calories'][0]} kcal, Fats: {user_preferences['Fats'][0]} g, "
      f"Proteins: {user_preferences['Proteins'][0]} g, Carbohydrates: {user_preferences['Carbohydrates'][0]} g")
print(f"Selected - Calories: {total_nutrients['Calories']} kcal, Fats: {total_nutrients['Fats']} g, "
      f"Proteins: {total_nutrients['Proteins']} g, Carbohydrates: {total_nutrients['Carbohydrates']} g")

# Check if total nutrients align with user's preference
if total_nutrients['Calories'] <= user_preferences['Calories'][0]:
    print("\nThe selected dishes are within your preferred calorie limit.")
else:
    print("\nThe selected dishes exceed your preferred calorie limit.")

# Check other nutrients
for nutrient in ['Fats', 'Proteins', 'Carbohydrates']:
    if total_nutrients[nutrient] > user_preferences[nutrient][0]:
        print(f"Warning: Selected {nutrient.lower()} exceed the preferred limit.")
