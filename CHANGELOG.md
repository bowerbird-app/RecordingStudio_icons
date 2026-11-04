# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.3] - 2026-11-04

Dummy app pins Recording Studio and FlatPack to current git tags so the lockfile
resolves Rails 8.1.4. The icon registry API is unchanged.

### Changed
- Dummy `Gemfile` pins `recording_studio` to tag `v6.3.0` and `flat_pack` to tag `v0.1.341`.
- Regenerated root and dummy `Gemfile.lock` files so Bundler resolves Rails 8.1.4.
- Dummy Recording Studio config matches 6.3.0 (`include_children` removed; `Workspace`, `Folder`, and `Page` declare `recording_studio_recordable`).
- Dummy Access demo row resolves the type name as a string because Access is no longer in core.
- Dummy demo table uses FlatPack Table `style: :plain` (inline CSS `style:` is no longer valid).

### Upgrade notes
- Hosts do not need to change. The public registry API is unchanged.
- Dummy-app development should `bundle install` in `test/dummy` after pulling this version so the tagged Recording Studio and FlatPack sources match the lockfile.

[Unreleased]: https://github.com/bowerbird-app/recording_studio_icons/compare/v0.1.3...HEAD
[0.1.3]: https://github.com/bowerbird-app/recording_studio_icons/compare/v0.1.2...v0.1.3

## [0.1.2] - 2026-11-02

Hygiene for the icon registry tests, dummy docs, and coverage artifacts. Icon resolution and rendering behavior are unchanged.

### Changed
- Updated the README to document the actual `recording_studio_icons:install` generator flow, generated initializer, engine helper integration, and hook lifecycle.
- Clarified that `docs/gem_template/` is archival template documentation and does not describe the current `RecordingStudioIcons` public API or setup.
- Replaced stale migration notes with a current repository-status summary.
- `IconReference` shares one private `blank?` helper for class and instance checks.
- Dummy README matches the demo (built-in `:heroicons` only).
- Root Gemfile comment names `recording_studio_icons.gemspec`.
- Registry isolation in tests now saves the original singleton in `test/test_helper.rb` and restores it on teardown.

### Removed
- Stopped tracking root and dummy coverage reports. `.gitignore` now covers `coverage/`.

### Upgrade notes
- Hosts do not need to change. The public registry API is unchanged.

## [0.1.1] - 2026-09-03

Cloud Agent Builds for this gem now match Billing 0.9.13. The icon registry,
renderers, and dummy demo are unchanged.

### Added
- `.cursor/fetch-skills.sh`, `.cursor/install.sh`, `.cursor/start.sh`, and
  `.cursor/environment.json` for Cloud Agent boot. Install skips apt,
  ruby-build, db:prepare, and tailwind when Ruby, bundle, and Postgres are
  already usable. A skippable provision failure does not fail the Build.
  Fetch-skills always runs last. Start only brings PostgreSQL up.

### Upgrade notes
- No host or schema changes. Rebuild the Cloud Agent environment with Draft
  off so Build loads the pack.

## [0.1.0] - 2025-12-04

### Added
- Initial release
- Configuration-driven icon registry for normalized type names
- Direct default and override icon registries with fallback resolution
- Structured `IconReference` and `ResolutionResult` value objects
- Built-in Heroicons renderer plus pluggable renderer registry support
- Rails engine integration with host-app config merge and view helper support
- Install generator for host applications and a dummy app demo
- Basic test suite with Minitest

[0.1.2]: https://github.com/bowerbird-app/recording_studio_icons/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/bowerbird-app/recording_studio_icons/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/bowerbird-app/recording_studio_icons/releases/tag/v0.1.0
