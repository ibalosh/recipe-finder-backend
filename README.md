# 🥘 Recipe Finder - Backend - API

A fast and lightweight Rails API for searching recipes by ingredients you already have at home.

[![Test Status](https://github.com/ibalosh/recipe_time/actions/workflows/ci.yml/badge.svg)](https://github.com/ibalosh/recipe_time/actions)

🌐 **Live frontend demo**: [recipe-time-frontend.onrender.com](https://recipe-time-frontend.onrender.com)

💻 **Frontend repo**: [github.com/ibalosh/recipe_time_frontend](https://github.com/ibalosh/recipe_time_frontend)

---

## 💡 Project Overview

This application allows users to search recipes by one or more ingredients (e.g. `eggs mushrooms`) and get back recipes that contain the most relevant matches. The API ranks results by how many of the searched ingredients match, relative to each recipe’s total ingredients.

Example:  
Searching for `eggs milk sugar` will prefer recipes that contain all three ingredients (100%) over those with partial matches (66%, 33%, etc).

---

## 🧠 Database Structure

The data is imported from a large JSON dataset (9,000+ recipes). The database uses a **relational schema** with pragmatic denormalization in some areas to favor performance, maintainability, and development speed.


### 📦 Key Tables

- `recipes`: holds core metadata like title, rating, cook/prep time, image URL, short description, and instructions
- `ingredients`: stores individual **raw strings** (e.g. `"2 eggs"`, `"½ cup milk"`) associated with a recipe
- `authors`, `categories`, `cuisines`: normalized for clean associations and potential filtering

### ⚖️ Design Decision: Raw Ingredients over Normalized Entities

Although a more normalized structure could have been used for ingredients (to separate ingredient by name, unit, measurement unit type), this was intentionally avoided for the following reasons:

- 🧠 The source ingredient data is **highly variable and inconsistent** (e.g. `"2 eggs"`, `"1 egg"`, `"egg yolks"`, `"beaten eggs"`), making automatic parsing error-prone
- ⏱️ Attempting to extract consistent quantity, unit, and name would have added significant complexity without clear value for this project scope
- 🚀 Instead, raw ingredient text is stored and searched with **fuzzy matching (ILIKE)** and **trigram indexing**, which gives good relevance without full normalization

This tradeoff keeps the schema simple, performant, and tailored for full-text ingredient search — rather than structured nutrition breakdown or measurement conversions.

---

## ⚡ Performance Optimizations

To ensure fast searches (goal: under **200ms** on Render), the following is in place:

- **PostgreSQL GIN index** on `ingredients.raw_text`, enabling trigram-accelerated ILIKE queries
- 🔥 **Measured local speedup**: recipe queries improved from **270ms → 80ms** after adding the index

---

## 🔐 Backend Improvements

- ✅ **Test coverage** for data models and API endpoints
- ✅ **Improved seeds**: transforms fields like URLs and enriches records with fields like `short_description` and `instructions` to make the frontend experience more engaging
- ✅ **Basic authentication**: added token-based protection to prevent public access to the API
