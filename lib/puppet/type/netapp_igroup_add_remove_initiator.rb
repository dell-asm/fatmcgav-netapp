Puppet::Type.newtype(:netapp_igroup_add_remove_initiator) do 
  @doc = "Manage Netapp iGroup add and remove."
  
  apply_to_device
  
  ensurable

  newparam(:name) do
    desc "Name of iGroup"
  end

  newparam(:initiator) do 
  end

   newparam(:force, :boolean => false) do
    desc "Forcibly online the lun, disabling mapping onflict checks with the high-availability partner."
    newvalues(:true, :false)
    defaultto :false
  end
  
end
