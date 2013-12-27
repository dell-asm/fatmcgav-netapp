# Class: netapp
#
# This module manages netapp
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]

class netapp {

     lun_create_destroy { '/vol/testVolume/testLun1':
      ensure         	    => 'present',
      size_bytes            => '20000000',
      ostype                => 'vmware',
    } ->

     lun_online_offline { '/vol/testVolume/testLun1':
      ensure         => 'present',
      force          => true
    } ->

    igroup_create_destroy { 'TestGroupNetApp':
      ensure             => 'present',
      initiatorgrouptype => 'fcp',
      ostype             => 'vmware',
      
    } ->

    igroup_add_remove_initiator { 'TestGroupNetApp':
      ensure             => 'present',
      initiator          => '20:01:00:0e:aa:34:00:64',
      force              => true,
    } ->

     lun_map_unmap { '/vol/testVolume/testLun1':
      ensure          => 'present',
      initiatorgroup  => 'TestGroupNetApp',
    } 
}

