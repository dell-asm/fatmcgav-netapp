Puppet::Type.newtype(:netapp_igroup_create_destroy) do 
  @doc = "Manage Netapp iGroup create and destroy."
  
  apply_to_device
  
  ensurable

  newparam(:name) do
    desc "Name of iGroup"
  end

  newparam(:initiatorgrouptype) do 
  end
  
  newparam(:ostype) do 
  end

  newparam(:bindportset) do 
  end

   newparam(:force, :boolean => false) do
    desc "Forcibly online the lun, disabling mapping onflict checks with the high-availability partner."
    newvalues(:true, :false)
    defaultto :false
  end
  
end
