const mongoose = require('mongoose');
const { Schema } = mongoose;

const articleSchema = new Schema({
  title: String,
  content: String
});

module.exports = mongoose.model('Article', articleSchema);