# Learn more about module testing here:
#   https://docs.puppet.com/guides/tests_smoke.html
#
# Run from the module directory:
#   puppet apply --verbose --modulepath=.. tests/init.pp

# Default type => fact and the if fact => is not specified, it uses the name. 
reporter {'puppetversion':;}

# Manually specify fact since the name differs.  Bypass logging, and override 
# output format.
reporter {'puppetversion_echo':
  echoonly => true,
  fact     => 'puppetversion',
  format   => 'Puppet version is %s';
}

# Write to log with a warning loglevel, but do not record a change.  
reporter {'puppetversion_log':
  loglevel => warning,
  logonly  => true,
  message  => "Puppet version is ${puppetversion}";
}

# Specify ruby code to run
reporter {'rubyversion':
  ruby     => 'RUBY_VERSION';
}

# Specify arbitrary command to run (use standard shell parsing)
reporter {'rubyversion_exec':
  format   => 'System ruby version is: %s',
  exec     => 'ruby -v | cut -f2 -d\ ';
}

# Specify arbitrary command to run (bypass shell parsing)
reporter {'rubyversion_exec_noparse':
  format   => 'System ruby version is: %s',
  exec     => ['ruby', '-e', 'puts RUBY_VERSION']
}
