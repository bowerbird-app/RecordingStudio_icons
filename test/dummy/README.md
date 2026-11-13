# RecordingStudioIcons dummy app

This dummy app demonstrates `recording_studio_icons` end-to-end with the real public API.

## What the demo shows

- addon-style default icon references
- explicit host overrides that beat addon defaults
- fallback icon behavior
- renderer dispatch through the built-in `:heroicons` renderer (the demo does not register a `:custom` renderer)
- FlatPack components for the demo UI (`PageTitle`, `Alert`, `Card`, and `Table`)
- Access is shown as the type name `RecordingStudio::Access` (core 6.3.0 no longer ships that model)

The dummy `Gemfile` pins `recording_studio` to git tag `v6.7.0` and `flat_pack` to git tag `v0.1.356`. After a pull, run `bundle install` here so those tags match the lockfile.

## Run the dummy app

```bash
cd test/dummy
bin/rails db:setup
bin/dev
```

Then sign in at `http://localhost:3000` with:

- Email: `admin@admin.com`
- Password: `Password`

The home page is the icon registry demo. The gem engine is mounted at
`/recording_studio_icons` and uses Recording Studio's default layout.
