module Crycord
  plugin = Plugin.new("enable_css", "core", "Enables css injection", true)
  Crycord::PLUGINS[plugin.name] = plugin unless plugin.disabled

  module Plugins
    module ENABLE_CSS
      extend self

      # https://github.com/leovoel/BeautifulDiscord/
      @@patch_1 = <<-STRING
            window._fileWatcher = null;
            window._styleTag = {};
            window.applyCSS = function(path, name) {
              var customCSS = window.Crycord.loadFile(path);
              if (!window._styleTag.hasOwnProperty(name)) {
                window._styleTag[name] = document.createElement("style");
                document.head.appendChild(window._styleTag[name]);
              }
              window._styleTag[name].innerHTML = customCSS;
            }
            window.clearCSS = function(name) {
              if (window._styleTag.hasOwnProperty(name)) {
                window._styleTag[name].innerHTML = "";
                window._styleTag[name].parentElement.removeChild(window._styleTag[name]);
                delete window._styleTag[name];
              }
            }
            window.watchCSS = function(path) {
              if (window.Crycord.isDirectory(path)) {
                files = window.Crycord.readDir(path);
                dirname = path;
              } else {
                files = [window.Crycord.basename(path)];
                dirname = window.Crycord.dirname(path);
              }
              for (var i = 0; i < files.length; i++) {
                var file = files[i];
                if (file.endsWith(".css")) {
                  window.applyCSS(window.Crycord.join(dirname, file), file)
                }
              }
              if(window._fileWatcher === null) {
                window._fileWatcher = window.Crycord.watcher(path,
                  function(eventType, filename) {
                    if (!filename.endsWith(".css")) return;
                    path = window.Crycord.join(dirname, filename);
                    if (eventType === "rename" && !window.Crycord.pathExists(path)) {
                      window.clearCSS(filename);
                    } else {
                      window.applyCSS(window.Crycord.join(dirname, filename), filename);
                    }
                  }
                );
              }
            };
            window.tearDownCSS = function() {
              for (var key in window._styleTag) {
                if (window._styleTag.hasOwnProperty(key)) {
                  window.clearCSS(key)
                }
              }
              if(window._fileWatcher !== null) { window._fileWatcher.close(); window._fileWatcher = null; }
            };
            window.removeDuplicateCSS = function(){
            	const styles = [...document.getElementsByTagName("style")];
            	const styleTags = window._styleTag;
            	for(let key in styleTags){
            		for (var i = 0; i < styles.length; i++) {
            			const keyStyle = styleTags[key];
            			const curStyle = styles[i];
            			if(curStyle !== keyStyle) {
            				const compare	 = keyStyle.innerText.localeCompare(curStyle.innerText);
            				if(compare === 0){
            					const parent = curStyle.parentElement;
            					parent.removeChild(curStyle);
            				}
            			}
            		}
            	}
            };
            window.applyAndWatchCSS = function(path) {
              window.tearDownCSS();
              window.watchCSS(path);
            };
            window.applyAndWatchCSS('<%- crycord_css %>');
            window.removeDuplicateCSS();
     STRING

      @@patch_2 = <<-STRING
           mainWindow.webContents.on('dom-ready', function () {
           mainWindow.webContents.executeJavaScript(`<%- crycord_patch1 %>`);
                 });


    STRING

      @@patch_3 = <<-STRING
            const bd_fs = require('fs');
            const bd_path = require('path');
            contextBridge.exposeInMainWorld('Crycord', {
                loadFile: (fileName) => {
                    return bd_fs.readFileSync(fileName, 'utf-8');
                },
                readDir: (p) => {
                    return bd_fs.readdirSync(p);
                },
                pathExists: (p) => {
                    return bd_fs.existsSync(p);
                },
                watcher: (p, cb) => {
                    return bd_fs.watch(p, { encoding: "utf-8" }, cb);
                },
                join: (a, b) => {
                    return bd_path.join(a, b);
                },
                basename: (p) => {
                    return bd_path.basename(p);
                },
                dirname: (p) => {
                    return bd_path.dirname(p);
                },
                isDirectory: (p) => {
                    return bd_fs.lstatSync(p).isDirectory()
                }
            });
            process.once('loaded', () => {
                global.require = require;


    STRING

      def execute(path : Path, css : String | Nil) : Bool
        return false if css.nil?
        mainScreen = path.join("app", "mainScreen.js").to_s
        mainScreenPreload = path.join("app", "mainScreenPreload.js").to_s

        raise "mainScreen.js doesn't exist" unless File.exists?(mainScreen)
        raise "mainScreenPreload.js doesn't exist" unless File.exists?(mainScreenPreload)

        File.write(mainScreenPreload, File.read(mainScreenPreload).sub("process.once('loaded', () => {", @@patch_3))

        mainScreen_content = File.read(mainScreen)
        index = mainScreen_content.index("mainWindow.on('blur'")

        raise "mainScreen.js is missing important info" if index.nil?

        range = index == 0 ? 0 : index - 1
        css_patch = @@patch_1.sub("<%- crycord_css %>", Path[css].expand(home: true).to_s)
        gen_patch_2 = @@patch_2.sub("<%- crycord_patch1 %>", css_patch)

        gen_patch_4 = (mainScreen_content[0..range] + gen_patch_2 + mainScreen_content[range..-1]).sub("nodeIntegration: false", "nodeIntegration: true")
        File.write(mainScreen, gen_patch_4)
        true
      end
    end
  end
end
