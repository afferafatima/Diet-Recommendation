const express = require('express');
const mysql = require('mysql2');
const jwt = require('jsonwebtoken');
const cors = require('cors');

const app = express();
app.use(express.json());
app.use(cors());

// MySQL connection
const db = mysql.createConnection({
  host: 'localhost', // or your cloud MySQL host
  user: 'root',
  password: '2022',
  database: 'diet',
});

// Connect to MySQL
db.connect(err => {
  if (err) {
    console.error('Error connecting to DB: ' + err.stack);
    return;
  }
  console.log('Connected to DB');
});

app.post('/login', (req, res) => {
  const { email, password } = req.body;

  console.log(`Received login request with email: ${email}`);  // Debugging message

  if (!email || !password) {
    console.log('Missing email or password');  // Debugging message
    return res.status(400).json({ error: 'Email and password are required' });
  }

  // Query the users table for the user ID
  db.query('SELECT id, password, email FROM users WHERE email = ?', [email], (err, results) => {
    if (err) {
      console.error('Database error:', err);  // Debugging message
      return res.status(500).json({ error: 'Database error' });
    }

    if (results.length === 0) {
      console.log(`User with email ${email} not found`);  // Debugging message
      return res.status(404).json({ message: 'User not found' });
    }

    const user = results[0];
    console.log('User found:', user);  // Debugging message

    // Check if passwords match (plaintext comparison)
    if (user.password !== password) {
      console.log('Invalid credentials');  // Debugging message
      return res.status(400).json({ message: 'Invalid credentials' });
    }

    // Now, get the first_name and last_name from the userdetails table using the user ID
    db.query('SELECT first_name, last_name FROM userdetails WHERE user_id = ?', [user.id], (err, userDetails) => {
      if (err) {
        console.error('Error fetching user details:', err);  // Debugging message
        return res.status(500).json({ error: 'Error fetching user details' });
      }

      if (userDetails.length === 0) {
        console.log('User details not found');  // Debugging message
        return res.status(404).json({ message: 'User details not found' });
      }

      const { first_name, last_name } = userDetails[0];
      console.log('User details found:', userDetails[0]);  // Debugging message

      // Create a JWT token
      const token = jwt.sign({ id: user.id, email: user.email }, 'your_jwt_secret', { expiresIn: '1h' });
      console.log('JWT token created successfully');  // Debugging message

      // Send response with token, email, and name
      res.status(200).json({
        message: 'Login successful',
        token,
        email: user.email,  // Include the email in the response
        name: `${first_name} ${last_name}`,  // Concatenate first and last name from userdetails table
      });
    });
  });
});


