Puppet::Type.newtype(:netapp_share) do 
  @doc = "Manage Netapp Share creation, modification and deletion."
  
  apply_to_device
  
  ensurable
  
  newparam(:name) do
    desc "The share name.."
    isnamevar
  end

  newparam(:path) do
    desc "The folder to share.  Valid format is /vol/[volume_name](/[qtree_name])"
    validate do |value|
      unless value =~ /^(\/[\w]+){2,3}$/
        raise ArgumentError, "%s is not a valid export filer path." % value
      end
    end
  end
  
  newparam(:access_rights) do
      desc "Access rights to be set to the above share and user."
      newvalues(:NoAccess, :Read, :Change, :FullControl)
      defaultto(:FullControl)
  end
  
  # Autorequire any matching netapp_volume resources. 
  autorequire(:netapp_volume) do
    requires = []
    [self[:path]].compact.each do |path|
      if match = %r{/\w+/(\w+)(?:/\w+)?$}.match(path)
        requires << match.captures[0]
      end
    end
    requires
  end
  
  # Autorequire any matching netapp_qtree resources. 
  autorequire(:netapp_qtree) do
    requires = []
    [self[:path]].compact.each do |path|
      if match = %r{/\w+/\w+(?:/(\w+))?$}.match(path)
        qtree = match.captures[0]
        requires << qtree if qtree
      end
    end
    requires
  end
  
end
