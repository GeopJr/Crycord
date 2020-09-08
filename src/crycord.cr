require "option_parser"
require "asar-cr"
require "./version.cr"
require "./functions/*"
require "./locators/*"
require "./plugins/core/*"
require "./plugins/extra/*"

module Crycord
  extend self
  @@plugins : Array(String)
  @@available_groups : Array(String)

  @@plugins = Crycord::PLUGINS.keys.reject! { |x| Crycord::PLUGINS[x].disabled }
  @@available_groups = @@plugins.map { |x| x = Crycord::PLUGINS[x].category }.uniq
  css_path = ""
  asar_path = ""
  groups = ["core"]
  should_revert = false

  def get_paths : String
    path = flatpak
    if path.nil?
      path = linux
    else
      puts "Flatpak Detected:"
      puts "Make sure it has access to your CSS file"
      puts "Usually ~/Downloads is accessible"
    end
    if path.nil?
      puts "ERROR: couldn't find core.asar, try manually setting it using the -f flag."
      exit
    end
    return path.to_s
  end

  def group_list
    puts "Available plugin groups:"
    puts @@available_groups.join("\n")
    puts "Note: core is being installed by default"
  end

  # CLI options
  OptionParser.parse do |parser|
    parser.banner = "<== [Crycord] ==>"

    parser.on "-v", "--version", "Show version" do
      puts "Crycord"
      puts "Version: #{VERSION}"
      exit
    end
    parser.on "-h", "--help", "Show help" do
      puts parser
      exit
    end
    parser.on "-gs", "--groups", "Lists all available plugin groups" do
      group_list
      exit
    end
    parser.on "-r", "--revert", "Reverts back to original asar" do
      should_revert = true
    end
    parser.on "-p", "--plugins", "Lists all available plugins" do
      available_plugins = Crycord::PLUGINS.keys.map { |x| x = Crycord::PLUGINS[x].name + " | " + Crycord::PLUGINS[x].category + " | " + Crycord::PLUGINS[x].desc }.uniq
      puts "Available plugins:"
      puts "NAME | GROUP | DESCRIPTION"
      puts available_plugins.reject! { |x| Crycord::PLUGINS[x].disabled }.join("\n")
      puts "Note: Disabled plugins are omitted"
      exit
    end
    parser.on "-c CSS_PATH", "--css=CSS_PATH", "Sets CSS location" do |path|
      css = Path[path].expand(home: true)
      unless File.exists?(css)
        puts "ERROR: CSS file not found"
        exit
      end
      css_path = css.to_s
    end
    parser.on "-f CORE_ASAR_PATH", "--force=CORE_ASAR_PATH", "Forces an asar path" do |path|
      asar_path = Path[path].expand(home: true).to_s
      unless File.exists?(asar_path)
        puts "ERROR: core.asar not found"
        exit
      end
    end
    parser.on "-g PLUGIN_GROUP", "--group=PLUGIN_GROUP", "Selects the plugin group(s) to install. Split multiple groups with commas(,)." do |input|
      if input == "" || input.nil?
        group_list
      end
      groups.concat(input.downcase.gsub(" ", "").split(","))
      groups.uniq!
      groups.each do |item|
        unless @@available_groups.includes?(item)
          puts "ERROR: unknown group, use the -gs flag to list all groups."
          exit
        end
      end
    end

    parser.missing_option do |option_flag|
      STDERR.puts "ERROR: #{option_flag} is missing something."
      STDERR.puts ""
      STDERR.puts parser
      exit(1)
    end
    parser.invalid_option do |option_flag|
      STDERR.puts "ERROR: #{option_flag} is not a valid option."
      STDERR.puts parser
      exit(1)
    end
  end

  # Check revert
  if should_revert
    asar_path = get_paths if asar_path == ""
    res = revert(Path[asar_path])
    puts "Restore was #{res.nil? ? "un" : ""}successful"
    exit
  end

  # Check options
  if css_path == ""
    puts "ERROR: -c option is missing"
    exit
  end

  # Check discord and get paths
  asar_path = get_paths if asar_path == ""

  # Extract asar
  puts "Extracting core.asar..."
  path = extract(Path[asar_path])
  if path.nil?
    puts "ERROR: couldn't extract core.asar"
    exit
  end

  # See collector.cr
  modules = Crycord::Plugins.collected_modules
  selected_plugins = @@plugins.reject! { |x| !groups.includes?(Crycord::PLUGINS[x].category) }

  selected_plugins.each do |plugin|
    plugin_module = modules.find { |i| i.to_s == "Crycord::Plugins::#{plugin.upcase}" }
    css = Crycord::PLUGINS[plugin].css ? css_path : nil
    puts "Installing #{plugin}..."
    plugin_module.try &.execute(path, css)
  end

  puts "Packing core.asar..."
  pack(Path[path])
  puts "Done!"
  puts "Restart Discord to see the results!"
end
