require 'puppet/util/network_device'
require 'puppet/util/network_device/netapp/facts'
require 'puppet/util/network_device/netapp/NaServer'
require 'uri'

class Puppet::Util::NetworkDevice::Netapp::Device

  attr_accessor :url, :transport

  def initialize(url, option = {})
    @url = URI.parse(url)
    @query = Hash.new([])
    @query = CGI.parse(@url.query) if @url.query

    redacted_url = @url.dup
    redacted_url.password = "****" if redacted_url.password

    Puppet.debug("Puppet::Device::Netapp: connecting to Netapp device #{redacted_url}")

    user = URI.decode(@url.user) if @url.user
    password = URI.decode(@url.password) if @url.password
    if id = @query.fetch('credential_id', []).first
      require 'asm/cipher'
      cred = ASM::Cipher.decrypt_credential(id)
      user = cred.username
      password = cred.password
    end

    raise ArgumentError, "Invalid scheme #{@url.scheme}. Must be https" unless @url.scheme == 'https'
    raise ArgumentError, "no user specified" unless user
    raise ArgumentError, "no password specified" unless password

    @transport ||= NaServer.new(@url.host, 1, 13)
    @transport.set_admin_user(user, password)
    @transport.set_transport_type(@url.scheme.upcase)
    @transport.set_port(@url.port)
    if match = %r{/([^/]+)}.match(@url.path)
      @vfiler = match.captures[0]
      @transport.set_vfiler(@vfiler)
      Puppet.debug("Puppet::Device::Netapp: vfiler context has been set to #{@vfiler}")
    end
    
    result = @transport.invoke("system-get-version")
    if(result.results_errno != 0)
      r = result.results_reason
      raise Puppet::Error, "invoke system-get-version failed: #{r}"
    else
      version = result.child_get_string("version")
      Puppet.debug("Puppet::Device::Netapp: Version = #{version}")
    end
  end
		
  def facts
    @facts ||= Puppet::Util::NetworkDevice::Netapp::Facts.new(@transport)
    facts = @facts.retrieve
    
    facts
  end
end
