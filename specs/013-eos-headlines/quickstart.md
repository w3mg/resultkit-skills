# Quickstart: rkit:headlines

## Prerequisites

1. Run `/rkit:setup` to configure API token and default team
2. Your default team must use the EOS management framework

## Usage

### View headlines

```
/rkit:headlines
```

Shows all active headlines for your default team.

### View headlines for a specific team

```
/rkit:headlines --team 908
```

### Add a headline

```
/rkit:headlines add "New client signed this week"
```

Creates a headline with default expiration (7 days from today). Confirms before creating.

### Add with custom expiration

```
/rkit:headlines add "Office lease renewed" --expires 2026-03-15
```

### Archive (remove) a headline

```
/rkit:headlines remove 201
```

Archives headline 201 (sets expiration to today). Confirms before archiving.

### Update headline text

```
/rkit:headlines update 201 --text "Updated headline text"
```

### Update expiration date

```
/rkit:headlines update 201 --expires 2026-03-20
```

### Update both text and expiration

```
/rkit:headlines update 201 --text "New text" --expires 2026-03-20
```

## Notes

- Headlines are only available for teams using the EOS framework
- Archived headlines may still appear for up to 7 days if recently created (API visibility rule)
- Only the headline creator or a team admin can update or archive a headline
