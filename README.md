# RecordingStudioIcons

RecordingStudioIcons is a configuration-driven icon registry for Ruby and Rails apps.
It was designed to support `RecordingStudio` recordables, but it works with any class or
type name that wants to register a default icon while keeping rendering delegated to
library-specific renderers.

## Why this gem exists

`RecordingStudio` already normalizes recordable types to class-name strings. This gem builds on
that pattern and adds a registry that can answer a single question for any registered type:

> Which icon should represent this class or object type?

The registry is intentionally **configuration-backed**, not database-backed.

## What it works with

The registry resolves icons for normalized type names. In practice that means you can register
and resolve icons with:

- class constants
- class-name strings
- symbols that normalize through the default library
- instances of registered classes

It does not require a `RecordingStudio` interface or special database schema. If the type can be
normalized to a name and you register an icon for that name, the registry can resolve it.

## Core concepts

### 1. Structured icon references

Concrete icons are normalized into a structured `IconReference` with:

- `library`
- `name`
- `variant` (optional)
- `options` (optional)

Examples:

```ruby
{ library: :heroicons, name: "document-text", variant: :outline }
{ library: :lucide, name: "file-text" }
{ library: :custom, name: "app-document" }
```

Plain strings and symbols are also supported. They normalize through `default_library` and `default_variant`:

```yaml
# config/recording_studio_icons.yml
development:
  default_library: heroicons
  default_variant: solid
```

```ruby
RecordingStudioIcons.register_default_icon "MyAddon::Document", :document_text
# => #<IconReference library=:heroicons name="document-text" variant=:solid>
```

### 2. Type-based registries

The registry stores direct icon references keyed by normalized type names.
There are separate stores for addon defaults, host-app overrides, and one optional fallback icon.

## Resolution precedence

Resolution is explicit and deterministic:

1. host override icon reference for type
2. addon/default icon reference for type
3. fallback icon reference
4. `nil`

Use `RecordingStudioIcons.resolve_icon(recordable_or_type)` to get the final normalized icon reference.
Use `RecordingStudioIcons.resolve_icon_details(recordable_or_type)` when you also want metadata such as
which precedence layer won.

## Public API

```ruby
RecordingStudioIcons.configure { |config| ... }
RecordingStudioIcons.resolve_icon(recordable_or_type)
RecordingStudioIcons.icon_for_type(type)
RecordingStudioIcons.register_default_icon(type, icon_ref)
RecordingStudioIcons.register_override_icon(type, icon_ref)
RecordingStudioIcons.register_renderer(library, renderer)
RecordingStudioIcons.render_icon(view_context, recordable_or_type, **options)
```

## Type normalization

Type input is normalized to a class-name string:

- class constant → class name string
- string → string
- symbol → string
- object instance → its class name string

No superclass fallback is applied.

## Configuration reference

`RecordingStudioIcons::Configuration` stores explicit registries for:

- `default_icons`
- `override_icons`
- `fallback_icon`
- `default_library`
- `default_variant`
- `raise_on_missing_renderer`

The engine also follows the same configuration-loading shape as `RecordingStudio`:

- `config/recording_studio_icons.yml`

For normal host-app setup, use the config file. The runtime Ruby API remains available for
advanced extensions and tests, but it is not a separate automatic load source.

## RecordingStudio integration

`RecordingStudio` is a natural fit because its recordables already resolve cleanly to class-name
strings. If you are using the gem with `RecordingStudio`, you can treat each recordable type as a
registered type in the icon registry.

## For addon authors

Register direct icon references per type:

```ruby
RecordingStudioIcons.register_default_icon MyAddon::Document,
  library: :heroicons,
  name: "document-text",
  variant: :outline
```

If the default library is enough, shorthand is also supported:

```ruby
RecordingStudioIcons.register_default_icon MyAddon::AuditTrail, :rectangle_stack
```

Because overrides are tracked in dedicated stores, the host app can always replace addon defaults explicitly.

For a plain Rails app, the same pattern works with any model class:

```ruby
RecordingStudioIcons.register_default_icon User, :user
RecordingStudioIcons.register_default_icon Invoice,
  library: :heroicons,
  name: "document-text",
  variant: :outline

RecordingStudioIcons.resolve_icon(User.new)
```

## For host app authors

Set the default library used for shorthand icon references:

```yaml
# config/recording_studio_icons.yml
development:
  default_library: heroicons
  default_variant: solid
```

Override a specific type with a concrete icon:

```yaml
# config/recording_studio_icons.yml
development:
  override_icons:
    MyAddon::Document:
      library: custom
      name: marketing-document
```

## Rendering and custom renderers

Resolution and rendering are intentionally separate.

```ruby
icon = RecordingStudioIcons.resolve_icon(record)
RecordingStudioIcons.render_icon(self, record, class: "h-5 w-5")
```

Register renderers by library key:

```ruby
RecordingStudioIcons.register_renderer :heroicons, RecordingStudioIcons::Renderers::Heroicons
RecordingStudioIcons.register_renderer :custom, MyCustomRenderer
```

Renderers must implement:

```ruby
render(view_context, icon_reference, **options)
```

### Missing renderer behavior

- default behavior: return `nil`
- strict mode: raise `RecordingStudioIcons::MissingRendererError`

```yaml
# config/recording_studio_icons.yml
development:
  raise_on_missing_renderer: true
```

## Heroicons and non-Heroicons support

The gem ships with a small built-in Heroicons renderer for demo-ready usage, but the registry is not Heroicons-only.
Any library key can be registered, including internal systems:

```ruby
RecordingStudioIcons.register_renderer :custom, MyApp::IconRenderer
RecordingStudioIcons.register_override_icon MyAddon::Folder,
  library: :custom,
  name: "workspace-folder"
```

## Dummy app demo

The dummy app intentionally uses FlatPack components wherever practical.
It demonstrates:

- addon concrete defaults
- host overrides
- fallback behavior
- multi-library rendering (`:heroicons` plus a custom renderer)
- resolved metadata shown in the UI

Run it with:

```bash
cd test/dummy
bin/rails db:setup
bin/dev
```

Sign in with:

- Email: `admin@admin.com`
- Password: `Password`

The home page contains the demo table and precedence explanation.
