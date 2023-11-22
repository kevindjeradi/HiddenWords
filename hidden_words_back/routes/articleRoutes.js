// articleRoutes.js
const express = require('express');
const router = express.Router();
const Article = require('../models/article');

// GET /articles to retrieve all articles
router.get('/articles', async (req, res) => {
    try {
        const articles = await Article.find({});
        res.json(articles);
    } catch (error) {
        res.status(500).send('Error fetching articles ' + error);
    }
});

// GET /article/:id
router.get('/article/:id', async (req, res) => {
try {
    const article = await Article.findById(req.params.id);
    if (!article) {
        return res.status(404).send('Article not found');
    }
    res.json(article);
} catch (error) {
    res.status(500).send('Error fetching article ' + error);
}
});

// POST /article to create a new article
router.post('/article', async (req, res) => {
    try {
        const { title, content, theme, url, hints, difficulty } = req.body;

        if (!title || !content) {
            return res.status(400).send('Title and content are required');
        }

        // Create an object to hold the article data
        let articleData = { title, content };

        // Add other fields if they are not null or empty
        if (theme) articleData.theme = theme;
        if (url) articleData.url = url;
        if (hints && hints.length > 0) articleData.hints = hints;
        if (difficulty) articleData.difficulty = difficulty;

        const newArticle = new Article(articleData);
        await newArticle.save();
        res.status(201).json(newArticle);
    } catch (error) {
        res.status(500).send('Error creating article ' + error);
    }
});

// PUT /article/:id to update an existing article
router.put('/article/:id', async (req, res) => {
    try {
        const { title, content, theme, url, hints, difficulty } = req.body;
        const articleData = { title, content, theme, url, hints, difficulty };
        
        const updatedArticle = await Article.findByIdAndUpdate(
            req.params.id,
            articleData,
            { new: true }
        );
        
        if (!updatedArticle) {
            return res.status(404).send('Article not found');
        }
        
        res.json(updatedArticle);
    } catch (error) {
        res.status(500).send('Error updating article ' + error);
    }
});

module.exports = router;