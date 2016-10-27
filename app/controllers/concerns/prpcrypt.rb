module Prpcrypt
  extend ActiveSupport::Concern

  def decrypt( encrypt)
    set_component_verify_ticket(encrypt)
  end

  def encrypt(encrypt_type, str)
    encode(str.to_s)
  end

  private

    def set_component_verify_ticket(encrypt)
      redis = Redis.new(:url => "#{ENV['REDISURL']}")
      encoding_aes = Base64.decode64("#{ENV["secret_key_base"]}=")
      decrypt_text = encrypt_text_decrypt(encoding_aes, encrypt)
      text = MultiXml.parse(decrypt_text[0])
      os = OpenStruct.new(text["xml"])
      redis.hset(ENV["key_name"],ENV['field_name'], os.ComponentVerifyTicket)
    end

    def encode(str)
      begin
        cipher = cipher_object(Rails.application.secrets.cipher_key)
        encrypted = cipher.update(str) << cipher.final
        Base64.urlsafe_encode64 encrypted
      rescue
        nil
      end
    end

    def encrypt_text_decrypt(aes_key, text)
      p aes_key
      status = 200
      text   = Base64.decode64(text)
      text   = handle_cipher(:decrypt, aes_key, text)
      pad = text[-1].ord
      pad = 0 if (pad < 1 || pad > 32)
      size = text.size - pad
      result = text[0...size]
      content  = result[16...result.length]
      len_list = content[0...4].unpack("N")
      xml_len  = len_list[0]
      xml_content = content[4...4 + xml_len]
      from_app_id = content[xml_len + 4...content.size]
      [xml_content, status]
    end

    def handle_cipher(action, aes_key, text)
      cipher = OpenSSL::Cipher.new('AES-256-CBC')
      cipher.send(action)
      cipher.padding = 0
      cipher.key = aes_key
      cipher.iv  = aes_key[0...16]
      cipher.update(text) + cipher.final
    end

    def cipher_object(aes_key, crypt_type="encrypt")
      cipher = OpenSSL::Cipher.new('AES-256-CBC')
      cipher.send(crypt_type)
      cipher.key = aes_key
      cipher.iv  = aes_key[0...16]
      cipher
    end

end
