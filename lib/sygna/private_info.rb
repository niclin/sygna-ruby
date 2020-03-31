module Sygna
  module PrivateInfo
    def self.encode(data, pbulic_key)
      crypt.encrypt(public_key, data.to_json).unpack('H*').first
    end

    def self.decode(data, private_key)
      config = Sygna::Config.instance
      private_key ||= OpenSSL::PKey::EC.new(config.private_key)

      crypt.decrypt(private_key, [data].pack("H*"))
    end

    def self.crypt
      ECIES::Crypt.new(cipher: "AES-256-CBC", digest: "SHA512", mac_digest: "SHA1")
    end

    private_class_method :crypt
  end
end