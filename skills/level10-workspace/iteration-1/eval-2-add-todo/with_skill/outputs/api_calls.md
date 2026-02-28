# API Calls

## 1. EOS Framework Gate — GET /teams/345

**Request:**
```
GET /teams/345
```

**Response (status 200):**
```json
{
  "data": {
    "id": 345,
    "name": "ResultMaps Incorporated",
    "description": "",
    "framework": "eos",
    "creator": {
      "id": 1,
      "login": "scottilevy",
      "first_name": "Scott",
      "last_name": "Levy"
    },
    "created_at": "2017-02-15T23:47:01.000Z",
    "updated_at": "2025-07-01T12:49:36.000Z",
    "members": [
      {"id": 403, "user": {"id": 1, "login": "scottilevy", "first_name": "Scott", "last_name": "Levy"}, "role": "admin"},
      {"id": 739, "user": {"id": 591, "login": "PatrickAngodung", "first_name": "Patrick", "last_name": "Angodung"}, "role": "admin"},
      {"id": 3179, "user": {"id": 2088, "login": "Shannon", "first_name": "Shannon", "last_name": "Arnold"}, "role": "member"},
      {"id": 3202, "user": {"id": 1049, "login": "kahlillevy", "first_name": "", "last_name": ""}, "role": "admin"},
      {"id": 3943, "user": {"id": 2266, "login": "MaryMejia", "first_name": "Mary", "last_name": "Mejia"}, "role": "admin"}
    ]
  }
}
```

**Result:** Framework is `"eos"` — gate passed. Team name: "ResultMaps Incorporated".

---

## 2. Create To-Do — POST /teams/345/l10/todos

**Request:**
```
POST /teams/345/l10/todos
Body: {"name": "Review quarterly metrics"}
```

**Response (status 201):**
```json
{
  "data": {
    "id": 211427,
    "name": "Review quarterly metrics #next",
    "description": null,
    "due": "2026-03-07",
    "status": "next",
    "on_weekly": true,
    "team": {
      "id": 345,
      "name": "ResultMaps Incorporated"
    },
    "creator": {
      "id": 1,
      "login": "scottilevy",
      "first_name": "Scott",
      "last_name": "Levy"
    },
    "assignees": [],
    "parent_id": null,
    "created_at": "2026-02-28T20:41:46.000Z",
    "updated_at": "2026-02-28T20:41:46.000Z"
  }
}
```

**Result:** To-do created successfully with ID 211427, due 2026-03-07.
