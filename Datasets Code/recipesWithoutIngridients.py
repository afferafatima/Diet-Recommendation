import requests
import csv
import os

# Define the API key and base URL
API_KEY = 'ad1d35ec1621451184a97301e22979cc'
BASE_URL = 'https://api.spoonacular.com/recipes/complexSearch'

# Parameters for the API request
params = {
    'apiKey': API_KEY,
    'cuisine': 'Asian',  # Filter for Asian cuisine
    'number': 50,  # Number of recipes to fetch per request (maximum depends on API limit)
    'offset': 300,              # Offset for pagination'
    'addRecipeInformation': True,  # Include detailed recipe information
    'addRecipeNutrition': True,  # Include nutritional information
    'addRecipeInstructions': True,  # Include recipe instructions
    'instructionsRequired': True  # Ensure recipes have instructions
}

# Function to fetch data from the API
def fetch_recipes():
    try:
        response = requests.get(BASE_URL, params=params)
        response.raise_for_status()  # Raise an error for bad status codes
        return response.json()
    except requests.exceptions.RequestException as e:
        print(f"Error fetching data: {e}")
        return None

# Function to save data to a CSV file


def save_to_csv(data, filename):
    if not data:
        print("No data to save.")
        return

    # Check if the file exists
    file_exists = os.path.exists(filename)

    # Open the file in append mode
    with open(filename, mode='a', newline='', encoding='utf-8') as file:
        writer = csv.writer(file)

        # Write the header only if the file doesn't exist
        if not file_exists:
            header = [
                'Recipe ID', 'Food Item Name', 'Calories', 'Fats', 'Proteins', 'Carbohydrates', 
                'Ingredients', 'Instructions', 'Dish Types', 'Image URL', 'Ready In Minutes', 
                'Servings', 'Source URL', 'Cuisine', 'Type', 'Intolerances'
            ]
            writer.writerow(header)

        # Write the recipe data
        for recipe in data.get('results', []):
            # Fetch ingredients
            ingredients = ", ".join([
                ingredient.get('name', '') for ingredient in recipe.get('extendedIngredients', [])
            ]) if recipe.get('extendedIngredients') else 'N/A'

            # Fetch instructions
            instructions = " ".join([
                step.get('step', '') for step in recipe.get('analyzedInstructions', [{}])[0].get('steps', [])
            ]) if recipe.get('analyzedInstructions') else 'N/A'

            # Prepare row
            row = [
                recipe.get('id'),
                recipe.get('title'),
                recipe.get('nutrition', {}).get('nutrients', [{}])[0].get('amount', ''),  # Calories
                recipe.get('nutrition', {}).get('nutrients', [{}])[1].get('amount', ''),  # Fats
                recipe.get('nutrition', {}).get('nutrients', [{}])[2].get('amount', ''),  # Proteins
                recipe.get('nutrition', {}).get('nutrients', [{}])[3].get('amount', ''),  # Carbohydrates
                ingredients,
                instructions,
                ", ".join(recipe.get('dishTypes', [])),
                recipe.get('image'),
                recipe.get('readyInMinutes'),
                recipe.get('servings'),
                recipe.get('sourceUrl'),
                ", ".join(recipe.get('cuisines', [])),
                recipe.get('dishTypes', [])[0] if recipe.get('dishTypes') else '',
                ", ".join(recipe.get('cuisines', []))  # Use cuisines for now, Spoonacular doesn't directly provide intolerances
            ]
            writer.writerow(row)
    print(f"Data appended to {filename}")
# Main execution
if __name__ == "__main__":
    print("Fetching recipes...")
    recipes_data = fetch_recipes()

    if recipes_data:
        print("Saving data to recipesWithoutIngridients.csv...")
        save_to_csv(recipes_data, './Datasets/RecipesWithoutIngridients.csv')
        print("Data saved successfully!")
    else:
        print("Failed to fetch or save data.")
