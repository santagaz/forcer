
module Forcer
  class ActionOptionsService
    def self.parse(options = {})
      if options[:deploy]
        p "call deploy"
      elsif options[:list_metadata]
        p "call list_metadata"
      end
    end
  end
end