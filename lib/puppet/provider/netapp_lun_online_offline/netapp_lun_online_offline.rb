require 'puppet/provider/netapp'

Puppet::Type.type(:netapp_lun_online_offline).provide(:netapp_lun_online_offline, :parent => Puppet::Provider::Netapp) do
  @doc = "Manage Netapp Lun online/offline."

  confine :feature => :posix
  defaultfor :feature => :posix
 
  netapp_commands :lunlist        => 'lun-list-info'
  netapp_commands :lunoffline     => 'lun-offline'
  netapp_commands :lunonline      => 'lun-online'
  

 def get_lun_status  

    lun_status = 'offline'
    Puppet.debug("Fetching Lun information")
    result = lunlist("path", @resource[:name])
    Puppet.debug(" Lun informations - #{result}")

    luns = result.child_get("luns")
    luns_info = luns.children_get()

      # Itterate through the luns-info blocks
      luns_info.each do |lun|
      # Pull out relevant info
      lun_state = lun.child_get_string("online")
      
      if ((lun_state != nil) && (lun_state == "true"))
       lun_status = 'online'
      end
	  
	  end
	  
    return lun_status  
       
  end

  def get_create_command 
    arguments = ["path", @resource[:name]]
     if @resource[:force] == :true
       arguments +=["force", @resource[:force]] 
     end
	 
    return arguments
  end


  def create   
    Puppet.debug("Inside create method.")
    lunonline(*get_create_command)
    lun_status = get_lun_status 
    Puppet.debug("Current Lun status after executing online operation - #{lun_status}")	
  end

  def destroy  
    Puppet.debug("Inside destroy method.")
    lunoffline("path", @resource[:name])
    lun_status = get_lun_status 
    Puppet.debug("Current Lun status after executing offline operation - #{lun_status}")	
  end

 def exists?
    Puppet.debug("Inside exists method.")
    lun_status = get_lun_status
    if  "#{lun_status}" == "offline"
      Puppet.debug("Lun status before executing any online/offline operation - #{lun_status}")
      false
    else
      Puppet.debug("Lun status before executing any online/offline operation - #{lun_status}")
      true
    end

    end

end



