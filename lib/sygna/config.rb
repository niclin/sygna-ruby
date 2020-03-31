module Sygna
  class Config
    class << self
      attr_writer :instance

      def instance
        @instance ||= new
      end
    end

    attr_accessor :api_key
    attr_accessor :private_key

    def initialize(config = {})
      self.api_key = config[:api_key]
      self.private_key = config[:private_key]
    end

    def valid?
      !self.api_key.empty? && !self.private_key.empty? rescue false
    end
  end
end