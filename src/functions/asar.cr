require "file_utils"

module Crycord
  # extract and pack require a significant amount of RAM

  # Asar to path
  def extract(path : Path) : Path
    parent = path.parent.join("core")
    output = parent.to_s
    delete_unpacked(parent) if Dir.exists?(output)
    asar = Asar::Extract.new path.to_s
    asar.extract output
    Path[output]
  end

  # Path to asar
  def pack(path : Path) : Path | Nil
    return unless Dir.exists?(path)
    core = path.parent.join("core.asar")
    backup(core) unless File.exists?(path.parent.join("core.asar.bak"))
    File.delete(core) if File.exists?(core)
    asar = Asar::Pack.new path.to_s
    asar.pack core.to_s
    delete_unpacked(path)
    core
  end

  def delete_unpacked(path : Path) : Bool
    FileUtils.rm_rf(path.to_s)
    true
  end

  def backup(path : Path) : Bool
    File.rename(path.to_s, path.parent.join("core.asar.bak").to_s)
    return true
  end

  def revert(path : Path) : Bool | Nil
    parent = path.parent
    bak = parent.join("core.asar.bak")
    return unless File.exists?(path) && File.exists?(bak)
    File.delete(path.to_s)
    File.rename(bak.to_s, path.to_s)
    true
  end
end
