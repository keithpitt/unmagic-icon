# frozen_string_literal: true

module Unmagic
  class Icon
    class Railtie < Rails::Railtie
      # Preload icon libraries on boot in all environments
      # Libraries don't change often, so restart for new libraries is reasonable
      config.after_initialize do
        Unmagic::Icon.preload!
      end
      
      rake_tasks do
        namespace :unmagic do
          namespace :icons do
            desc "Scan codebase for icon usage and build icons.txt"
            task build: :environment do
              Unmagic::Icon::Scanner.write!
            end

            desc "Show icon usage statistics"
            task stats: :environment do
              Unmagic::Icon::Scanner.stats
            end

            desc "Watch for changes and rebuild icons.txt (requires listen gem)"
            task watch: :environment do
              system("bundle exec rails unmagic:icons:watch:poll")
            end

            desc "Download popular icon libraries"
            task :download, [ :library, :force ] => :environment do |task, args|
              require_relative "downloader"

              library = args[:library]&.strip
              force = args[:force] == "force"

              if library.nil? || library.empty?
                puts "Error: Please specify a library to download"
                puts "Available libraries:"
                Unmagic::Icon::Downloader::LIBRARIES.each do |key, config|
                  puts "  #{key.to_s.ljust(15)} - #{config[:description]}"
                end
                puts "\nUsage: rails unmagic:icons:download[heroicons]"
                puts "       rails unmagic:icons:download[silk,force]"
                exit 1
              end

              puts "Downloading #{library}..."
              Unmagic::Icon::Downloader.download(library.to_sym, force: force)

              # Run build task to update icons.txt
              puts "\nUpdating icons.txt..."
              Rake::Task["unmagic:icons:build"].invoke
            end

            namespace :watch do
              desc "Watch for changes with polling"
              task poll: :environment do
                require "listen"

                puts "[unmagic-icon] Watching for changes..."
                Unmagic::Icon::Scanner.write!

                # Watch source code for icon usage changes
                source_directories = [
                  Rails.root.join("app"),
                  Rails.root.join("lib"),
                  Rails.root.join("spec"),
                  Rails.root.join("test")
                ].select { |d| d.exist? }

                source_listener = Listen.to(
                  *source_directories,
                  only: /\.(rb|erb|html|haml|slim)$/,
                  force_polling: ENV["UNMAGIC_ICONS_WATCH_POLL"].present?
                ) do |modified, added, removed|
                  if (modified + added + removed).any?
                    puts "[unmagic-icon] Source files changed, rescanning for icon usage..."
                    Unmagic::Icon.clear_known_icons!
                    Unmagic::Icon::Scanner.write!
                  end
                end

                # Watch icon files for changes
                icons_directory = Rails.root.join("app/assets/icons")
                icons_listener = nil
                if icons_directory.exist?
                  icons_listener = Listen.to(
                    icons_directory,
                    only: /\.svg$/,
                    force_polling: ENV["UNMAGIC_ICONS_WATCH_POLL"].present?
                  ) do |modified, added, removed|
                    if (modified + added + removed).any?
                      puts "[unmagic-icon] Icon files changed, clearing library cache..."
                      # Clear library cache to pick up new/changed/deleted SVG files
                      Unmagic::Icon.instance_variable_set(:@libraries, nil)
                      Unmagic::Icon.clear_known_icons!
                      Unmagic::Icon::Scanner.write!
                    end
                  end
                end

                source_listener.start
                icons_listener&.start

                sleep
              rescue Interrupt
                puts "\n[unmagic-icon] Stopping watcher."
                source_listener&.stop
                icons_listener&.stop
              end
            end
          end
        end
      end
    end
  end
end
