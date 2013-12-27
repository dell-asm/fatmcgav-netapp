Puppet::Type.newtype(:netapp_lun_map_unmap) do 
  @doc = "Manage Netapp Lun map and unmap."
  
  apply_to_device
  
  ensurable

  newparam(:name) do
    desc "Path of the LUN."
  end

  newparam(:force, :boolean => true) do
    desc "Forcibly online the lun, disabling mapping onflict checks with the high-availability partner."
    newvalues(:true, :false)
    defaultto :false
  end

  newparam(:initiatorgroup) do 
  end
  
  newparam(:lunid) do 
  end
  
end
