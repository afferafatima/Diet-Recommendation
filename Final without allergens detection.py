def calculate_bmi(weight, height):
    # BMI formula: weight (kg) / height (m)^2
    bmi = weight / (height ** 2)
    return bmi

def calculate_tdee(age, weight, height, sex, activity_level):
    # Mifflin-St Jeor Equation to calculate BMR
    if sex == 'male':
        bmr = (10 * weight) + (6.25 * height * 100) - (5 * age) + 5  # BMR for males
    else:
        bmr =  (10 * weight) + (6.25 * height * 100) - (5 * age) - 161 # BMR for males

    # Activity multiplier based on activ ity level
    activity_multiplier = {
        'sedentary': 1.2,
        'light': 1.375,
        'moderate': 1.55,
        'active': 1.725,
        'very_active': 1.9
    }

    tdee = bmr * activity_multiplier.get(activity_level, 1.2)  # Default to sedentary if activity level is invalid
    return tdee

def calculate_macronutrients(tdee):
    # Macronutrient distribution (percentage of total calories)
    protein_calories = tdee * 0.3  # 20% of total calories from protein
    fat_calories = tdee * 0.3      # 30% of total calories from fat
    carb_calories = tdee * 0.4     # 50% of total calories from carbs

    # Convert calories into grams (1g protein = 4 calories, 1g fat = 9 calories, 1g carb = 4 calories)
    protein_grams = protein_calories / 4
    fat_grams = fat_calories / 9
    carb_grams = carb_calories / 4

    return protein_grams, fat_grams, carb_grams
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.neighbors import KNeighborsClassifier
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix, precision_score, recall_score, f1_score
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

# Load the dataset
data = pd.read_csv("bmi.csv")

# Define features (X) and target (y)
X = data[['Age', 'Height', 'Weight', 'Bmi']]
y = data[['BmiClass']]

# Apply StandardScaler to features
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# One-hot encode the BmiClass column without dropping any columns
onehot_encoder = OneHotEncoder(sparse_output=False)  # For scikit-learn >=1.2.0
y_encoded = onehot_encoder.fit_transform(y)

# Get the class labels for BMI Class (optional)
bmi_class_labels = onehot_encoder.categories_[0]

# Display the number of columns generated and the labels
print(f"One-hot encoding generated {y_encoded.shape[1]} columns.")
print(f"BmiClass categories: {bmi_class_labels}")

# Split the data
X_train, X_test, y_train, y_test = train_test_split(X_scaled, y_encoded, test_size=0.3, random_state=42)

# Reverse one-hot encoding for test labels
y_test_labels = np.argmax(y_test, axis=1)

# Initialize K-Nearest Neighbors model
knn_model = KNeighborsClassifier(n_neighbors=5)

# Train the KNN model
knn_model.fit(X_train, np.argmax(y_train, axis=1))  # Use class indices for training

# Make predictions
y_pred = knn_model.predict(X_test)

# Evaluate the model
accuracy = accuracy_score(y_test_labels, y_pred)
precision = precision_score(y_test_labels, y_pred, average='weighted')
recall = recall_score(y_test_labels, y_pred, average='weighted')
f1 = f1_score(y_test_labels, y_pred, average='weighted')
conf_matrix = confusion_matrix(y_test_labels, y_pred)
class_report = classification_report(y_test_labels, y_pred, target_names=bmi_class_labels)

# Print evaluation metrics
print(f"K-Nearest Neighbors Accuracy: {accuracy:.4f}")
print(f"K-Nearest Neighbors Precision: {precision:.4f}")
print(f"K-Nearest Neighbors Recall: {recall:.4f}")
print(f"K-Nearest Neighbors F1 Score: {f1:.4f}")
print(f"\nK-Nearest Neighbors Classification Report:\n{class_report}")

# Visualization: Confusion Matrix
plt.figure(figsize=(8, 6))
sns.heatmap(conf_matrix, annot=True, fmt='d', cmap='Blues', xticklabels=bmi_class_labels, yticklabels=bmi_class_labels)
plt.title("Confusion Matrix for K-Nearest Neighbors")
plt.xlabel("Predicted Labels")
plt.ylabel("True Labels")
plt.show()


# Function to predict BMI class for passed data
def predict_bmi_class(model, scaler, bmi_class_labels, age, height, weight, bmi):
    # Prepare the data for prediction
    user_data = np.array([[age, height, weight, bmi]])

    # Standardize the input data (use the same scaler that was used for training)
    user_data_scaled = scaler.transform(user_data)

    # Make prediction
    prediction = model.predict(user_data_scaled)

    # Get the predicted BMI class
    predicted_class = bmi_class_labels[prediction][0]

    print(f"Predicted BMI Class: {predicted_class}")
import pandas as pd
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.preprocessing import StandardScaler

# Load dataset
data_path = 'Food.csv'
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
meal_categories = ['Breakfast', 'Lunch', 'Dinner', 'Snack' ,'Side Dish']
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


def main():
    # Get user input
    age = int(input("Enter your age: "))
    weight = float(input("Enter your weight (kg): "))
    height = float(input("Enter your height (m): "))
    sex = input("Enter your sex (male/female): ").lower()
    activity_level = input("Enter your activity level (sedentary, light, moderate, active, very_active): ").lower()
    allergies = input("Do you have any allergies or intolerances (yes/no)? ").lower()

    # Calculate BMI
    bmi = calculate_bmi(weight, height)

    # Calculate Total Daily Energy Expenditure (TDEE)
    tdee = calculate_tdee(age, weight, height, sex, activity_level)

    # Calculate Macronutrient breakdown
    protein_grams, fat_grams, carb_grams = calculate_macronutrients(tdee)

    # Output results
    print("\nResults:")
    print(f"BMI: {bmi:.2f}")
    print(f"Total Calories: {tdee:.2f} kcal")
    print(f"Protein: {protein_grams:.2f} grams")
    print(f"Fat: {fat_grams:.2f} grams")
    print(f"Carbohydrates: {carb_grams:.2f} grams")

    if allergies == 'yes':
        print("Note: You have allergies or intolerances. Please consult a healthcare provider before following this plan.")
    
# Call the prediction function with user data
    predict_bmi_class(knn_model, scaler, bmi_class_labels, age , height, weight, bmi)
    # Example user_preferences dictionary
    user_preferences = {
        'Calories': [tdee],
        'Fats': [fat_grams],
        'Proteins': [protein_grams],
        'Carbohydrates': [carb_grams],
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

if __name__ == "__main__":
    main()
