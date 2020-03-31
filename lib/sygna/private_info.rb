module Sygna
  class PrivateInfo
    def initialize(data, beneficiary_vasp_code)
      @config = Sygna::Config.instance
      @data = data
      @beneficiary_vasp_code = beneficiary_vasp_code.upcase
    end

    def encode
      crypt.encrypt(vasp_public_key, @data.to_json).unpack('H*').first
    end

    def decode
      crypt.decrypt(private_key, [@data].pack("H*"))
    end

    private

    def crypt
      ECIES::Crypt.new(cipher: "AES-256-CBC", digest: "SHA512", mac_digest: "SHA1")
    end

    def vasp_public_key
      public_key_hex = Sygna::VaspPublicKeyFinder.new(@beneficiary_vasp_code).get

      group = OpenSSL::PKey::EC::Group.new('secp256k1')
      key = OpenSSL::PKey::EC.new(group)
      public_key_bn = OpenSSL::BN.new(public_key_hex, 16)
      public_key = OpenSSL::PKey::EC::Point.new(group, public_key_bn)
      key.public_key = public_key

      key
    end

    def private_key
      OpenSSL::PKey::EC.new(@config.private_key)
    end
  end
end