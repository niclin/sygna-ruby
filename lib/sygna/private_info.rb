module Sygna
  module PrivateInfo
    def self.encode(data, public_key_hex)
      group = OpenSSL::PKey::EC::Group.new('secp256k1')
      key = OpenSSL::PKey::EC.new(group)
      public_key_bn = OpenSSL::BN.new(public_key_hex, 16)
      public_key = OpenSSL::PKey::EC::Point.new(group, public_key_bn)
      key.public_key = public_key

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