define netapp::create_cifs_share (
  $size,
  $ensure        = 'present',
  $aggr          = 'aggr1',
  $spaceres      = 'none',
  $snapresv      = 0,
  $autoincrement = true,
  $snapschedule  = {
    'minutes'       => 0,
    'hours'         => 0,
    'days'          => 0,
    'weeks'         => 0,
    'which-hours'   => 0,
    'which-minutes' => 0
  },
  $options       = {
    'convert_ucode'   => 'on',
    'no_atime_update' => 'on',
    'try_first'       => 'volume_grow'
  },
  $share_name,
  ) {

  netapp_volume { "${name}":
    ensure        => $ensure,
    initsize      => $size,
    aggregate     => $aggr,
    spaceres      => $spaceres,
    snapreserve   => $snapresv,
    autoincrement => $autoincrement,
    options       => $options,
    snapschedule  => $snapschedule,
  }
  
  netapp_share { "${share_name}":
    ensure   => $ensure,
    path => "/vol/${name}",
  }
 
}

