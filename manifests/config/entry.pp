define puppet::config::entry (
  $key,
  $value,
  $section,
  $sectionorder = 5,
  $joiner       = ',',
) {
  if is_array($value) {
    $value_ = join(flatten($value), $joiner)
  } elsif is_bool($value) {
    $value_ = bool2str($value)
  } else {
    $value_ = $value
  }

  # note the spaces at he end of the 'order' parameters,
  # they make sure that '1_main ' is ordered before '1_main_*'
  ensure_resource('concat::fragment', "puppet.conf_${section}", {
    target  => "${::puppet::dir}/puppet.conf",
    content => "\n\n[${section}]",
    order   => "${sectionorder}_${section} ",
  })

  if (!defined(Concat::Fragment["puppet.conf_${section}_${key}"])){
    concat::fragment{"puppet.conf_${section}_${key}":
      target  => "${::puppet::dir}/puppet.conf",
      content => "\n    ${key} = ${value_}",
      order   => "${sectionorder}_${section}_${key} ",
    }
  } else {
    concat::fragment{"puppet.conf_${section}_${key}_${name}":
      target  => "${::puppet::dir}/puppet.conf",
      content => "${joiner}${value_}",
      order   => "${sectionorder}_${section}_${key}_${name} ",
    }
  }
}
