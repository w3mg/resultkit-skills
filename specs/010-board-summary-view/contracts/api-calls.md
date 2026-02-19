# API Contracts: Board Summary View

No new API calls. Same calls as 003-board View Board flow:

| Step | Method | Path | Body |
|------|--------|------|------|
| Fetch columns | GET | `/items/{board_id}/children?per_page=50` | — |
| Fetch column items (×N) | GET | `/items/{column_id}/children?per_page=50` | — |

The only change is what happens after the data is fetched: display summary first, then ask user before showing item detail.
