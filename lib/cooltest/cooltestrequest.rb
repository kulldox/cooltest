require File.dirname(__FILE__)+"/../config/config";
require 'json'
# require 'net/ldap'
require 'net/ssh'
require 'net/scp'
require 'net/sftp'
require 'net/http'
require 'net/https'
require 'savon'
require 'uri'
require 'xmlsimple'
require 'digest/sha1'
# require 'crypt/blowfish' 
require "Base64"
require "#{APPDIR}/lib/logging/logging"

require "openssl"

##
# CURRENTLY NOT WORKING, NOT compatible with Java implementation
# 
# for JBlowfish start
# require 'java'
# require '#{APPDIR}/javalib/blowfish-1.0.jar'
# for JBlowfish end
module Blowfish #:nodoc:
	def self.cipher(mode, key, data)
		cipher = OpenSSL::Cipher::Cipher.new('bf-ecb').send(mode)
		cipher.key = Digest::SHA256.digest(key)
		cipher.padding = 16
		cipher.update(data) << cipher.final
	end

	def self.encrypt(key, data)
		cipher(:encrypt, key, data)
	end

	def self.decrypt(key, text)
		cipher(:decrypt, key, text)
	end
end

##
# The purpose of this module is to provide Blowfish encryption/decryption
# It is basically a wrapper around the java blowfish implemented jar
# 
# It is using the java blowfish-1.0.jar. because this jar doesn't have a main class, a BlowfishWrapper is used that accepts 3 params:
# @1 operation: encrypt or decrypt
# @2 key: the encryption key
# @3 text: the text that needs to be encrypted/decrypted
# since calling java classes is impossible in Ruby (plus using Windows like paths is convoluted), a system call is done via a bin/bf.bat file. it accepts the same params in the same order
# 
module JBlowfish #:nodoc:
	# java_import logical.crypto.blowfish.Blowfish;
	def self.encrypt(key, plainData)
		`#{APPDIR}/bin/bf.bat "encrypt" "#{key}" "#{plainData}"`
		# system "cd #{APPDIR}/javalib/; java -classpath #{APPDIR}/javalib/ -cp \"blowfish-1.0.jar;.\"  BlowfishWrapper \"encrypt\" \""+key+"\" \""+plainData+"\""
	end

	def self.decrypt(key, ecryptedData)
		`#{APPDIR}/bin/bf.bat "decrypt" "#{key}" "#{ecryptedData}"`
		# system "cd #{lpath}; java -classpath #{lpath} -cp \"blowfish-1.0.jar;.\"  BlowfishWrapper \"decrypt\" \""+key.to_s+"\" \""+ecryptedData.to_s+"\""
	end
end

# require 'fileutils'

##
# Extend the default Hash class with two methods:
# * +without+ - is removing elements from the Hash
# * +pick+ - is selecting just the mentioned elements from the Hash
class Hash #:nodoc:
	def without(*keys)
		cpy = self.dup
		keys.each { |key| cpy.delete(key) }
		cpy
	end
	def pick(*values)
		select { |k,v| values.include?(k) }
	end
end


