# Migration Notes

This file is now historical status documentation for the repository, not an active checklist.

## Current status

- The repository is already on the public-gem setup.
- The dummy app already uses FlatPack.
- The current host-app configuration path is `Rails.application.config.recording_studio_icons = { ... }`.
- The current install path is documented in `README.md` and exercised by the install generator.

## Current sources of truth

- `README.md` documents installation, configuration, rendering, and hook integration.
- `test/dummy/README.md` documents the runnable demo app.
- `docs/gem_template/` remains preserved template-reference material only.

## If you are updating an older fork

Use this short checklist instead of the old migration steps:

1. Replace any leftover template-era setup with `recording_studio_icons` naming and configuration.
2. Move host configuration into `config/initializers/recording_studio_icons.rb`.
3. Remove any legacy private-gem or `makeup_artist` instructions that no longer apply.
4. Run the dummy app and test suite to confirm the fork matches current repository behavior.
