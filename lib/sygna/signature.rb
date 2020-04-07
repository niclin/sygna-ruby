module Sygna
  module Signature
    EMPTY_SIGNATURE = { signature: "" }.freeze

    def self.sign(object)
      object_string = object.merge(EMPTY_SIGNATURE).to_json

      Secp256k1::Utils.encode_hex(ecdsa_private_key.ecdsa_serialize_compact(ecdsa_private_key.ecdsa_sign(object_string)))
    end

    def self.verify(object, signature, public_key_hex)
      object_string = object.merge(EMPTY_SIGNATURE).to_json

      public_key_binary = Secp256k1::Utils.decode_hex(public_key_hex)
      ecdsa_public_key = Secp256k1::PublicKey.new(pubkey: public_key_binary, raw: true)

      binary_signature = Secp256k1::Utils.decode_hex(signature)
      raw_signature = ecdsa_public_key.ecdsa_deserialize_compact(binary_signature)

      ecdsa_public_key.ecdsa_verify(object_string, raw_signature)
    end

    def self.ecdsa_private_key
      config = Sygna::Config.instance

      private_key_binary = OpenSSL::PKey::EC.new(config.private_key).private_key.to_s(2)

      Secp256k1::PrivateKey.new(privkey: private_key_binary)
    end

    private_class_method :ecdsa_private_key
  end
end