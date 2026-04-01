# RecordingStudioIcons dummy app

This dummy app demonstrates `recording_studio_icons` end-to-end with the real public API.

## What the demo shows

- addon-style default icon tokens and default icon references
- host app token mapping through `icon_token_map`
- explicit host overrides that beat addon defaults
- fallback icon behavior
- renderer dispatch across multiple libraries (`:heroicons` and a dummy `:custom` renderer)
- FlatPack components for the demo UI (`PageTitle`, `Alert`, `Card`, and `Table`)

## Run the dummy app

```bash
cd test/dummy
bin/rails db:setup
bin/dev
```

Then sign in at `http://localhost:3000` with:

- Email: `admin@admin.com`
- Password: `Password`

The home page is the icon registry demo.
