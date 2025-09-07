---unmagic/docs
category: Icons
---

# Icon Libraries

Detailed information about icon libraries and management.

## Library Structure

Each icon library is a directory containing SVG files:

```
app/assets/icons/
├── feather/
│   ├── home.svg
│   ├── settings.svg
│   └── user.svg
├── heroicons/
│   ├── outline/
│   │   ├── home.svg
│   │   └── cog.svg
│   └── solid/
│       ├── home.svg
│       └── cog.svg
```

## Engine Libraries

Rails engines can provide their own icon libraries by including icons in their asset paths. Engine icons are referenced with the engine namespace:

```ruby
# Application icon
Unmagic::Icon.find("feather/home")

# Engine icon
Unmagic::Icon.find("my_engine:feather/home")
```

## Library Management

### Listing Libraries

```ruby
# Get all available libraries
Unmagic::Icon.libraries
#=> { "feather" => #<Library>, "heroicons" => #<Library> }

# Check if library exists
Unmagic::Icon.library_exists?("feather")
#=> true
```

### Library Information

```ruby
library = Unmagic::Icon.libraries["feather"]
library.icons.count  # Number of icons in library
library.icon_names   # Array of icon names
```

## Best Practices

1. **Consistent Naming**: Use lowercase names with hyphens for multi-word icons
2. **SVG Optimization**: Ensure SVGs are optimized and don't contain unnecessary metadata
3. **Accessibility**: Provide meaningful `aria_label` attributes when rendering
4. **Organization**: Group related icons into logical libraries
