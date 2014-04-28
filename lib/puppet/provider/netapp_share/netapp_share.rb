require 'puppet/provider/netapp'

Puppet::Type.type(:netapp_share).provide(:netapp_share, :parent => Puppet::Provider::Netapp) do
  @doc = "Manage Netapp share creation, modification and deletion."
  
  confine :feature => :posix
  defaultfor :feature => :posix

  netapp_commands :slist   => 'cifs-share-list-iter-start'
  netapp_commands :sdel    => 'cifs-share-delete'
  netapp_commands :sadd    => 'cifs-share-add'
  netapp_commands :siterate => 'cifs-share-list-iter-next'
  
  mk_resource_methods

  def self.instances
    Puppet.debug("Puppet::Provider::netapp_share: got to self.instances.")
    shares = []

    result = slist
    tag = result.child_get_string('tag')
    record_count = result.child_get_string('records')
    
    iterator = siterate('tag',tag,'maximum',record_count)
    cifs_shares = iterator.child_get("cifs-shares")
    results_info = cifs_shares.children_get()
    results_info.each do |cifs_share|
      cifs_share_info_node = cifs_share.children_get()
      
      share = {}
      share[:name] = cifs_share.child_get_string('share-name')
      share[:mountpoint] = cifs_share.child_get_string('mount-point')
      share[:description] = cifs_share.child_get_string('description')
      share[:ensure] = :present
      shares << new(share)
      
    end
    shares
  end
  
  def self.prefetch(resources)
    Puppet.debug("Puppet::Provider::netapp_share: Got to self.prefetch.")
    # Itterate instances and match provider where relevant.
    instances.each do |prov|
      Puppet.debug "Resource information #{resources.inspect}"
      Puppet.debug("Prov.name = #{resources[prov.name]}. ")
      if resource = resources[prov.name]
        Puppet.debug "Provider name #{prov.name}"
        Puppet.debug "Resource #{prov}"
        resource.provider = prov
      end
    end
  end

  def flush
    Puppet.debug("Puppet::Provider::netapp_share: Got to flush for resource #{@resource[:name]}.")
   
    # Check required resource state
    Puppet.debug("Property_hash ensure = #{@property_hash[:ensure]}")
    case @property_hash[:ensure]
    when :absent
      Puppet.debug("Puppet::Provider::netapp_share: Ensure is absent.")
      
      # Invoke the constructed request
      result = sdel('share-name', @resource[:name])
  
      Puppet.debug("Puppet::Provider::netapp_share: cifs share #{@resource[:name]} destroyed successfully. \n")
      return true
    
    when :present
      Puppet.debug("Puppet::Provider::netapp_share: Ensure is present.")

      Puppet.debug("Puppet::Provider::netapp_share: export rule #{@resource[:name]} modified successfully on path #{@resource[:path]}. \n")
      return true
      
    end #EOC
  end
  
  def create
    Puppet.debug("Puppet::Provider::netapp_share: creating Netapp export rule #{@resource[:name]} on path #{@resource[:path]}.")

    # Construct rule list
    share = NaElement.new("cifs-share-add")
    share.child_add_string("share-name", @resource[:name])
    share.child_add_string("path", @resource[:path]) unless @resource[:path].nil?
    
    # Add the export rule
    result = sadd('share-name', @resource[:name], 'path', @resource[:path])
    Puppet.debug "Result : #{result.inspect}"

    # Passed above, therefore must of worked. 
    Puppet.debug("Puppet::Provider::netapp_share: cifs share #{@resource[:name]} created successfully on path #{@resource[:path]}. \n")
    return true
  end
  
  def destroy
    Puppet.debug("Puppet::Provider::netapp_share: destroying Netapp share #{@resource[:name]} against path #{@resource[:path]}")
    @property_hash[:ensure] = :absent
  end

  def exists?
    Puppet.debug("Puppet::Provider::netapp_share: checking existance of Netapp share #{@resource[:name]}.")
    Puppet.debug "Ensure value : #{@property_hash.inspect}"
    @property_hash[:ensure] == :present
  end

   
end
