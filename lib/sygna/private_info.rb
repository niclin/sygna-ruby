module Sygna
  module PrivateInfo
    def self.encode(data, public_key_hex)
      key = Crypt.public_key_from_hex(public_key_hex)

      crypt.encrypt(key, data.to_json).unpack('H*').first
    end

    def self.decode(data)
      config = Sygna::Config.instance
      private_key = OpenSSL::PKey::EC.new(config.private_key)

      crypt.decrypt(private_key, [data].pack("H*"))
    end

    def self.crypt
      Crypt.new(cipher: "AES-256-CBC", digest: "SHA512", mac_digest: "SHA1")
    end

    private_class_method :crypt
  end
end