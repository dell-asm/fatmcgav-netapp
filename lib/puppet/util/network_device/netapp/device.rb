require 'puppet/util/network_device'
require 'puppet/util/network_device/netapp/facts'
require 'puppet/util/network_device/netapp/NaServer'
require 'uri'
require '/etc/puppetlabs/puppet/modules/asm_lib/lib/security/encode'

class Puppet::Util::NetworkDevice::Netapp::Device

  attr_accessor :url, :transport

  def initialize(url, option = {})
    @url = URI.parse(url)
    @query = Hash.new([])
    @query = CGI.parse(@url.query) if @url.query

    redacted_url = @url.dup
    redacted_url.password = "****" if redacted_url.password

    Puppet.debug("Puppet::Device::Netapp: connecting to Netapp device #{redacted_url}")

    raise ArgumentError, "Invalid scheme #{@url.scheme}. Must be https" unless @url.scheme == 'https'
    raise ArgumentError, "no user specified" unless @url.user
    raise ArgumentError, "no password specified" unless @url.password

    @transport ||= NaServer.new(@url.host, 1, 13)
    #password = URI.decode(asm_decrypt(@url.password))
    password = URI.decode(@url.password)
    @transport.set_admin_user(URI.decode(@url.user), password)
    @transport.set_transport_type(@url.scheme.upcase)
    @transport.set_port(@url.port)
    if match = %r{/([^/]+)}.match(@url.path)
      @vfiler = match.captures[0]
      @transport.set_vfiler(@vfiler)
      Puppet.debug("Puppet::Device::Netapp: vfiler context has been set to #{@vfiler}")
    end
    
    override_using_credential_id

    result = @transport.invoke("system-get-version")
    if(result.results_errno != 0)
      r = result.results_reason
      raise Puppet::Error, "invoke system-get-version failed: #{r}"
    else
      version = result.child_get_string("version")
      Puppet.debug("Puppet::Device::Netapp: Version = #{version}")
    end
  end
		
  def override_using_credential_id
    if id = @query.fetch('credential_id', []).first
      require 'asm/cipher'
      cred = ASM::Cipher.decrypt_credential(id)
      @transport.set_admin_user(cred.username, cred.password)
    end
  end

  def facts
    @facts ||= Puppet::Util::NetworkDevice::Netapp::Facts.new(@transport)
    facts = @facts.retrieve
    
    facts
  end
end
