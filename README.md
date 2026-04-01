# RecordingStudioIcons

RecordingStudioIcons is a configuration-driven icon registry addon for `RecordingStudio`.
It lets addon authors register semantic icon intent per recordable type while leaving the
host application in control of the actual icon library and rendered output.

## Why this addon exists

`RecordingStudio` already normalizes recordable types to class-name strings. This addon builds on
that pattern and adds a registry that can answer a single question:

> Which icon should represent this recordable type?

The registry is intentionally **configuration-backed**, not database-backed.

## Core concepts

### 1. Semantic icon tokens (preferred for addons)

Addons should usually express intent with semantic tokens:

```ruby
RecordingStudioIcons.register_default_icon_token MyAddon::Document, :document
RecordingStudioIcons.register_default_icon_token MyAddon::Folder, :folder
```

Semantic tokens let the addon say _what kind of thing this is_ without forcing the host app to use a
specific icon library.

### 2. Structured icon references (used for rendering and explicit overrides)

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

Plain strings and symbols are also supported. They normalize through `default_library`:

```ruby
RecordingStudioIcons.configure do |config|
  config.default_library = :heroicons
end

RecordingStudioIcons.register_default_icon "MyAddon::Document", :document_text
# => #<IconReference library=:heroicons name="document-text">
```

## Resolution precedence

Resolution is explicit and deterministic:

1. host override icon reference for type
2. host override icon token for type, mapped through `icon_token_map`
3. addon/default icon reference for type
4. addon/default icon token for type, mapped through `icon_token_map`
5. fallback icon reference
6. `nil`

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
RecordingStudioIcons.register_default_icon_token(type, token)
RecordingStudioIcons.register_override_icon_token(type, token)
RecordingStudioIcons.map_icon_token(token, icon_ref)
RecordingStudioIcons.register_renderer(library, renderer)
RecordingStudioIcons.render_icon(view_context, recordable_or_type, **options)
```

## Type normalization

Type input is normalized exactly the same way the addon needs for `RecordingStudio` integration:

- class constant → class name string
- string → string
- recordable instance → its class name string

No superclass fallback is applied.

## Configuration reference

`RecordingStudioIcons::Configuration` stores explicit registries for:

- `default_icon_tokens`
- `override_icon_tokens`
- `default_icons`
- `override_icons`
- `icon_token_map`
- `fallback_icon`
- `default_library`
- `raise_on_missing_renderer`
- `raise_on_missing_token_mapping`

The engine also follows the same configuration-loading shape as `RecordingStudio`:

- `config/recording_studio_icons.yml`
- `config.x.recording_studio_icons`
- initializer-based overrides

## For addon authors

Prefer semantic tokens:

```ruby
RecordingStudioIcons.register_default_icon_token MyAddon::Document, :document
RecordingStudioIcons.register_default_icon_token MyAddon::Comment, :comment
```

Use direct icon references only when you genuinely need a concrete glyph regardless of host styling:

```ruby
RecordingStudioIcons.register_default_icon MyAddon::AuditTrail,
  library: :heroicons,
  name: "rectangle-stack",
  variant: :outline
```

Because overrides are tracked in dedicated stores, the host app can always replace addon defaults explicitly.

## For host app authors

Map tokens to your visual system:

```ruby
RecordingStudioIcons.configure do |config|
  config.default_library = :heroicons

  config.map_icon_token :document,
    library: :heroicons,
    name: "document-text",
    variant: :outline

  config.map_icon_token :folder,
    library: :custom,
    name: "app-folder"
end
```

Override a specific type with a concrete icon:

```ruby
RecordingStudioIcons.register_override_icon MyAddon::Document,
  library: :custom,
  name: "marketing-document"
```

Or override with a token while keeping the final library mapping centralized:

```ruby
RecordingStudioIcons.register_override_icon_token MyAddon::AudioClip, :document
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

```ruby
RecordingStudioIcons.configure do |config|
  config.raise_on_missing_renderer = true
end
```

### Missing token mapping behavior

- default behavior: continue to fallback icon or `nil`
- strict mode: raise `RecordingStudioIcons::MissingTokenMappingError`

```ruby
RecordingStudioIcons.configure do |config|
  config.raise_on_missing_token_mapping = true
end
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

- addon token defaults
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
