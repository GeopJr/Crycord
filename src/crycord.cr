require "option_parser"
require "asar-cr"
require "colorize"

require "./version.cr"
require "./functions/*"
require "./locators/*"
require "./plugins/core/*"
require "./plugins/extra/*"

module Crycord
  extend self

  @@plugins : Array(String)
  @@available_groups : Array(String)
  PATHS = Hash(String, Path).new

  @@plugins = Crycord::PLUGINS.keys.reject! { |x| Crycord::PLUGINS[x].disabled }
  @@available_groups = @@plugins.map { |x| x = Crycord::PLUGINS[x].category }.uniq
  css_path = asar_path = ""
  groups = ["core"]
  plugins = ["enable_css", "enable_https"]
  should_revert = false

  def get_paths : String
    path = flatpak
    if path.nil?
      path = linux
    else
      STDOUT.puts "Flatpak Detected:".colorize(:yellow)
      STDOUT.puts "Make sure it has access to your CSS file".colorize(:yellow)
      STDOUT.puts "Usually ~/Downloads/ is accessible".colorize(:yellow)
    end
    if path.nil?
      STDERR.puts "ERROR: couldn't find core.asar, try manually setting it using the -f flag.".colorize(:red)
      exit(1)
    end
    return path.to_s
  end

  def group_list
    STDOUT.puts "Available plugin groups:"
    STDOUT.puts @@available_groups.join("\n")
    STDOUT.puts "Note: core is being installed by default".colorize(:yellow)
    exit(1)
  end

  def plugin_list
    available_plugins = Crycord::PLUGINS.keys.reject! { |x| Crycord::PLUGINS[x].disabled }.map { |x| x = Crycord::PLUGINS[x].name + " | " + Crycord::PLUGINS[x].category + " | " + Crycord::PLUGINS[x].desc }.uniq
    STDOUT.puts "Available plugins:"
    STDOUT.puts "NAME | GROUP | DESCRIPTION"
    STDOUT.puts available_plugins.join("\n")
    STDOUT.puts "Note: Disabled plugins are omitted".colorize(:yellow)
    STDOUT.puts "Note: core is being installed by default".colorize(:yellow)
    exit(1)
  end

  # CLI options
  OptionParser.parse do |parser|
    parser.banner = "<== [Crycord] ==>"

    parser.on "-v", "--version", "Show version" do
      STDOUT.puts "Crycord".colorize(:magenta)
      STDOUT.puts "Made by: GeopJr".colorize(:cyan)
      STDOUT.puts "Version: #{VERSION}".colorize(:yellow)
      exit(1)
    end
    parser.on "-h", "--help", "Show help" do
      STDOUT.puts parser
      exit(1)
    end
    parser.on "-l", "--list", "Lists all available plugin groups & plugins" do
      plugin_list
    end
    parser.on "-r", "--revert", "Reverts back to original asar" do
      should_revert = true
    end
    parser.on "-p PLUGINS", "--plugins=PLUGINS", "Selects the plugin(s) to install. Split multiple groups with commas(,)." do |input|
      if input == "" || input.nil?
        plugin_list
      end
      plugins.concat(input.downcase.gsub(" ", "").split(","))
      plugins.uniq!
      plugins.each do |item|
        unless @@plugins.includes?(item)
          STDERR.puts "ERROR: unknown plugin #{item}, use the -l flag to list all groups.".colorize(:red)
          exit(1)
        end
      end
    end
    parser.on "-c CSS_PATH", "--css=CSS_PATH", "Sets CSS location" do |path|
      css = Path[path].expand(home: true)
      unless File.exists?(css)
        STDERR.puts "ERROR: CSS file not found".colorize(:red)
        exit(1)
      end
      css_path = css.to_s
    end
    parser.on "-f CORE_ASAR_PATH", "--force=CORE_ASAR_PATH", "Forces an asar path" do |path|
      asar_path = Path[path].expand(home: true).to_s
      unless File.exists?(asar_path)
        STDERR.puts "ERROR: core.asar not found".colorize(:red)
        exit(1)
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
          STDOUT.puts "ERROR: unknown group #{item}, use the -l flag to list all groups.".colorize(:red)
          exit(1)
        end
      end
    end

    parser.missing_option do |option_flag|
      STDERR.puts "ERROR: #{option_flag} is missing something.".colorize(:red)
      STDERR.puts ""
      STDERR.puts parser
      exit(1)
    end
    parser.invalid_option do |option_flag|
      STDERR.puts "ERROR: #{option_flag} is not a valid option.".colorize(:red)
      STDERR.puts ""
      STDERR.puts parser
      exit(1)
    end
  end

  # Check revert
  if should_revert
    asar_path = get_paths if asar_path.empty?
    res = revert(Path[asar_path])
    if res.nil?
      STDERR.puts "Restore was unsuccessful".colorize(:red)
    else
      STDOUT.puts "Restore was successful".colorize(:green)
    end
    exit(1)
  end

  # Check options
  if css_path.empty?
    STDERR.puts "ERROR: -c option is missing".colorize(:red)
    exit(1)
  end

  # Check discord and get paths
  asar_path = get_paths if asar_path.empty?

  # Extract asar
  STDOUT.puts "Extracting core.asar...".colorize(:yellow)
  path = extract(Path[asar_path])
  if path.nil?
    STDERR.puts "ERROR: couldn't extract core.asar".colorize(:red)
    exit(1)
  end

  # Set paths
  PATHS["asar"] = path
  PATHS["css"] = Path[css_path]

  # See collector.cr
  modules = Crycord::Plugins.collected_modules
  selected_plugins = @@plugins.reject { |x| !groups.includes?(Crycord::PLUGINS[x].category) && !plugins.includes?(Crycord::PLUGINS[x].name) }.uniq

  selected_plugins.each do |plugin|
    plugin_module = modules.find { |i| i.to_s == "Crycord::Plugins::#{plugin.upcase}" }
    STDOUT.puts "Installing #{plugin}...".colorize(:yellow)
    plugin_module.try &.execute
  end

  STDOUT.puts "Packing core.asar...".colorize(:yellow)
  pack(path)
  STDOUT.puts "Done!".colorize(:green)
  STDOUT.puts "Restart Discord to see the results!".colorize(:yellow)
end
