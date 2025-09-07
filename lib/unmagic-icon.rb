# frozen_string_literal: true

require "unmagic/icon/version"
require "unmagic/icon"
require "unmagic/icon/library"
require "unmagic/icon/scanner"
require "unmagic/icon/gallery"
require "unmagic/icon/railtie" if defined?(Rails)
require "unmagic/icon/engine" if defined?(Rails)
