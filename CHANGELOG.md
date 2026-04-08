# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- Updated the README to document the actual `recording_studio_icons:install` generator flow, generated initializer, engine helper integration, and hook lifecycle.
- Clarified that `docs/gem_template/` is archival template documentation and does not describe the current `RecordingStudioIcons` public API or setup.
- Replaced stale migration notes with a current repository-status summary.

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

[Unreleased]: https://github.com/bowerbird-app/recording_studio_icons/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/bowerbird-app/recording_studio_icons/releases/tag/v0.1.0
