from flask import Flask, request, jsonify
import pandas as pd
from sklearn.metrics.pairwise import cosine_similarity
import joblib
from flask_cors import CORS
from spacy.matcher import PhraseMatcher
import spacy
from fuzzywuzzy import process
import csv

# Initialize the Flask app
app = Flask(__name__)

# Enable CORS to allow requests from your frontend app (e.g., Flutter)
CORS(app)

# Load BMI prediction model and scaler
try:
    knn_model = joblib.load('knn_model_with_smote.pkl')
    scaler = joblib.load('scaler_with_smote.pkl')
    print("BMI model and scaler loaded successfully.")
except Exception as e:
    print(f"Error loading BMI model or scaler: {e}")

# Define BMI class labels
bmi_class_labels = ['Normal Weight', 'Obese Class 1', 'Obese Class 2', 
                    'Obese Class 3', 'Overweight', 'Underweight']

# BMI Prediction Endpoint
@app.route('/predict', methods=['POST'])
def predict():
    try:
        data = request.get_json()
        print(f"Received data for prediction: {data}")

        # Extract input data
        age = data['age']
        height = data['height']
        weight = data['weight']
        bmi = data['bmi']

        # Prepare user data for prediction
        user_data = pd.DataFrame([[age, height, weight, bmi]], columns=['Age', 'Height', 'Weight', 'Bmi'])
        print(f"Original user data: {user_data}")

        # Standardize the input data
        user_data_scaled = scaler.transform(user_data)
        print(f"Scaled user data: {user_data_scaled}")

        # Make prediction
        prediction = knn_model.predict(user_data_scaled)
        predicted_class = bmi_class_labels[prediction[0]]
        print(f"Predicted BMI class: {predicted_class}")

        return jsonify({'predicted_class': predicted_class})

    except Exception as e:
        print(f"Error in prediction: {e}")
        return jsonify({'error': str(e)})

# Load the dataset
data_path = 'food.csv'
try:
    df = pd.read_csv(data_path)
    print(f"Dataset loaded from {data_path}")
except FileNotFoundError:
    print(f"Error: Dataset file {data_path} not found.")
    exit()

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
meal_categories = ['Breakfast', 'Lunch', 'Dinner', 'Snack']
meals = {meal: df[df[meal] == 1].drop(columns=meal_categories).copy() for meal in meal_categories}

# Normalize each meal category
df_normalized_meals = {
    meal: data.apply(lambda x: (x - x.mean()) / x.std(), axis=0) for meal, data in meals.items()
}

import random  # Import for random selection

# Updated recommendation function
def recommend_food_items_based_on_preference(user_preferences, meal_type, num_recommendations=20):
    try:
        print(f"Generating recommendations for meal type: {meal_type}")
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
        print(f"Top {num_recommendations} recommendations: {food_sim_df.head(num_recommendations)}")
        return food_sim_df.head(num_recommendations)
    except Exception as e:
        print(f"Error in recommendation function: {e}")
        return pd.DataFrame()

# Function to extract allergies using spaCy and fuzzy matching
def extract_allergies(allergies_input, predefined_allergens, threshold=80):
    try:
        print(f"Extracting allergies from input: {allergies_input}")
        nlp = spacy.load("en_core_web_sm")
        matcher = PhraseMatcher(nlp.vocab)
        patterns = [nlp.make_doc(allergen) for allergen in predefined_allergens]
        matcher.add("ALLERGENS", patterns)
        doc = nlp(allergies_input)
        matches = matcher(doc)
        extracted_allergies = [doc[start:end].text.lower() for _, start, end in matches]

        known_allergens = set(predefined_allergens)
        words_in_input = set(token.text.lower() for token in doc if token.is_alpha)
        fuzzy_matches = {
            word: process.extractOne(word, predefined_allergens)
            for word in words_in_input
        }

        corrected_allergens = [
            match[0] for word, match in fuzzy_matches.items() if match and match[1] >= threshold
        ]

        all_allergies = set(extracted_allergies).union(corrected_allergens)
        print(f"Extracted and corrected allergies: {all_allergies}")
        return list(all_allergies)
    except Exception as e:
        print(f"Error in extracting allergies: {e}")
        return []

# Load dishes and allergens from CSV
def load_dishes_from_csv():
    dishes = []
    predefined_allergens = set()
    try:
        with open(data_path, mode='r') as csv_file:
            reader = csv.DictReader(csv_file)
            for row in reader:
                ingredients = row["Ingredients"].split(",")
                dishes.append({
                    "name": row["Food Items"],
                    "ingredients": ingredients,
                    "calories": float(row["Calories"]),
                    "fats": float(row["Fats"]),
                    "proteins": float(row["Proteins"]),
                    "carbohydrates": float(row["Carbohydrates"]),
                    "meal_type": {
                        "breakfast": row["Breakfast"].strip().lower() == "yes",
                        "lunch": row["Lunch"].strip().lower() == "yes",
                        "dinner": row["Dinner"].strip().lower() == "yes",
                        "snack": row["Snack"].strip().lower() == "yes",
                    },
                })
                predefined_allergens.update(ingredient.strip().lower() for ingredient in ingredients)
    except FileNotFoundError:
        print(f"Error: File {data_path} not found.")
    return dishes, list(predefined_allergens)

