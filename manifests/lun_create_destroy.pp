# == Define: netapp::lun_create_destroy
#
# Utility class for creation of a NetApp Lun create and destroy operation.
#

define netapp::lun_create_destroy (
  $size_bytes    	     = '2000',
  $ensure        	     = 'present',
  $prefix_size_bytes         = '',
  $ostype      		     = '',
  $space_res_enabled         = false, 
  $force                     = false, 
) {

  netapp_lun_create_destroy { "${name}":
    ensure        	=> $ensure,
    size_bytes      	=> $size_bytes,
    prefix_size_bytes   => $prefix_size_bytes,
    ostype      	=> $ostype,
    space_res_enabled   => $space_res_enabled,
    force               => $force,
  }
 }
