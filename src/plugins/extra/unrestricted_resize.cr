module Crycord
  plugin = Plugin.new("unrestricted_resize", "extra", "Removes window size limits")
  Crycord::PLUGINS[plugin.name] = plugin unless plugin.disabled

  module Plugins
    module UNRESTRICTED_RESIZE
      extend self

      def execute : Bool
        mainScreen = PATHS["asar"].join("app", "mainScreen.js").to_s

        raise "mainScreen.js doesn't exist" unless File.exists?(mainScreen)

        File.write(mainScreen, File.read(mainScreen).sub("'MIN_WIDTH', 940", "'MIN_WIDTH', 0").sub("'MIN_HEIGHT', 500", "'MIN_HEIGHT', 0"))
        true
      end
    end
  end
end
