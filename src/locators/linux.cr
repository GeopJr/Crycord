module Crycord
  private def find_build(path : Path) : Path | Nil
    build = ""
    Dir.open(path.to_s).each_child do |c|
      unless (c =~ /^discord(ptb|canary)?$/).nil?
        build = c
        break
      end
    end
    puts build
    return if build == ""
    return path.join(build)
  end

  def linux : Path | Nil
    # Usually located at ~/.config/discord...
    config_path = Path["~/.config/"].expand(home: true)
    return unless Dir.exists?(config_path)
    build = find_build(config_path)
    return unless !build.nil? && Dir.exists?(build)
    version_path = find_version_folder(build)
    return if version_path.nil?
    core_path = version_path.join("modules/discord_desktop_core/core.asar")
    return unless File.exists?(core_path)
    return core_path
  end
end