// Endpoint to save user details
app.post('/api/saveUserDetails', (req, res) => {
  const {
    email,
    password,
    firstName,
    lastName,
    age,
    weight,
    height,
    gender,
    activityLevel,
    foodAllergies,
  } = req.body;

  console.log('Received request to save user details');  // Debugging message

  // Step 1: Insert user data into the 'users' table (email and password)
  const insertUserQuery = `
    INSERT INTO users (email, password, created_at)
    VALUES (?, ?, CURRENT_TIMESTAMP)
  `;

  db.query(insertUserQuery, [email, password], (err, result) => {
    if (err) {
      console.error('Error inserting into users table: ', err);
      return res.status(500).send({ message: 'Error saving user.' });
    }

    // Step 2: Retrieve the auto-generated user_id (from the users table)
    const userId = result.insertId; // The `insertId` contains the auto-generated user_id
    console.log(`User ID generated: ${userId}`);  // Debugging message

    // Step 3: Insert user details into the 'userdetails' table using the generated user_id
    const insertDetailsQuery = `
      INSERT INTO userdetails (user_id, first_name, last_name, age, weight, height, gender, activity_level, food_allergies)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    `;

    db.query(
      insertDetailsQuery,
      [
        userId, // Use the user_id from the users table
        firstName,
        lastName,
        age,
        weight,
        height,
        gender,
        activityLevel,
        foodAllergies,
      ],
      (err, result) => {
        if (err) {
          console.error('Error inserting into userdetails table: ', err);
          return res.status(500).send({ message: 'Error saving user details.' });
        }

        console.log('User details saved successfully!');  // Debugging message
        res.status(200).send({ message: 'User details saved successfully!' });
      }
    );
  });
});
app.post('/user-data', (req, res) => {
  const { userEmail } = req.body;

  console.log(`Received request for user data with email: ${userEmail}`);

  // Query the users table for the user ID
  db.query('SELECT id, password FROM users WHERE email = ?', [userEmail], (err, results) => {
    if (err) {
      console.error('Database error:', err);
      return res.status(500).json({ error: 'Database error' });
    }

    if (results.length === 0) {
      console.log(`User with email ${userEmail} not found`);
      return res.status(404).json({ message: 'User not found' });
    }

    const user = results[0];
    console.log('User found:', user);

    // Query the database for the user's information from `userdetails` table
    db.query('SELECT weight, height, age, gender, activity_level FROM userdetails WHERE user_id = ?', [user.id], (err, details) => {
      if (err) {
        console.error('Database error:', err);
        return res.status(500).json({ error: 'Database error' });
      }

      if (details.length === 0) {
        console.log(`No user details found for user ID: ${user.id}`);
        return res.status(404).json({ message: 'User details not found' });
      }

      const userDetails = details[0];
      console.log('User details found:', userDetails);

      // Convert height from centimeters to meters for BMI calculation
      const heightInMeters = userDetails.height / 100;
      console.log(`Height in meters: ${heightInMeters}`);

      // Calculate BMI
      const bmi = userDetails.weight / (heightInMeters * heightInMeters);
      console.log(`Calculated BMI: ${bmi.toFixed(2)}`);

      // Calculate TDEE (Total Daily Energy Expenditure)
      let bmr;
      if (userDetails.gender === 'male') {
        bmr = (10 * userDetails.weight) + (6.25 * heightInMeters * 100) - (5 * userDetails.age) + 5;
      } else {
        bmr = (10 * userDetails.weight) + (6.25 * heightInMeters * 100) - (5 * userDetails.age) - 161;
      }
      console.log(`Calculated BMR: ${bmr}`);

      const activityMultiplier = {
        Sedentary: 1.2,
        Light: 1.375,
        Moderate: 1.55,
        Active: 1.725,
        VeryActive: 1.9
      };

      const tdee = bmr * (activityMultiplier[userDetails.activity_level] || 1.2);
      console.log(`Calculated TDEE: ${tdee.toFixed(2)}`);

      // Calculate Macronutrients (Protein, Fat, Carbs)
      const proteinCalories = tdee * 0.3;
      const fatCalories = tdee * 0.3;
      const carbCalories = tdee * 0.4;

      const proteinGrams = proteinCalories / 4;
      const fatGrams = fatCalories / 9;
      const carbGrams = carbCalories / 4;

      console.log(`Protein: ${proteinGrams.toFixed(2)} grams`);
      console.log(`Fat: ${fatGrams.toFixed(2)} grams`);
      console.log(`Carbs: ${carbGrams.toFixed(2)} grams`);

      // Insert or update the calculated values in the database
      const query = `
        INSERT INTO user_nutrition_data (user_id, bmi, calories , protein, fat, carbs, created_at)
        VALUES (?, ?, ?, ?, ?, ?, NOW())
        ON DUPLICATE KEY UPDATE 
          bmi = VALUES(bmi), 
          calories = VALUES(calories), 
          protein = VALUES(protein), 
          fat = VALUES(fat), 
          carbs = VALUES(carbs), 
          created_at = NOW();
      `;

      db.query(query, [user.id, bmi, tdee, proteinGrams, fatGrams, carbGrams], (err) => {
        if (err) {
          console.error('Error inserting or updating nutrition data:', err);
          return res.status(500).json({ error: 'Error storing nutrition data' });
        }

        // Return the calculated data in the response
        res.status(200).json({
          bmi: bmi.toFixed(2),
          calories: tdee.toFixed(2),
          protein: proteinGrams.toFixed(2),
          fat: fatGrams.toFixed(2),
          carbs: carbGrams.toFixed(2),
        });
      });
    });
  });
});
app.post('/user-info', (req, res) => {
  const { userEmail } = req.body;

  // Check and log user email
  console.log(`Received request for user data with email: ${userEmail}`);

  // Query database for user info
  db.query('SELECT id, password FROM users WHERE email = ?', [userEmail], (err, results) => {
    if (err) {
      console.error('Database error:', err);
      return res.status(500).json({ error: 'Database error' });
    }

    if (results.length === 0) {
      console.log(`User with email ${userEmail} not found`);
      return res.status(404).json({ message: 'User not found' });
    }

    const user = results[0];
    console.log('User found:', user);

    // Query database for user details
    db.query('SELECT weight, height, age, gender, activity_level FROM userdetails WHERE user_id = ?', [user.id], (err, details) => {
      if (err) {
        console.error('Database error:', err);
        return res.status(500).json({ error: 'Database error' });
      }

      if (details.length === 0) {
        console.log(`No user details found for user ID: ${user.id}`);
        return res.status(404).json({ message: 'User details not found' });
      }

      const userDetails = details[0];
      console.log('User details found:', userDetails);

      // Calculate BMI
      const heightInMeters = userDetails.height / 100;
      const bmi = userDetails.weight / (heightInMeters * heightInMeters);

      // Respond with the calculated data
      res.status(200).json({
        height: heightInMeters.toFixed(2),
        age: userDetails.age,
        weight: userDetails.weight,
        bmi: bmi.toFixed(2),
      });
    });
  });
});

