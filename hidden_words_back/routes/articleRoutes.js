// articleRoutes.js
const express = require('express');
const router = express.Router();
const Article = require('../models/article');

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
        const { title, content } = req.body;
        if (!title || !content) {
            return res.status(400).send('Title and content are required');
        }
        const newArticle = new Article({ title, content });
        await newArticle.save();
        res.status(201).json(newArticle);
    } catch (error) {
        res.status(500).send('Error creating article ' + error);
    }
});

module.exports = router;