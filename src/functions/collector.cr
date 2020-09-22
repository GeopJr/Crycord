# Collector from Granz (GeopJr/Granz-cr)
module Crycord
  record Plugin, name : String, category : String, desc : String, disabled : Bool? = false
  PLUGINS = Hash(String, Plugin).new

  module Plugins
    # Macro that lists all available constants under Crycord::Plugins
    # and also filters through them
    def self.collected_modules
      {{@type.constants}}.reject! { |x| !PLUGINS.keys.includes?(x.to_s.split("::Plugins::", limit: 2)[-1].downcase) }
    end
  end
end
