# 🥘 Recipe Finder - Backend - API

Task on hand: It's dinner time! Create an application that helps users find the most relevant recipes that they can prepare with the ingredients that they have at home.

---

A fast and lightweight Rails API for searching recipes by ingredients you already have at home.

[![Test Status](https://github.com/ibalosh/recipe_time/actions/workflows/ci.yml/badge.svg)](https://github.com/ibalosh/recipe_time/actions)

🌐 **Live frontend demo**: [recipe-finder](https://recipe-finder.playground.ibalosh.com/)

💻 **Frontend repo**: [github.com/ibalosh/recipe_time_frontend](https://github.com/ibalosh/recipe_time_frontend)

---

## 💡 Project Overview

This application allows users to search recipes by one or more ingredients (e.g. `eggs mushrooms`) and get back recipes that contain the most relevant matches. The API ranks results by how many of the searched ingredients match, relative to each recipe’s total ingredients.
 
Searching for `flour water oil` will prefer recipes that contain all ingredients compared to total number ingredients in the recipe.

#### Example: searching for `["water", "oil", "flour"]`

| Recipe                         | Total Ingredients | Matched Ingredients | Relevance (%) |
|--------------------------------|-------------------|---------------------|---------------|
| Gluten-Free Sourdough Starter  | 3                 | 3                   | 100.00        |
| Fried Flour Tortilla Chips     | 2                 | 2                   | 100.00        |
| Chapati (East African Bread)   | 6                 | 5                   |  83.33        |

---

## 🧠 Database Structure

The data is imported from a JSON dataset (9,000+ recipes). 
The database uses a **relational schema** with denormalization in some areas to favor performance, maintainability, and development speed.

For a deeper look at the schema and the reasoning behind optimizations (indexing, partial normalization), see [docs/DATABASE.md](docs/DATABASE.md).
API endpoints are documented in [docs/API_ENDPOINTS.md](docs/API_ENDPOINTS.md).

---

## 🔐 Backend Improvements

- ✅ **Test coverage** for data models and API endpoints
- ✅ **Improved seeds**: transforms fields like URLs and enriches records with fields like `short_description` and `instructions` to make the frontend experience more engaging
- ✅ **Basic authentication**: added simple single token-based protection to prevent public access to the API
