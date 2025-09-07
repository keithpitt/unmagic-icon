# frozen_string_literal: true

module Unmagic
  class Icon
    # Configuration for Unmagic::Icon including search paths for emoji packs.
    #
    # Example:
    #
    #   Unmagic::Icon.init do |config|
    #     config.paths = ["tmp/emojis", "app/assets/emojis"]
    #   end
    #
    class Configuration
      attr_accessor :paths

      def initialize
        @paths = []
      end
    end
  end
end
