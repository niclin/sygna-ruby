# reference: https://github.com/jamoes/ecies/blob/master/lib/ecies/crypt.rb

module Sygna
  # Provides functionality for encrypting and decrypting messages using ECIES.
  # Encapsulates the configuration parameters chosen for ECIES.
  class Crypt

    # The allowed digest algorithms for ECIES.
    DIGESTS = %w{SHA1 SHA224 SHA256 SHA384 SHA512}

    # The allowed cipher algorithms for ECIES.
    CIPHERS = %w{AES-128-CBC AES-192-CBC AES-256-CBC AES-128-CTR AES-192-CTR AES-256-CTR}

    # The initialization vector used in ECIES. Quoting from sec1-v2:
    # "When using ECIES, some exception are made. For the CBC and CTR modes, the
    # initial value or initial counter are set to be zero and are omitted from
    # the ciphertext. In general this practice is not advisable, but in the case
    # of ECIES it is acceptable because the definition of ECIES implies the
    # symmetric block cipher key is only to be used once.
    IV = ("\x00" * 16).force_encoding(Encoding::BINARY)

    # Creates a new instance of {Crypt}.
    #
    # @param cipher [String] The cipher algorithm to use. Must be one of
    #     {CIPHERS}.
    # @param digest [String,OpenSSL::Digest] The digest algorithm to use for
    #     HMAC and KDF. Must be one of {DIGESTS}.
    # @param mac_digest [String,OpenSSL::Digest,nil] The digest algorithm to
    #     use for HMAC. If not specified, the `digest` argument will be used.
    def initialize(cipher: 'AES-256-CTR', digest: 'SHA256', mac_digest: nil)
      @cipher = OpenSSL::Cipher.new(cipher)
      @mac_digest = OpenSSL::Digest.new(mac_digest || digest)

      CIPHERS.include?(@cipher.name) or raise "Cipher must be one of #{CIPHERS}"
      DIGESTS.include?(@mac_digest.name) or raise "Digest must be one of #{DIGESTS}"
    end

    # Encrypts a message to a public key using ECIES.
    #
    # @param key [OpenSSL::EC:PKey] The public key.
    # @param message [String] The plain-text message.
    # @return [String] The octet string of the encrypted message.
    def encrypt(key, message)
      key.public_key? or raise "Must have public key to encrypt"
      @cipher.reset

      group_copy = OpenSSL::PKey::EC::Group.new(key.group)

      ephemeral_key = OpenSSL::PKey::EC.new(group_copy).generate_key
      ephemeral_public_key_octet = ephemeral_key.public_key.to_bn.to_s(2)

      shared_secret = ephemeral_key.dh_compute_key(key.public_key)

      hashed_secret = Digest::SHA512.digest(shared_secret)

      cipher_key = hashed_secret.slice(0, 32)
      hmac_key = hashed_secret.slice(32, hashed_secret.length - 32)

      @cipher.encrypt
      @cipher.iv = IV
      @cipher.key = cipher_key
      ciphertext = @cipher.update(message) + @cipher.final

      data_to_mac = IV + ephemeral_public_key_octet + ciphertext

      mac = OpenSSL::HMAC.digest(@mac_digest, hmac_key, data_to_mac)

      # 65 + 20 + 16
      ephemeral_public_key_octet + mac + ciphertext
    end

    # Decrypts a message with a private key using ECIES.
    #
    # @param key [OpenSSL::EC:PKey] The private key.
    # @param encrypted_message [String] Octet string of the encrypted message.
    # @return [String] The plain-text message.
    def decrypt(key, encrypted_message)
      key.private_key? or raise "Must have private key to decrypt"
      @cipher.reset

      group_copy = OpenSSL::PKey::EC::Group.new(key.group)

      ephemeral_public_key_octet = encrypted_message.slice(0, 65)

      mac = encrypted_message.slice(65, 20)

      ciphertext = encrypted_message.slice(85, encrypted_message.size)

      ephemeral_public_key = OpenSSL::PKey::EC::Point.new(group_copy, OpenSSL::BN.new(ephemeral_public_key_octet, 2))

      shared_secret = key.dh_compute_key(ephemeral_public_key)

      hashed_secret = Digest::SHA512.digest(shared_secret)

      cipher_key = hashed_secret.slice(0, 32)
      hmac_key = hashed_secret.slice(32, hashed_secret.length)

      data_to_mac = IV + ephemeral_public_key_octet + ciphertext

      computed_mac = OpenSSL::HMAC.digest("SHA1", hmac_key, data_to_mac)
      computed_mac == mac or raise OpenSSL::PKey::ECError, "Invalid Message Authenticaton Code"

      @cipher.decrypt
      @cipher.iv = IV
      @cipher.key = cipher_key

      @cipher.update(ciphertext) + @cipher.final
    end

    # Converts a hex-encoded public key to an `OpenSSL::PKey::EC`.
    #
    # @param hex_string [String] The hex-encoded public key.
    # @param ec_group [OpenSSL::PKey::EC::Group,String] The elliptical curve
    #     group for this public key.
    # @return [OpenSSL::PKey::EC] The public key.
    # @raise [OpenSSL::PKey::EC::Point::Error] If the public key is invalid.
    def self.public_key_from_hex(hex_string, ec_group = 'secp256k1')
      ec_group = OpenSSL::PKey::EC::Group.new(ec_group) if ec_group.is_a?(String)
      key = OpenSSL::PKey::EC.new(ec_group)
      key.public_key = OpenSSL::PKey::EC::Point.new(ec_group, OpenSSL::BN.new(hex_string, 16))
      key
    end

    # Converts a hex-encoded private key to an `OpenSSL::PKey::EC`.
    #
    # @param hex_string [String] The hex-encoded private key.
    # @param ec_group [OpenSSL::PKey::EC::Group,String] The elliptical curve
    #     group for this private key.
    # @return [OpenSSL::PKey::EC] The private key.
    # @note The returned key only contains the private component. In order to
    #     populate the public component of the key, you must compute it as
    #     follows: `key.public_key = key.group.generator.mul(key.private_key)`.
    # @raise [OpenSSL::PKey::ECError] If the private key is invalid.
    def self.private_key_from_hex(hex_string, ec_group = 'secp256k1')
      ec_group = OpenSSL::PKey::EC::Group.new(ec_group) if ec_group.is_a?(String)
      key = OpenSSL::PKey::EC.new(ec_group)
      key.private_key = OpenSSL::BN.new(hex_string, 16)
      key.private_key < ec_group.order or raise OpenSSL::PKey::ECError, "Private key greater than group's order"
      key.private_key > 1 or raise OpenSSL::PKey::ECError, "Private key too small"
      key
    end
  end
end