app.post('/user-bmi', (req, res) => {
  const { userEmail } = req.body;

  console.log(`Received request for user data with email: ${userEmail}`); // Debugging message

  // Query the users table for the user ID
  db.query('SELECT id, password FROM users WHERE email = ?', [userEmail], (err, results) => {
    if (err) {
      console.error('Database error:', err);  // Debugging message
      return res.status(500).json({ error: 'Database error' });
    }

    if (results.length === 0) {
      console.log(`User with email ${userEmail} not found`);  // Debugging message
      return res.status(404).json({ message: 'User not found' });
    }

    const user = results[0];
    console.log('User found:', user);  // Debugging message

    // Query the database for the user's nutrition data from `userdetails` table
    db.query('SELECT bmi, calories, protein, fat, carbs FROM user_nutrition_data WHERE user_id = ?', [user.id], (err, details) => {
      if (err) {
        console.error('Database error:', err);
        return res.status(500).json({ error: 'Database error' });
      }

      if (details.length === 0) {
        console.log(`No user details found for user ID: ${user.id}`);  // Debugging message
        return res.status(404).json({ message: 'User details not found' });
      }

      const userDetails = details[0];
      console.log('User details found:', userDetails);  // Debugging message

      // Return the data from the database in the response
      res.status(200).json({
        bmi: userDetails.bmi.toFixed(2),
        calories: userDetails.calories.toFixed(2),
        protein: userDetails.protein.toFixed(2),
        fat: userDetails.fat.toFixed(2),
        carbs: userDetails.carbs.toFixed(2),
      });
    });
  });
});


