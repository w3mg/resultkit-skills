# Quickstart: rkit:board

## Prerequisites

1. Run `/rkit:setup` to configure API token and default team
2. Know an item ID that has children (this will be your "board")

## Usage

### View a board

```
/rkit:board 10
```

Shows item 10's children as columns with their items underneath.

### View with default board

```
/rkit:board
```

Uses `default_board_id` from config, or prompts for an ID.

### View single column

```
/rkit:board 10 Engineering
/rkit:board 10 42
```

### Move item between columns

```
/rkit:board move 55 43
```

Moves item 55 to column 43 (confirms before executing).

### Add item to column

```
/rkit:board add 10 42 "New task"
/rkit:board add 10 "New task"
```

Second form prompts for column selection.

### Remove item from column

```
/rkit:board remove 55
```

Prompts with options: remove from all projects, move to another project, or move to a one-on-one/other source.

## Config

Optional `default_board_id` in `~/.config/resultkit/config.json`:

```json
{
  "default_board_id": 42
}
```

Set to `"ask"` to be prompted for confirmation each time.
