require "sygna/version"
require "sygna/config"

module Sygna
  class Error < StandardError; end


  class << self
    def configure
      yield config = Sygna::Config.instance
    end

    def configured?
      Sygna::Config.instance.valid?
    end
  end
end
