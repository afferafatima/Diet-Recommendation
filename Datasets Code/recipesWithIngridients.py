import requests
import pandas as pd
import os
# Replace with your Spoonacular API key
API_KEY = 'ad1d35ec1621451184a97301e22979cc'
BASE_URL = 'https://api.spoonacular.com/recipes'

# Function to fetch only Asian dishes
def fetch_asian_dishes():
    params = {
        'apiKey': API_KEY,
        'number': 50,  # Number of dishes to fetch
        'offset': 325,  # Offset for pagination
        'cuisine': 'Asian',  # Filter for Asian cuisine
    }
    response = requests.get(f"{BASE_URL}/complexSearch", params=params)
    if response.status_code == 200:
        return response.json().get('results', [])
    else:
        print(f"Error: {response.status_code}, {response.text}")
        return []

# Function to process the data
def process_data(dishes):
    data = []
    for dish in dishes:
        # Fetch additional details for each dish
        recipe_id = dish.get('id')
        detail_url = f"{BASE_URL}/{recipe_id}/information"
        detail_response = requests.get(detail_url, params={'apiKey': API_KEY})
        if detail_response.status_code == 200:
            details = detail_response.json()
            
           
            item = {
                'Id' : details.get('id'),
                'Food Item Name': details.get('title'),
                'Ingredients': ', '.join([ingredient['name'] for ingredient in details.get('extendedIngredients', [])])
            }

            data.append(item)
    return data

# Save data to CSV
def save_to_csv(data, filename):
    df = pd.DataFrame(data)
    
    # Check if the file exists
    if os.path.exists(filename):
        # Append without writing the header
        df.to_csv(filename, mode='a', index=False, header=False)
    else:
        # Write with the header if the file does not exist
        df.to_csv(filename, index=False)
    
    print(f"Data appended to {filename}")

asian_dishes = fetch_asian_dishes()
if asian_dishes:
    processed_data = process_data(asian_dishes)
    save_to_csv(processed_data, './Datasets/recipesIngridients.csv')