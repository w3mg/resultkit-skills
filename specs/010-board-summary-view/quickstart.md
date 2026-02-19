# Quickstart: Board Summary View

## What changed

`/rkit:board` now shows a column summary first, then asks before showing item detail.

## Before

```
/rkit:board 203813
```
→ Immediately dumps all columns with all their items.

## After

```
/rkit:board 203813
```
→ Shows:

```
Board: 203813

| # | Column       | ID     | Items |
|---|-------------|--------|-------|
| 1 | Might fix   | 203827 | 0     |
| 2 | Must fix    | 203829 | 3     |
| 3 | NEXT        | 203831 | 7     |
| 4 | Done        | 203833 | 12    |
```

→ Then asks: view all columns, pick one, or none.

All other commands (`/rkit:board {id} {column}`, `move`, `add`, `remove`) work exactly the same.