app.post('/user-allergies', (req, res) => {
  const { userEmail } = req.body;
  // Check and log user email
  console.log(`Received request for user data with email: ${userEmail}`);

  // Query database for user info
  db.query('SELECT id, password FROM users WHERE email = ?', [userEmail], (err, results) => {
    if (err) {
      console.error('Database error:', err);
      return res.status(500).json({ error: 'Database error' });
    }

    if (results.length === 0) {
      console.log(`User with email ${userEmail} not found`);
      return res.status(404).json({ message: 'User not found' });
    }

    const user = results[0];
    console.log('User found:', user);

    // Query database for user details
    db.query('SELECT food_allergies FROM userdetails WHERE user_id = ?', [user.id], (err, details) => {
      if (err) {
        console.error('Database error:', err);
        return res.status(500).json({ error: 'Database error' });
      }

      if (details.length === 0) {
        console.log(`No user details found for user ID: ${user.id}`);
        return res.status(404).json({ message: 'User details not found' });
      }

      const userDetails = details[0];
      console.log('User details found:', userDetails);


      // Respond with the calculated data
      res.status(200).json({
        foodAllergies: userDetails.food_allergies,
      });
    });
  });
});
app.post('/profile', (req, res) => {
  const { userEmail } = req.body;

  console.log(`Received request for user data with email: ${userEmail}`);

  // Query the users table for the user ID
  db.query('SELECT id, email , password FROM users WHERE email = ?', [userEmail], (err, results) => {
    if (err) {
      console.error('Database error:', err);
      return res.status(500).json({ error: 'Database error' });
    }

    if (results.length === 0) {
      console.log(`User with email ${userEmail} not found`);
      return res.status(404).json({ message: 'User not found' });
    }

    const user = results[0];
    console.log('User found:', user);

    // Query the database for the user's information from `userdetails` table
    db.query('SELECT first_name , last_name , weight, height, age, gender, activity_level, food_allergies FROM userdetails WHERE user_id = ?', [user.id], (err, details) => {
      if (err) {
        console.error('Database error:', err);
        return res.status(500).json({ error: 'Database error' });
      }

      if (details.length === 0) {
        console.log(`No user details found for user ID: ${user.id}`);
        return res.status(404).json({ message: 'User details not found' });
      }

      const userDetails = details[0];
      console.log('User details found:', userDetails);

      // Convert height from centimeters to meters for BMI calculation
      const heightInMeters = userDetails.height / 100;
      console.log(`Height in meters: ${heightInMeters}`);

      // Calculate BMI: BMI = weight (kg) / height (m)^2
      const bmi = userDetails.weight / (heightInMeters * heightInMeters);
      console.log(`Calculated BMI: ${bmi.toFixed(2)}`);

      // Return the calculated data in the response
      res.status(200).json({
        user: {
          name: userDetails.first_name + ' ' + userDetails.last_name,
          email: user.email, // Sending the email
          password: user.password,
          age: userDetails.age,
          gender: userDetails.gender,
          activityLevel: userDetails.activity_level,
          weight: userDetails.weight,
          height: userDetails.height,
          allergies: userDetails.food_allergies, // Sending allergies
        }
      });
    });
  });
});



