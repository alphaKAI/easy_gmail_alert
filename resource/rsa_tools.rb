#encoding:utf-8
require "openssl"

# Copyleft (C) alphaKAI 2013

class RsaTools
	include OpenSSL::PKey

	def initialize
		rsa = RSA.generate(2048)
		unless File.exist?("./keys/rsa_pass.txt")
			key=""
			1000.times{|i|
				key+=rand(i).to_s
			}
			File.write("./keys/rsa_pass.txt",key)
		end
		rsa_gen_key=File.read("./keys/rsa_pass.txt", :encoding => Encoding::UTF_8).to_s
		
		public_key = rsa.public_key.to_s
		private_key = rsa.export(OpenSSL::Cipher::Cipher.new("aes256"),rsa_gen_key)

		File.write("./keys/private.dat",private_key)
		File.write("./keys/public.dat",public_key)
	end

	def encode(target_str)	
		public_key=File.read("./keys/public.dat", :encoding => Encoding::UTF_8).to_s
		rsa_gen_key=File.read("./keys/rsa_pass.txt", :encoding => Encoding::UTF_8).to_s
		pub = RSA.new(public_key)

		enc_target = pub.public_encrypt(target_str)
		return enc_target
	end

	def decode(target)
		private_key=File.read("./keys/private.dat", :encoding => Encoding::UTF_8).to_s
		rsa_gen_key=File.read("./keys/rsa_pass.txt", :encoding => Encoding::UTF_8).to_s

		private = RSA.new(private_key,rsa_gen_key)
		return private.private_decrypt(target)
	end
end

RsaTools.new.rsa_first
