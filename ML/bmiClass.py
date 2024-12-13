from imblearn.over_sampling import SMOTE
from sklearn.metrics import classification_report, confusion_matrix, accuracy_score, precision_score, recall_score, f1_score
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split
from sklearn.neighbors import KNeighborsClassifier
from sklearn.preprocessing import OneHotEncoder

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

# Split the data
X_train, X_test, y_train, y_test = train_test_split(X_scaled, y_encoded, test_size=0.3, random_state=42)

# Reverse one-hot encoding for test labels
y_test_labels = np.argmax(y_test, axis=1)

# Inspect class distribution before SMOTE (original data)
class_distribution_before = data['BmiClass'].value_counts()
print("Class Distribution Before SMOTE:\n", class_distribution_before)

# Plot the distribution of the original data
plt.figure(figsize=(8, 6))
class_distribution_before.plot(kind='bar', color='skyblue')
plt.title("Class Distribution Before SMOTE")
plt.xlabel("BMI Class")
plt.ylabel("Number of Instances")
plt.show()

# Apply SMOTE to the training data to handle class imbalance
smote = SMOTE(random_state=42)
X_train_resampled, y_train_resampled = smote.fit_resample(X_train, np.argmax(y_train, axis=1))

# Inspect class distribution after SMOTE (resampled data)
class_distribution_after = pd.Series(y_train_resampled).value_counts()
print("Class Distribution After SMOTE:\n", class_distribution_after)

# Plot the distribution of the resampled data
plt.figure(figsize=(8, 6))
class_distribution_after.plot(kind='bar', color='lightcoral')
plt.title("Class Distribution After SMOTE")
plt.xlabel("BMI Class")
plt.ylabel("Number of Instances")
plt.show()

# Calculate imbalance ratio before and after SMOTE
imbalance_ratio_before = class_distribution_before.max() / class_distribution_before.min()
imbalance_ratio_after = class_distribution_after.max() / class_distribution_after.min()

print(f"Imbalance Ratio Before SMOTE: {imbalance_ratio_before:.2f}")
print(f"Imbalance Ratio After SMOTE: {imbalance_ratio_after:.2f}")
# Initialize K-Nearest Neighbors model
knn_model = KNeighborsClassifier(n_neighbors=5)

# Train the KNN model on the resampled data
knn_model.fit(X_train_resampled, y_train_resampled)

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
print(f"K-Nearest Neighbors Accuracy (with SMOTE): {accuracy:.4f}")
print(f"K-Nearest Neighbors Precision (with SMOTE): {precision:.4f}")
print(f"K-Nearest Neighbors Recall (with SMOTE): {recall:.4f}")
print(f"K-Nearest Neighbors F1 Score (with SMOTE): {f1:.4f}")
print(f"\nK-Nearest Neighbors Classification Report (with SMOTE):\n{class_report}")

# Confusion Matrix for SMOTE
plt.figure(figsize=(8, 6))
sns.heatmap(conf_matrix, annot=True, fmt='d', cmap='Blues', xticklabels=bmi_class_labels, yticklabels=bmi_class_labels)
plt.title("Confusion Matrix for K-Nearest Neighbors with SMOTE")
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

# Call the prediction function with user data
predict_bmi_class(knn_model, scaler, bmi_class_labels, 61, 1.85, 109.3, 31.94)
