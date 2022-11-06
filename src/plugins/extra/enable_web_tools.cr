module Crycord
  plugin = Plugin.new("enable_web_tools", "extra", "Enables web tools on Discord stable")
  Crycord::PLUGINS[plugin.name] = plugin unless plugin.disabled

  module Plugins
    module ENABLE_WEB_TOOLS
      extend self

      def execute : Bool
        settings_json = Path[""]
        PATHS["asar"].each_parent do |parent|
          settings_json = parent if parent.to_s.ends_with?("/config/discord")
        end
        settings_json = settings_json / "settings.json"

        raise "settings.json doesn't exist" unless File.exists?(settings_json)

        hash = JSON.parse(File.read(settings_json)).as_h
        hash["DANGEROUS_ENABLE_DEVTOOLS_ONLY_ENABLE_IF_YOU_KNOW_WHAT_YOURE_DOING"] = JSON::Any.new(true)

        File.write(settings_json, hash.to_json)
        true
      end
    end
  end
end
