const mongoose = require('mongoose');
const { Schema } = mongoose;

const articleSchema = new Schema({
  title: String,
  theme: String,
  url: String,
  content: String,
  hints: [String],
  difficulty: String,
});

module.exports = mongoose.model('Article', articleSchema);