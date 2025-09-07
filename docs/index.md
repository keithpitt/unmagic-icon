---unmagic/docs
category: Icons
---

# Icon Libraries

The Unmagic::Icon engine provides SVG icon management for your application.

## Features

- Library-based organization of icons
- Engine-specific icon support
- Automatic SVG attribute management
- CSS class integration
- Accessibility support with ARIA labels

## Usage

### Finding Icons

```ruby
# Find an icon from a library
icon = Unmagic::Icon.find("feather/home")

# Find engine-specific icon
icon = Unmagic::Icon.find("unmagic_ui:feather/settings")
```

### Rendering Icons

```ruby
# Basic rendering
icon.to_svg
#=> "<svg class='unmagic-icon[feather] fill-current' role='img'>...</svg>"

# With custom classes
icon.to_svg(class: "w-5 h-5 text-blue-500")
#=> "<svg class='unmagic-icon[feather] fill-current w-5 h-5 text-blue-500'>...</svg>"

# With accessibility label
icon.to_svg(aria_label: "Home page")
#=> "<svg aria-label='Home page' role='img'>...</svg>"
```

## Icon Libraries

Icons are organized into libraries stored in `app/assets/icons/[library_name]/`. Each library is a directory containing SVG files.

### Available Libraries

The system automatically discovers icon libraries from:
- Application icons in `app/assets/icons/`
- Engine icons from Rails engines

### Adding Custom Icons

1. Create a directory under `app/assets/icons/`
2. Add SVG files to the directory
3. Icons will be automatically available as `library_name/icon_name`
