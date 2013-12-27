# == Define: netapp::igroup_add_remove
#
# Utility class for creation of a NetApp iGroup add and remove initiator operation.
#

define netapp::igroup_add_remove_initiator (
  $initiator,
  $ensure              = 'present',
  $force               = false,
) {

  netapp_igroup_add_remove_initiator { "${name}":
    ensure               => $ensure,
    initiator            => $initiator,
    force                => $force,
  }
 }
