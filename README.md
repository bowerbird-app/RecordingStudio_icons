# RecordingStudioIcons

RecordingStudioIcons is a configuration-driven icon registry for Ruby and Rails apps.
It was designed to support `RecordingStudio` recordables, but it works with any class or
type name that wants to register a default icon while keeping rendering delegated to
library-specific renderers.

## Installation

Add the gem to your application:

```ruby
gem "recording_studio_icons"
```

Then install it:

```bash
bundle install
bin/rails generate recording_studio_icons:install
```

The install generator does three things:

- mounts the engine at `/recording_studio_icons`
- creates `config/initializers/recording_studio_icons.rb`
- adds the engine view path to `app/assets/tailwind/application.css` when Tailwind is present

The generated initializer looks like this:

```ruby
Rails.application.config.recording_studio_icons = {
  default_library: :heroicons,
  override_icons: {
    "Workspace" => {
      name: "document-text",
      variant: :outline
    }
  },
  fallback_icon: {
    name: "rectangle-stack",
    variant: :outline
  }
}
```

Default icons should be registered with the owning class or addon in Ruby code. The initializer is for
host-app overrides and global settings.

If you prefer not to use the generator, you can add the mount and initializer manually.

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

```ruby
# config/initializers/recording_studio_icons.rb
Rails.application.config.recording_studio_icons = {
  default_library: :heroicons,
  default_variant: :solid
}
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

For Rails apps, prefer `Rails.application.config.recording_studio_icons = { ... }` in an initializer.
`RecordingStudioIcons.configure` remains useful for tests and non-Rails usage.

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

For normal host-app setup, use a Rails initializer for host-owned settings:

- `config/initializers/recording_studio_icons.rb`

Register `default_icons` in the owning model, class, or addon code with `register_default_icon`.
Use the initializer for `override_icons`, `fallback_icon`, `default_library`, `default_variant`, and
`raise_on_missing_renderer`.

The runtime Ruby API remains available for advanced extensions and tests, but it is not a
separate automatic load source.

## Engine integration

The engine automatically:

- includes `RecordingStudioIcons::ViewHelper` in controllers via `helper RecordingStudioIcons::ViewHelper`
- merges `Rails.application.config.recording_studio_icons` after Rails loads initializers
- runs lifecycle hooks before config merge, on configuration merge, and after initialization

In views, you can render through the helper instead of calling the registry directly:

```erb
<%= render_recording_studio_icon(Page, class: "h-5 w-5") %>
```

Hook registration lives on `RecordingStudioIcons.configuration.hooks`:

```ruby
RecordingStudioIcons.configuration.hooks.after_initialize do
  RecordingStudioIcons.register_renderer(:custom, MyCustomRenderer)
end
```

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

```ruby
# config/initializers/recording_studio_icons.rb
Rails.application.config.recording_studio_icons = {
  default_library: :heroicons,
  default_variant: :solid
}
```

Override a specific type with a concrete icon:

```ruby
# config/initializers/recording_studio_icons.rb
Rails.application.config.recording_studio_icons = {
  override_icons: {
    "MyAddon::Document" => {
      library: :custom,
      name: "marketing-document"
    }
  }
}
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

### Unknown icon library

- default behavior: return `nil`
- strict mode: raise `RecordingStudioIcons::MissingRendererError`

```ruby
# config/initializers/recording_studio_icons.rb
Rails.application.config.recording_studio_icons = {
  raise_on_missing_renderer: true
}
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

Then sign in at `http://localhost:3000` with:

- Email: `admin@admin.com`
- Password: `Password`

The dummy app root path contains the richer registry demo and guide pages. The mounted engine
home page is also available at `http://localhost:3000/recording_studio_icons`.

## Cloud Agent boot

Cloud Agent Builds run `.cursor/install.sh`, then `.cursor/fetch-skills.sh`.
The install hook provisions a cold image. On a warm snapshot it skips apt,
ruby-build, db:prepare, and tailwind when Ruby, bundle, and Postgres are
already usable. Fetch-skills always runs last. `.cursor/start.sh` starts
PostgreSQL on each boot. Rebuild with Draft off to load a new pack. See
[Cursor skills in Cloud Agents](docs/cursor-skills.md).

## Archival template docs

The files under `docs/gem_template/` are preserved template documentation from the source gem
template. They are architecture reference only and do not describe the current
`recording_studio_icons` installation or API surface.
