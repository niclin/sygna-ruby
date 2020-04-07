module Sygna
  class Config
    class << self
      attr_writer :instance

      def instance
        @instance ||= new
      end
    end

    attr_accessor :private_key

    def initialize(config = {})
      self.private_key = config[:private_key]
    end

    def valid?
      !self.private_key.empty? rescue false
    end
  end
end