##
# The purpose of this class is to provide a collection of every request type needed for testing
# Currently it has the following types of requests:
# * +SOAP+ - using the SAVON client from the +savon+ gem
# * +HTTP+ - using the +httpi+ gem
# * +SSH+ - using the +net-ssh+ gem
# 
class CooltestRequest
	include Logging
	$k = Config.new();
	def initialize(options)
		@options = options
		@soapClientOptions = {
			wsdl: "",
			host: "",
			port: "",
			url: "",
			namespace: "",
			env_namespace: :soapenv,
			namespace_identifier: :v1,
			headers: {"SOAPAction" => ""},
			raise_errors: false,
			open_timeout: 5,
			read_timeout: 20,
			log: true,
			log_level: :info # or one of [:info, :debug, :warn, :error, :fatal]
		}
	end

	##
	# wrapper for the Savon SOAP client setup 
	# 
	# ==== Attributes
	# * +sc_params+ - an object with settings for host, port, url, wsdl.
	# 
	def savonClient(sc_params = {})

		s_params = @soapClientOptions.merge(sc_params);
		logger.debug "#{s_params}"
		# Savon::Response.raise_errors = false
		@soapClient ||= Savon.client(
			wsdl: s_params[:wsdl],
			endpoint: "http://"+s_params[:host]+":"+s_params[:port]+s_params[:url],
			namespace: s_params[:namespace],
			env_namespace: s_params[:env_namespace],
			namespace_identifier: s_params[:namespace_identifier],
			headers: s_params[:headers],
			raise_errors: s_params[:raise_errors],
			open_timeout: s_params[:open_timeout],
			read_timeout: s_params[:read_timeout],
			log: s_params[:log],
			log_level: s_params[:log_level]
		)
	end

	##
	# Returns the SOAP operation defined in WSDL for a given method name. This is used so that the user can do e SOAP request using the user friendly method name like ActivateReq, DeleteCustomerReq, etc. instead of the WSDL operation
	# 
	# ==== Attributes
	# * +requestType+ - the request name that needs to be executed, like ActivateReq, etc.
	# 
	def getSoapOperationByRequestType(requestType)
		document = Wasabi.document File.read(@soapClientOptions[:wsdl])
		document.operations.select {|f,v| v[:input] == requestType}.keys[0]
	end

	##
	# a generic HTTP request that can be used for
	# * +method+ - HTTP request method POST/GET
	# * +url+ - the destination URL
	# * +data+ - the data params HASH
	# 
	def httpRequest(method, url, data)
		request = HTTPI::Request.new(url)
		request.body = data;

		# request.auth.ssl.cert_key_file     = "client_key.pem"   # the private key file to use
		# request.auth.ssl.cert_key_password = "C3rtP@ssw0rd"     # the key file's password
		# request.auth.ssl.cert_file         = "client_cert.pem"  # the certificate file to use
		# request.auth.ssl.ca_cert_file      = "ca_cert.pem"      # the ca certificate file to use
		# request.auth.ssl.verify_mode       = :none              # or one of [:peer, :fail_if_no_peer_cert, :client_once]
		# request.auth.ssl.ssl_version       = :TLSv1             # or one of [:TLSv1_2, :TLSv1_1, :TLSv1, :SSLv3, :SSLv23, :SSLv2]
		# request.auth.ssl.ca_cert_file      = "ca_cert.pem"
		# request.auth.ssl.verify_mode       = :none
		# request.auth.ssl.ssl_version = :TLSv1
		HTTPI.adapter = :httpclient
		# puts request
		res = HTTPI.request(method, request)
		return {request: request.url.to_s+"?"+request.body, body: request.body, original_response: res}
	end

	##
	# TODO: Currently does NOT really work as expected.
	#
	# a generic HTTPs request that can be used for
	# * +method+ - HTTP request method POST/GET
	# * +url+ - the destination URL
	# * +data+ - the data params HASH
	# 
	def httpsRequest(method, url, data)
		uri = URI.parse(url)
		httpsSetup =Net::HTTP.new(uri.host,uri.port)
		httpsSetup.use_ssl = true
		# httpsSetup.ssl_version = :TLSv1_2
		# httpsSetup.verify_mode = OpenSSL::SSL::VERIFY_NONE # please don't use verify_none.
		# httpsSetup.verify_mode = OpenSSL::SSL::VERIFY_PEER # please don't use verify_none.
		# httpsSetup.ciphers = ['DES-CBC3-SHA']
		httpsSetup.ssl_version = :SSLv23
		httpsSetup.ciphers = ['RC4-SHA']
		p OpenSSL::SSL::SSLContext::DEFAULT_PARAMS
		p uri.to_json
		p url+"?"+data
		req = httpsSetup.get(url+"?"+data)
		# The body needs to be a JSON string, use whatever you know to parse Hash to JSON
		# req.body = data.to_json
		res = httpsSetup.request(req)
  		return {request: req.url.to_s+"?"+req.body, body: req.body, original_response: res}
	end


	##
	# generic SSH request
	# 
	# ==== Attributes
	# * +ssh_h+ - host
	# * +ssh_u+ - user
	# * +ssh_u+ - user
	# * +ssh_p+ - password
	# * +cmd+ - command
	# * +onlyOutput+ - if true, return only the result of the command, else, return the command itself as well
	# * +options+ - various options like custom port for ex
	# 
	def sshcmd(ssh_h, ssh_u, ssh_p, cmd, onlyOutput = false, options = {})
		ssh_port = options[:port] ? options[:port] : '22'
		logger.debug "SSH (#{ssh_u}@#{ssh_h}:#{ssh_port}): " + cmd
		Net::SSH.start(
			ssh_h,
			ssh_u,
			{:port => ssh_port,
			:password => ssh_p,
			# :verbose => :debug,
			# :auth_methods => ['password','publickey','hostbased','keyboard-interactive'],
			:auth_methods => ['password'],
			:forward_agent => true}
		) do|ssh| 
			out = ''
			if onlyOutput == true
				out = ssh.exec!(cmd)
			else
				out = cmd+"\n"+ssh.exec!(cmd)
			end
			logger.debug out
			return out
		end
	end

	##
	# NOTE: Currently not used anywhere. ldap via SSH is used instead. The intention is to mimic the same output as the CLI ldap commands return.
	# Executes a ldap operation in USD NDS
	# 
	# ==== Attributes
	# none
	# 
	# TODO: make it more generic and suitable for testing, which will work similar to the ldap CLI commands
	# 
	def ldap()

		ldap = Net::LDAP.new :host => $k.get('server_ldap'),
		     :port => $k.get('port_ldap'),
		     :auth => {
			           :method => :simple,
			           :username => $k.get('user_ldap'),
			           :password => $k.get('password_ldap')
		     		}

		filter = Net::LDAP::Filter.eq( "objectClass", "*" )
		treebase = "subdata=services,uid=f4994c2a-783a-4962-bf3a-5003d7b8,ds=SUBSCRIBER,o=DEFAULT,DC=C-NTDB"

		ldap.search( :base => treebase, :filter => filter ) do |entry|
		  puts ""
		  logger.debug "##{entry.dn}"
		  entry.each do |attribute, values|
		    values.each do |value|
		      puts "#{attribute}: #{value}"
		    end
		  end
		end

		# p ldap.get_operation_result
	end


end
