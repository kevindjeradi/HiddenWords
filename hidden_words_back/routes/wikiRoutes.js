const fetch = require('node-fetch');
const express = require('express');
const router = express.Router();
const Article = require('../models/article');

router.get('/random-wikipedia-article', async (req, res) => {
    try {
        let validArticleFound = false;
        let attempts = 0;
        let title, url, contentToShow;

        while (!validArticleFound && attempts < 20) {
            const apiUrl = 'https://fr.wikipedia.org/w/api.php?action=query&format=json&list=random&rnnamespace=0&rnlimit=1';
            const response = await fetch(apiUrl);

            if (!response.ok) {
                throw new Error(`Error fetching from French Wikipedia API: ${response.status} - ${response.statusText}`);
            }

            const data = await response.json();

            if (!data.query || !data.query.random || data.query.random.length === 0) {
                throw new Error('No article found in the response');
            }

            title = data.query.random[0].title;

            if (title.split(' ').length <= 2 && !title.includes(':') && !title.includes('-') && !title.includes('.')) {
                validArticleFound = true;

                url = `https://fr.wikipedia.org/wiki/${encodeURIComponent(title)}`;

                const contentApiUrl = `https://fr.wikipedia.org/w/api.php?action=query&format=json&prop=extracts&explaintext&titles=${encodeURIComponent(title)}`;
                const contentResponse = await fetch(contentApiUrl);

                if (!contentResponse.ok) {
                    throw new Error(`Error fetching article content from French Wikipedia API: ${contentResponse.status} - ${contentResponse.statusText}`);
                }

                const contentData = await contentResponse.json();
                const pageId = Object.keys(contentData.query.pages)[0];
                let fullText = contentData.query.pages[pageId].extract || 'No content available';

                // Split by subcategory titles
                const sections = fullText.split(/(\n={2,3} [^=]+ ={2,3}\n)/);
                contentToShow = sections[0]; // Intro section
                
                // Remove consecutive newline characters, equals signs, and spaces
                fullText = fullText.replace(/\n{2,}/g, '\n')
                            .replace(/={2,}/g, '')
                            .replace(/ {2,}/g, ' ');


                if (sections.length > 3) {
                    for (let i = 1; i < sections.length && i <= 4; i++) {
                        // Extract and clean the title text
                        const titleMatch = sections[i].match(/={2,3} ([^=]+) ={2,3}/);
                        if (titleMatch && titleMatch[1]) {
                            contentToShow += `\n${titleMatch[1].trim()}\n${sections[i + 1]}`;
                        }
                    }
                } else {
                    contentToShow = fullText; // Show everything if less than two subcategories
                }
            }

            attempts++;
        }

        if (!validArticleFound) {
            return res.status(404).send('Unable to find a suitable article after several attempts');
        }

        // Final cleanup of the content to show
        contentToShow = contentToShow.replace(/\n{2,}/g, '\n')
                        .replace(/={2,}/g, '')
                        .replace(/ {2,}/g, ' ');
        res.send({ title, url, contentToShow });
    } catch (error) {
        console.error(error.message);
        res.status(500).send(`Error fetching article: ${error.message}`);
    }
});


// POST route to create a new article
router.post('/create-article-from-wikipedia', async (req, res) => {
    try {
        const { title, content, url } = req.body;

        // Simple validation
        if (!title || !content || !url) {
            return res.status(400).send('Title, content, and URL are required.');
        }

        // Create a new article using the Article model
        const newArticle = new Article({ title, content, url });
        await newArticle.save();

        res.status(201).json(newArticle);
    } catch (error) {
        console.error(error.message);
        res.status(500).send(`Error creating article: ${error.message}`);
    }
});

module.exports = router;