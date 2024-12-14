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

// Login route (without password hashing)
app.post('/login', (req, res) => {
  const { email, password } = req.body;

  console.log(`Received login request with email: ${email}`);  // Debugging message

  if (!email || !password) {
    console.log('Missing email or password');  // Debugging message
    return res.status(400).json({ error: 'Email and password are required' });
  }

  // Query database for user
  db.query('SELECT * FROM users WHERE email = ?', [email], (err, results) => {
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

    // Create a JWT token
    const token = jwt.sign({ id: user.id, email: user.email }, 'your_jwt_secret', { expiresIn: '1h' });
    console.log('JWT token created successfully');  // Debugging message
    res.status(200).json({ message: 'Login successful', token });
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

// Start the server
const port = 5000;
app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
