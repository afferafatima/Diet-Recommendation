import pandas as pd

# Load the CSV files
recipes_with_ingredients = pd.read_csv('./Datasets/RecipesWithIngridients.csv')
recipes_without_ingredients = pd.read_csv('./Datasets/RecipesWithoutIngridients.csv')

# Merge the two files on 'Recipe ID' using an outer join
merged_data = pd.merge(
    recipes_with_ingredients, 
    recipes_without_ingredients, 
    on='Recipe ID', 
    how='outer'
)

# Fill missing values with 'N/A'
merged_data.fillna('N/A', inplace=True)

# Save the result to a new file
merged_data.to_csv('merged_recipes.csv', index=False)

print("Files merged successfully! Check 'merged_recipes.csv'.")
