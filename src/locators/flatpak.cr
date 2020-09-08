module Crycord
  def flatpak : Path | Nil
    # Flatpak apps are usually located at ~/.var/app/
    path = Path["~/.var/app/com.discordapp.Discord/config/discord"].expand(home: true)
    return unless Dir.exists?(path)
    version_path = find_version_folder(path)
    return if version_path.nil?
    core_path = version_path.join("modules/discord_desktop_core/core.asar")
    return unless File.exists?(core_path)
    return core_path
  end

  # # Useless for now
  # def flatpak_resources : Path | Nil
  #   path = Path["~/.local/share/flatpak/app/com.discordapp.Discord/x86_64/stable"].expand(home: true)
  #   return unless Dir.exists?(path)
  #   folder = ""
  #   Dir.open(path.to_s).each_child do |item|
  #     next if File.symlink?(path.join(item).to_s)
  #     folder = item
  #   end
  #   return if folder == ""
  #   app_path = Path[path].join("#{folder}/files/discord/resources/app.asar")
  #   return unless File.exists?(app_path)
  #   return app_path
  # end
end
