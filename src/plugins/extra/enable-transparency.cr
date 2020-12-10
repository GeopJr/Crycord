require "http/client"
require "json"

# Disabled till mutter support (or I switch to kwin/compiz/whatever)
module Crycord
  plugin = Plugin.new("enable_transparency", "extra", "Enables glasscord support", true)
  Crycord::PLUGINS[plugin.name] = plugin unless plugin.disabled

  module Plugins
    module ENABLE_TRANSPARENCY
      extend self

      private def latest_artifact(version : String | Nil = "latest") : String
        latest_glasscord = "v0.9999.9999"
        url = "https://github.com/AryToNeX/Glasscord/releases/download/#{version}/glasscord.asar"
        if version == "latest"
          response = HTTP::Client.get "https://api.github.com/repos/AryToNeX/Glasscord/releases/latest"
          latest_artifact(latest_glasscord) unless response.status_code == 200 | response.status_code == 304
          value = JSON.parse(response.body).as_h
          assets = value["assets"]
          latest_artifact(latest_glasscord) unless assets.size >= 1
          url = assets[0]["browser_download_url"].to_s
        end
        return url
      end

      def download(path : Path) : Path
        glasscord_location = path.join("glasscord.asar")
        response = HTTP::Client.get(latest_artifact)
        HTTP::Client.get(response.headers["Location"]) do |res|
          File.write(glasscord_location.to_s, res.body_io)
        end
        return glasscord_location
      end

      # Path to extracted asar
      def execute : Bool
        app_path = PATHS["asar"].parent
        app_dir = app_path.join("core")
        Dir.mkdir_p(app_dir.to_s)
        app = app_path.join("core.asar")
        asar = Asar::Extract.new app.to_s
        content = asar.get("/package.json")
        raise "package.json doesn't exist" if content.nil?
        packagejson = content.gets_to_end
        STDOUT.puts "Downloading Glasscord...".colorize(:yellow)
        glasscord_location = download(app_path)
        STDOUT.puts "Installing Glasscord...".colorize(:yellow)
        File.rename(glasscord_location.to_s, app_dir.join("glasscord.asar").to_s)
        File.write(app_dir.join("package.json"), packagejson.sub("app_bootstrap/index.js", "./glasscord.asar"))
        true
      end
    end
  end
end
