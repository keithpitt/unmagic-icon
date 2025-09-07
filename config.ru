# config.ru
# frozen_string_literal: true

ENV['RACK_ENV'] ||= 'development'

require 'bundler/setup'
require 'rails'

require 'action_controller/railtie'
require 'action_view/railtie'

require_relative 'lib/unmagic-icon'

ICONS_PATH = File.join(__dir__, 'tmp/icons')

# Create icons directory if it doesn't exist
unless Dir.exist?(ICONS_PATH)
  require 'fileutils'
  FileUtils.mkdir_p(ICONS_PATH)
end

# Move any existing icons from the old location
old_path = File.join(__dir__, 'tmp/app/assets/icons')
if Dir.exist?(old_path)
  require 'fileutils'
  Dir.glob("#{old_path}/*").each do |library_dir|
    next unless File.directory?(library_dir)

    library_name = File.basename(library_dir)
    FileUtils.mv(library_dir, File.join(ICONS_PATH, library_name))
  end
  FileUtils.rm_rf(File.join(__dir__, 'tmp/app')) if Dir.exist?(File.join(__dir__, 'tmp/app'))
end

# Create a minimal Rails application for the icon browser
module IconGallerySandbox
  class Application < Rails::Application
    config.load_defaults 8.0

    config.middleware.delete Rails::Rack::Logger
    # Disable Rack::Lint to avoid header case issues
    config.middleware.delete Rack::Lint

    config.eager_load = false
    config.consider_all_requests_local = true
    config.secret_key_base = 'dev-secret-key-change-me'
    config.public_file_server.enabled = true

    config.cache_classes = false
    config.reload_classes_only_on_change = true

    # Set the root to our gem directory so Rails.root works correctly
    config.root = __dir__

    # Override the icon search paths to use our tmp directory
    def self.override_icon_paths!
      Unmagic::Icon.define_singleton_method(:search_paths) do
        [ [ nil, Pathname.new(ICONS_PATH) ] ]
      end

      # Clear library cache and force rediscovery
      Unmagic::Icon::Library.instance_variable_set(:@libraries, nil)
    end

    routes.append do
      mount Unmagic::Icon::Gallery => '/'
    end
  end
end

# Override icon paths before initialization
IconGallerySandbox::Application.override_icon_paths!

IconGallerySandbox::Application.initialize!
run IconGallerySandbox::Application