def filter_dishes_by_allergies(dishes, allergies):
    filtered_dishes = []
    for dish in dishes:
        ingredients = dish["Ingredients"].split(",") if isinstance(dish["Ingredients"], str) else []
        ingredients = [ingredient.strip().lower() for ingredient in ingredients]
        allergies_normalized = [allergen.strip().lower() for allergen in allergies]

        print(f"Checking dish: {dish['Food Items']}")
        print(f"Ingredients: {ingredients}")
        print(f"User allergies: {allergies_normalized}")

        if not any(allergen in ingredients for allergen in allergies_normalized):
            filtered_dishes.append(dish)
        else:
            print(f"Dish '{dish['Food Items']}' contains allergens: {set(ingredients).intersection(allergies_normalized)}")

    return filtered_dishes
# Updated food recommendation API
@app.route('/food-recommendation', methods=['POST'])
def food_recommendation():
    try:
        data = request.get_json()
        print(f"Received data for food recommendation: {data}")
        
        # Input data
        allergies = data.get('allergies_input', "").strip().lower()  # User's allergy input
        user_preferences = data.get('user_preferences', {})  # User's food preferences
        meal_types = data.get('mealTypes', ['Breakfast', 'Lunch', 'Dinner', 'Snack'])  # Default meal types

        # Load dishes and allergens
        dishes, predefined_allergens = load_dishes_from_csv()
        
        # Check if allergies input indicates no allergies
        if allergies == "no":
            print("No allergies specified. Proceeding without filtering.")
            user_allergies = []
        else:
            # Extract allergies from user input
            user_allergies = extract_allergies(allergies, predefined_allergens)
            print(f"Identified allergies: {user_allergies}")
        
        # Initialize the response dictionary
        meal_recommendations = {}

        # Loop through each meal type and get the recommendations
        for meal_type in meal_types:
            print(f"\nGenerating recommendations for {meal_type}:")
            
            # Get top 20 recommendations based on user preferences
            recommended_foods = recommend_food_items_based_on_preference(user_preferences, meal_type, num_recommendations=20)
            
            # If allergies are specified, filter the recommendations
            if user_allergies:
                filtered_dishes = filter_dishes_by_allergies(recommended_foods.to_dict('records'), user_allergies)
            else:
                # No filtering for allergies
                filtered_dishes = recommended_foods.to_dict('records')
            
            # Randomly select 3 dishes from the filtered recommendations
            random_dishes = random.sample(filtered_dishes, min(3, len(filtered_dishes)))
            
            # Prepare the meal recommendations for the response
            if random_dishes:
                random_dishes_df = pd.DataFrame(random_dishes)
                meal_recommendations[meal_type] = random_dishes_df[['Food Items', 'Ingredients']].to_dict(orient='records')
                print(f"Randomly selected dishes for {meal_type}:")
                print(random_dishes_df[['Food Items', 'Ingredients']])
            else:
                meal_recommendations[meal_type] = []

        # Prepare the final response
        response = {
            "allergies_found": user_allergies,
            "recommended_dishes": meal_recommendations
        }

        print(f"Final recommendation response: {response}")
        return jsonify(response)

    except Exception as e:
        print(f"Error in food recommendation: {e}")
        return jsonify({'error': str(e)}), 400
@app.route('/total_nutrients', methods=['POST'])
def total_nutrients():
    try:
        data = request.get_json()
        selected_dishes = data.get('selectedDishes', [])
        print(f"Received selected dishes for nutrient calculation: {selected_dishes}")
        
        total_nutrients = {"Calories": 0, "Proteins": 0, "Fats": 0, "Carbohydrates": 0}

        # Iterate through each selected dish name/ID and sum up the nutrients
        for dish_name in selected_dishes:
            if dish_name in df.index:  # Assume 'df.index' contains dish names or IDs
                dish_data = df.loc[dish_name]
                total_nutrients["Calories"] += dish_data.get('Calories', 0)
                total_nutrients["Proteins"] += dish_data.get('Proteins', 0)
                total_nutrients["Fats"] += dish_data.get('Fats', 0)
                total_nutrients["Carbohydrates"] += dish_data.get('Carbohydrates', 0)

        print(f"Total nutrients for selected dishes: {total_nutrients}")
        return jsonify(total_nutrients)

    except Exception as e:
        print(f"Error in total_nutrients endpoint: {e}")
        return jsonify({'error': str(e)}), 400

# Run the Flask app
if __name__ == '__main__':
    app.run(debug=True)
