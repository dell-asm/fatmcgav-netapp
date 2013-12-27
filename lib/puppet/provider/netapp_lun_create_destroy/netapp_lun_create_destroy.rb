require 'puppet/provider/netapp'


Puppet::Type.type(:netapp_lun_create_destroy).provide(:netapp_lun_create_destroy, :parent => Puppet::Provider::Netapp) do
  @doc = "Manage Netapp Lun creation, modification and deletion."
  
  confine :feature => :posix
  defaultfor :feature => :posix
 
  netapp_commands :luncreate      => 'lun-create-by-size'
  netapp_commands :lundestroy     => 'lun-destroy'
  netapp_commands :lunlist        => 'lun-list-info'
  
  mk_resource_methods
   
  def get_lun_existence_status  

    lun_exists = 'false'
    Puppet.debug("Fetching Lun information")
	begin
     result = lunlist("path", @resource[:name])
	 Puppet.debug(" Lun informations - #{result}")
	rescue   
     
	end
	
	 if (result != nil)
       lun_exists = 'true'
      end
	  
    return lun_exists  
       
  end

  def get_create_command 
    arguments = ["path", @resource[:name], "size", @resource[:size_bytes]]

     if @resource[:space_res_enabled] == :true
       arguments +=["space-reservation-enabled", @resource[:space_res_enabled]] 
     end

     if ((@resource[:prefix_size_bytes]!= nil) && (@resource[:prefix_size_bytes].length > 0))
       arguments +=["prefix-size", @resource[:prefix_size_bytes]] 
     end

     if ((@resource[:ostype]!= nil) && (@resource[:ostype].length > 0))
       arguments +=["ostype", @resource[:ostype]] 
     end
	 
    return arguments
  end

  def get_destroy_command 
    arguments = ["path", @resource[:name]]
     if @resource[:force] == :true
       arguments +=["force", @resource[:force] ] 
     end
	 
    return arguments
  end
  
  def create   
    Puppet.debug("Inside create method.")
    exitvalue = luncreate(*get_create_command)  
    Puppet.debug("Current Lun size after executing create operation - #{exitvalue.child_get_int("actual-size")}")	
  end

  def destroy  
    Puppet.debug("Inside destroy method.")
    lundestroy(*get_destroy_command)
    lun_exists = get_lun_existence_status
    Puppet.debug("Lun existence status after executing destroy operation - #{lun_exists}")
  end
  
  def exists?
    Puppet.debug("Inside exists method.")
    lun_exists = get_lun_existence_status
    if  "#{lun_exists}" == "false"
      Puppet.debug("Lun existence status before executing any create/destroy operation - #{lun_exists}")
      false
    else
      Puppet.debug("Lun existence status before executing any create/destroy operation - #{lun_exists}")
      true
    end

    end

  
end
