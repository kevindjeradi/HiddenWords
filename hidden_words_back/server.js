// server.js
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

const app = express();
const PORT = 3001;

// Load environment variables from .env file
require('dotenv').config();
const dbURI = process.env.MONGO_URI;

mongoose.connect(dbURI, {
    useNewUrlParser: true,
    useUnifiedTopology: true
})
.then(() => console.log('Connected to MongoDB'))
.catch(err => console.error('Could not connect to MongoDB', err));

app.use(cors());
app.use(express.json());

app.get('/', (req, res) => {
  res.send('Yo');
});

app.listen(PORT, '0.0.0.0', function() {
  console.log(`Server is running on http://localhost:${PORT}`);
}
);
