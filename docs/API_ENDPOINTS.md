# API Endpoints

## 1. List Recipes

**GET** `/recipes`

Returns a paginated list of recipes. Supports search by ingredient tokens (default) or title.

**Query params:**
- `search` (string, optional): search query. If omitted, returns all recipes.
- `mode` (string, optional): `ingredients` (default) or `title`.
- `page` (integer, optional): page number.
- `per_page` (integer, optional): items per page.

**Response:**

```json
{
  "recipes": [
    {
      "id": 1,
      "title": "Recipe Title",
      "ratings": "4.5",
      "image_url": "https://...",
      "cook_time": 15,
      "prep_time": 10,
      "author": { "id": 2, "name": "Author" },
      "category": { "id": 3, "name": "Category" },
      "ingredients": ["1 pound ground beef", "mushrooms", "1 cup sour cream"]
    }
  ],
  "pagination": {
    "current_page": 1,
    "next_page": 2,
    "prev_page": null,
    "total_pages": 42,
    "total_count": 500
  }
}
```

## 2. Get Recipe

**GET** `/recipes/{id}`

Returns a single recipe with detailed fields.

**Response:**

```json
{
  "id": 123,
  "title": "Recipe Title",
  "ratings": "4.5",
  "image_url": "https://...",
  "cook_time": 15,
  "prep_time": 10,
  "author": { "id": 2, "name": "Author" },
  "category": { "id": 3, "name": "Category" },
  "ingredients": ["eggs", "mushrooms", "butter"],
  "cuisine": { "id": 4, "name": "Cuisine" },
  "short_description": "...",
  "instructions": "..."
}
```

## 3. Unknown Route

Return a JSON error for non-existing routes.

**Response:**

```json
{
  "error": {
    "message": "Endpoint not found."
  }
}
```
