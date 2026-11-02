# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.2] - 2026-11-02

Hygiene for the icon registry tests, dummy docs, and coverage artifacts. Icon resolution and rendering behavior are unchanged.

### Added
- Public `RecordingStudioIcons.reset_registry!` so tests can isolate the singleton registry without reading private instance variables.

### Changed
- `IconReference` shares one private `blank?` helper for class and instance checks.
- Dummy README matches the demo (built-in `:heroicons` only).
- Dummy Tailwind `@source` for FlatPack is bundle-relative (`vendor/bundle/**/flatpack-*`) instead of a hard-coded `/usr/local/bundle` SHA path.
- Root Gemfile comment names `recording_studio_icons.gemspec`.

### Removed
- Stopped tracking root and dummy coverage reports. `.gitignore` now covers `coverage/`.

### Upgrade notes
- Hosts do not need to change. `reset_configuration!` and `reset_renderers!` still reset the current registry. `reset_registry!` replaces that registry with a new one. Tests that poked `@registry` should call `reset_registry!` instead.

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

[Unreleased]: https://github.com/bowerbird-app/recording_studio_icons/compare/v0.1.2...HEAD
[0.1.2]: https://github.com/bowerbird-app/recording_studio_icons/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/bowerbird-app/recording_studio_icons/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/bowerbird-app/recording_studio_icons/releases/tag/v0.1.0
