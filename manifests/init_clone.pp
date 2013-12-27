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
   lun_clone_unclone { '/vol/testVolumeFCoE/testLun2':
      ensure         		=> 'present',
      parentlunpath             => '/vol/testVolumeFCoE/testLun8',
      parentsnap                => '200',
      snapshot                  => 'bbb',
      volume                    => '200',
      spacereservationenabled   => true,
      force                     => false,
    }
}

