require "json"
require "openssl"
require "secp256k1"

require "sygna/version"
require "sygna/config"
require "sygna/crypt"
require "sygna/private_info"
require "sygna/signature"

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
