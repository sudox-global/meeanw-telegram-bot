module EncryptionHelper
  require 'openssl'
  require 'base64'

  def self.encrypt(message, key)
    cipher = OpenSSL::Cipher.new('AES-128-CBC')
    cipher.encrypt
    cipher.key = key
    iv = cipher.random_iv
    encrypted = cipher.update(message) + cipher.final
    encoded = Base64.strict_encode64(encrypted + iv)
  end

  def self.decrypt(encrypted_message, key)
    decoded = Base64.strict_decode64(encrypted_message)
    cipher = OpenSSL::Cipher.new('AES-128-CBC')
    cipher.decrypt
    cipher.key = key
    iv = decoded[-16..-1] # Extract the IV from the decoded message
    decoded = decoded[0..-17] # Remove the IV from the decoded message
    cipher.iv = iv
    decrypted = cipher.update(decoded) + cipher.final
  end
end
