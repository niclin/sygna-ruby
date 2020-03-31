require "ecies"
require "sygna/version"
require "sygna/config"
require "sygna/private_info"

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