app.put('/updateProfile', (req, res) => {
  const { userEmail, name, age, password, weight, height, gender , activityLevel, foodAllergies } = req.body;

  console.log(`Received request to update profile for user with email: ${userEmail}`);

  // Query the users table for the user ID
  db.query('SELECT id, email, password FROM users WHERE email = ?', [userEmail], (err, results) => {
    if (err) {
      console.error('Database error:', err);
      return res.status(500).json({ error: 'Database error' });
    }

    if (results.length === 0) {
      console.log(`User with email ${userEmail} not found`);
      return res.status(404).json({ message: 'User not found' });
    }

    const user = results[0];
    console.log('User found:', user);

    // Update user data in the `users` table
    const updateUserQuery = `
      UPDATE users
      SET password = ?
      WHERE email = ?
    `;
    db.query(updateUserQuery, [password, userEmail], (err, updateUserResults) => {
      if (err) {
        console.error('Error updating user data:', err);
        return res.status(500).json({ error: 'Error updating user data' });
      }

      // Update user details in the `userdetails` table
      const updateDetailsQuery = `
        UPDATE userdetails
        SET first_name = ?, last_name = ?, age = ?, weight = ?, height = ?, gender = ? ,activity_level = ?, food_allergies = ?
        WHERE user_id = ?
      `;
      db.query(updateDetailsQuery, [name.split(' ')[0], name.split(' ')[1], age, weight, height, gender , activityLevel, foodAllergies, user.id], (err, updateDetailsResults) => {
        if (err) {
          console.error('Error updating user details:', err);
          return res.status(500).json({ error: 'Error updating user details' });
        }

        // Retrieve updated details for nutrition calculation
        const updatedUserDetailsQuery = 'SELECT * FROM userdetails WHERE user_id = ?';
        db.query(updatedUserDetailsQuery, [user.id], (err, userDetailsResult) => {
          if (err) {
            console.error('Error retrieving updated user details:', err);
            return res.status(500).json({ error: 'Error retrieving updated user details' });
          }

          const userDetails = userDetailsResult[0];
          console.log('Updated user details:', userDetails);

          // Convert height from centimeters to meters for BMI calculation
          const heightInMeters = userDetails.height / 100;
          console.log(`Height in meters: ${heightInMeters}`);

          // Calculate BMI: BMI = weight (kg) / height (m)^2
          const bmi = userDetails.weight / (heightInMeters * heightInMeters);
          console.log(`Calculated BMI: ${bmi.toFixed(2)}`);

          // Calculate TDEE (Total Daily Energy Expenditure)
          let bmr;
          if (userDetails.gender === 'male') {
            bmr = (10 * userDetails.weight) + (6.25 * heightInMeters * 100) - (5 * userDetails.age) + 5;
          } else {
            bmr = (10 * userDetails.weight) + (6.25 * heightInMeters * 100) - (5 * userDetails.age) - 161;
          }
          console.log(`Calculated BMR: ${bmr}`);

          const activityMultiplier = {
            Sedentary: 1.2,
            Light: 1.375,
            Moderate: 1.55,
            Active: 1.725,
            VeryActive: 1.9
          };

          const tdee = bmr * (activityMultiplier[userDetails.activity_level] || 1.2);
          console.log(`Calculated TDEE: ${tdee.toFixed(2)}`);

          // Calculate Macronutrients (Protein, Fat, Carbs)
          const proteinCalories = tdee * 0.3;
          const fatCalories = tdee * 0.3;
          const carbCalories = tdee * 0.4;

          const proteinGrams = proteinCalories / 4;
          const fatGrams = fatCalories / 9;
          const carbGrams = carbCalories / 4;

          console.log(`Protein: ${proteinGrams.toFixed(2)} grams`);
          console.log(`Fat: ${fatGrams.toFixed(2)} grams`);
          console.log(`Carbs: ${carbGrams.toFixed(2)} grams`);
          // Update the calculated nutrition values in the database
          const nutritionQuery = `
  UPDATE user_nutrition_data
  SET 
    bmi = ?, 
    calories = ?, 
    protein = ?, 
    fat = ?, 
    carbs = ?, 
    created_at = NOW()
  WHERE user_id = ?;
`;

          db.query(nutritionQuery, [bmi, tdee, proteinGrams, fatGrams, carbGrams, user.id], (err) => {
            if (err) {
              console.error('Error updating nutrition data:', err);
              return res.status(500).json({ error: 'Error storing nutrition data' });
            }

            // Return the updated user profile and nutrition data in the response
            res.status(200).json({
              message: 'Profile updated successfully',
              user: {
                name: name,
                email: user.email,
                password: password,
                age: age,
                activityLevel: activityLevel,
                weight: weight,
                height: height,
                gender : gender ,
                allergies: foodAllergies,
                bmi: bmi.toFixed(2),
                calories: tdee.toFixed(2),
                protein: proteinGrams.toFixed(2),
                fat: fatGrams.toFixed(2),
                carbs: carbGrams.toFixed(2)
              }
            });
          });
        });
      });
    });
  });
});


