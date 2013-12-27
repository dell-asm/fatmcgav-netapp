# == Define: netapp::lun_clone_unclone
#
# Utility class for creation of a NetApp Lun clone and destroy operation.
#

define netapp::lun_clone_unclone (
  $parentlunpath,
  $parentsnap,
  $snapshot,
  $volume,
  $ensure        			   = 'present',
  $spacereservationenabled      	   =  false,
  $force      	                           =  false,
) {

  netapp_lun_clone_unclone { "${name}":
    ensure        		=> $ensure,
    parentlunpath      	        => $parentlunpath,
    parentsnap                  => $parentsnap,
    snapshot                    => $snapshot,
    volume      		=> $volume,
    spacereservationenabled     => $spacereservationenabled,
    force                       => $force,
  }
 }
