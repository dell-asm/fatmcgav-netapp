require 'puppet/provider/netapp'

Puppet::Type.type(:netapp_share).provide(:netapp_share, :parent => Puppet::Provider::Netapp) do
  @doc = "Manage Netapp share creation, modification and deletion."
  
  confine :feature => :posix
  defaultfor :feature => :posix

  netapp_commands :slist   => 'cifs-share-list-iter-start'
  netapp_commands :sdel    => 'cifs-share-delete'
  netapp_commands :sadd    => 'cifs-share-add'
  netapp_commands :smodify => 'cifs-shre-change'
  
  mk_resource_methods

  def self.instances
    Puppet.debug("Puppet::Provider::netapp_share: got to self.instances.")
    shares = []

#    # Get a list of all shares
#    result = slist
#    Puppet.debug("Share listing data: #{result.inspect}")
#
#    # Get a list of exports
#    cifs_list = result.child_get("cifs-shares")
#    cifsshares = cifs_list.children_get()
#    # Itterate through each 'export-info' block.
#    cifsshares.each do |cifsshare|
#      cifs-share-info = cifshare.children_get()
#      cifs-share-info.each do |attributename|
#        share = { "#{attributename}" => attributename }
#      end
#      
#      # Create the instance and add to exports array.
#      Puppet.debug("Creating instance for #{share['share-name']}. \n")
#      shares << new(share)
#    end
#  
#    # Return the final share array. 
#    Puppet.debug("Returning exports array. #{shares}")
#    shares
  end
  
  def self.prefetch(resources)
    Puppet.debug("Puppet::Provider::netapp_share: Got to self.prefetch.")
    # Itterate instances and match provider where relevant.
    instances.each do |prov|
      Puppet.debug("Prov.name = #{resources[prov.name]}. ")
      if resource = resources[prov.name]
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
    Puppet.debug("Puppet::Provider::netapp_share: destroying Netapp export rule #{@resource[:name]} against path #{@resource[:path]}")
    @property_hash[:ensure] = :absent
  end

  def exists?
    Puppet.debug("Puppet::Provider::netapp_share: checking existance of Netapp export rule #{@resource[:name]}.")
    @property_hash[:ensure] == :present
  end

   
end
