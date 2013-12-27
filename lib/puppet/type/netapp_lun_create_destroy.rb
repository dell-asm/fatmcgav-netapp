Puppet::Type.newtype(:netapp_lun_create_destroy) do 
  @doc = "Manage Netapp Volume creation, modification and deletion."
  
  apply_to_device
  
  ensurable
  
  newparam(:name) do
    desc "The volume name. Valid characters are a-z, 1-9 & underscore."
  end

  newparam(:ostype) do  
  end
  
  newparam(:size_bytes) do  
  end
  
  newparam(:prefix_size_bytes) do  
  end

   newparam(:space_res_enabled, :boolean => false) do
    newvalues(:true, :false)
    defaultto :false
  end

  newparam(:force, :boolean => false) do
    newvalues(:true, :false)
    defaultto :false
  end
  
end
