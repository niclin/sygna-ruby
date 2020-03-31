module Sygna
  class Signature
    def initialize(obj)
      @obj = obj
    end

    def sign
      object_string = @obj.merge(empty_signature).to_json

      privkey = Secp256k1::PrivateKey.new(privkey: private_key_binary)

      Secp256k1::Utils.encode_hex(privkey.ecdsa_serialize_compact(privkey.ecdsa_sign(object_string)))
    end

    private

    def private_key_binary
      config = Sygna::Config.instance

      OpenSSL::PKey::EC.new(config.private_key).private_key.to_s(2)
    end

    def empty_signature
      {
        signature: ""
      }
    end
  end
end