app.post('/preferences', (req, res) => {
  const {
    email,
    preferred_calories,
    preferred_carbs,
    preferred_fats,
    preferred_proteins,
    dishes,
  } = req.body;

  const currentDate = new Date().toISOString().slice(0, 10); // Get current date in 'YYYY-MM-DD' format

  console.log('Received request:', req.body);

  // Step 1: Retrieve user_id using the provided email
  const userQuery = 'SELECT id FROM users WHERE email = ?';

  db.execute(userQuery, [email], (err, results) => {
    if (err) {
      console.error('Error executing query to fetch user_id:', err);
      return res.status(500).json({ message: 'Error fetching user data.' });
    }

    if (results.length === 0) {
      console.warn('User not found with email:', email);
      return res.status(404).json({ message: 'User not found with the provided email.' });
    }

    const user_id = results[0].id;
    console.log('Fetched user_id:', user_id);

    // Parse dishes to extract meal data
    const breakfast = dishes.find((dish) => dish.meal_type === 'Breakfast')?.food_items || '';
    const lunch = dishes.find((dish) => dish.meal_type === 'Lunch')?.food_items || '';
    const dinner = dishes.find((dish) => dish.meal_type === 'Dinner')?.food_items || '';
    const snack = dishes.find((dish) => dish.meal_type === 'Snack')?.food_items || '';

    console.log('Parsed meal data:', {
      breakfast,
      lunch,
      dinner,
      snack,
    });

    // Step 2: Check if a record exists for the user on the current date
    const checkQuery = `
      SELECT id FROM UserPreferences
      WHERE user_id = ? AND created_at  = ?
    `;

    db.execute(checkQuery, [user_id, currentDate], (err, checkResults) => {
      if (err) {
        console.error('Error checking for existing preferences:', err);
        return res.status(500).json({ message: 'Error checking preferences.' });
      }

      if (checkResults.length > 0) {
        // Record exists, update it
        console.log('Updating existing preferences for user_id:', user_id, 'on date:', currentDate);

        const updateQuery = `
          UPDATE UserPreferences
          SET 
            preferred_calories = ?, 
            preferred_carbs = ?, 
            preferred_fats = ?, 
            preferred_proteins = ?, 
            breakfast = ?, 
            lunch = ?, 
            dinner = ?, 
            snack = ?, 
            updated_at = CURRENT_TIMESTAMP
          WHERE user_id = ? AND created_at = ?
        `;

        db.execute(updateQuery, [
          preferred_calories,
          preferred_carbs,
          preferred_fats,
          preferred_proteins,
          breakfast,
          lunch,
          dinner,
          snack,
          user_id,
          currentDate,
        ], (err, updateResults) => {
          if (err) {
            console.error('Error updating preferences:', err);
            return res.status(500).json({ message: 'Error updating preferences.' });
          }

          console.log('Preferences updated successfully. Results:', updateResults);
          res.status(200).json({ message: 'Preferences updated successfully!', data: updateResults });
        });
      } else {
        // No record exists, insert a new one
        console.log('Inserting new preferences for user_id:', user_id, 'on date:', currentDate);

        const insertQuery = `
          INSERT INTO UserPreferences (
            user_id, 
            preferred_calories, 
            preferred_carbs, 
            preferred_fats, 
            preferred_proteins, 
            breakfast, 
            lunch, 
            dinner, 
            snack, 
            created_at
          )
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        `;

        db.execute(insertQuery, [
          user_id,
          preferred_calories,
          preferred_carbs,
          preferred_fats,
          preferred_proteins,
          breakfast,
          lunch,
          dinner,
          snack,
          currentDate,
        ], (err, insertResults) => {
          if (err) {
            console.error('Error inserting new preferences:', err);
            return res.status(500).json({ message: 'Error inserting preferences.' });
          }

          console.log('Preferences inserted successfully. Results:', insertResults);
          res.status(200).json({ message: 'Preferences saved successfully!', data: insertResults });
        });
      }
    });
  });
});

app.post('/view-preferences', (req, res) => {
  const { email, date } = req.body;
  
  console.log('Received request:', req.body);

  // Step 1: Retrieve user_id using the provided email
  const userQuery = 'SELECT id FROM users WHERE email = ?';

  db.execute(userQuery, [email], (err, results) => {
    if (err) {
      console.error('Error executing query to fetch user_id:', err);
      return res.status(500).json({ message: 'Error fetching user data.' });
    }

    if (results.length === 0) {
      console.warn('User not found with email:', email);
      return res.status(404).json({ message: 'User not found with the provided email.' });
    }

    const user_id = results[0].id;
    console.log('Fetched user_id:', user_id);

    // Step 2: Check if a record exists for the user on the current date
    const checkQuery = `SELECT breakfast, lunch, dinner, snack FROM UserPreferences WHERE user_id = ? AND created_at = ?`;

    db.execute(checkQuery, [user_id, date], (err, checkResults) => {
      if (err) {
        console.error('Error checking for existing preferences:', err);
        return res.status(500).json({ message: 'Error checking preferences.' });
      }

      if (checkResults.length > 0) {
        const mealPlan = checkResults[0]; // Get the meal plan data
        return res.status(200).json({ message: 'Preferences found', data: mealPlan });
      } else {
        return res.status(404).json({ message: 'No preferences found for the given date' });
      }
    });
  });
});



























// Start the server
const port = 3000;
app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
