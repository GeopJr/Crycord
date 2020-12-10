require "yaml"

module Crycord
  VERSION = YAML.parse(::File.read("./shard.yml"))["version"]
end
