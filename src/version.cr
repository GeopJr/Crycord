require "yaml"

module Crycord
  VERSION = {{ `shards version #{__DIR__}`.chomp.stringify }}
end
