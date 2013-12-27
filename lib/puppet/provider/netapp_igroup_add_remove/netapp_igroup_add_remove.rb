require 'puppet/provider/netapp'

Puppet::Type.type(:netapp_igroup_add_remove).provide(:netapp_igroup_add_remove, :parent => Puppet::Provider::Netapp) do
  @doc = "Manage Netapp iGroup add/remove operations."

  confine :feature => :posix
  defaultfor :feature => :posix
 
  netapp_commands :igrouplist     => 'igroup-list-info'
  netapp_commands :igroupadd      => 'igroup-add'
  netapp_commands :igroupremove   => 'igroup-remove'
  

 def get_igroup_status  

    igroup_status = 'false'
    Puppet.debug("Fetching iGroup information")
     begin
       result = igrouplist("initiator-group-name", @resource[:name])
       Puppet.debug(" iGroup informations - #{result}")
     rescue   
     
     end
	
      if (result != nil)
        igroup_status = 'true'
      end
	  
    return igroup_status  
       
  end

  def get_create_command 
    arguments = ["initiator-group-name", @resource[:name], "initiator", @resource[:initiator]]
     if @resource[:force] == :true
       arguments +=["force", @resource[:force] ] 
     end
	 
    return arguments
  end

def get_destroy_command 
    arguments = ["initiator-group-name", @resource[:name], "initiator", @resource[:initiator]]
     if @resource[:force] == :true
       arguments +=["force", @resource[:force] ] 
     end
	 
    return arguments
  end

  def create   
    Puppet.debug("Inside create method.")
    igroupadd(*get_create_command)
    igroup_status = get_igroup_status
    Puppet.debug("iGroup existence status after executing add operation - #{igroup_status}")
  end

  def destroy  
    Puppet.debug("Inside destroy method.")
    igroupremove(*get_destroy_command)
    igroup_status = get_igroup_status
    Puppet.debug("iGroup existence status after executing remove operation - #{igroup_status}")
  end

 def exists?
    Puppet.debug("Inside exists method.")
    igroup_status = get_igroup_status
    if  "#{igroup_status}" == "false"
      Puppet.debug("iGroup existence status before executing any add/remove operation - #{igroup_status}")
      false
    else
      Puppet.debug("iGroup existence status before executing any add/remove operation - #{igroup_status}")
      true
    end

    end

end



