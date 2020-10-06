module Crycord
  plugin = Plugin.new("enable_https", "core", "Disables CSP")
  Crycord::PLUGINS[plugin.name] = plugin unless plugin.disabled

  module Plugins
    module ENABLE_HTTPS
      extend self

      # https://github.com/leovoel/BeautifulDiscord/
      @@patch_1 = <<-STRING
        // Crycord
        require("electron").session.defaultSession.webRequest.onHeadersReceived(({ responseHeaders }, done) => {
          let csp = responseHeaders["content-security-policy"];
          if (!csp) return done({cancel: false});
          let header = csp[0].replace(/connect-src ([^;]+);/, "connect-src $1 https://*;");
          header = header.replace(/style-src ([^;]+);/, "style-src $1 https://*;");
          header = header.replace(/img-src ([^;]+);/, "img-src $1 https://*;");
          responseHeaders["content-security-policy"] = header;
          done({ responseHeaders });
        });


    STRING

      def execute : Bool
        index_path = PATHS["asar"].join("app", "index.js").to_s
        raise "index.js doesn't exist" unless File.exists?(index_path)

        index = File.read(index_path)

        if index.includes?("// Crycord")
          puts "ERROR: Already patched"
          exit
        end

        File.write(index_path, @@patch_1 + index)
        true
      end
    end
  end
end
