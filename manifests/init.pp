#
# Example reporter usage to collect some basic system info
#
# Test from this directory with: 
#
#   puppet apply --modulepath=../.. -e 'include reporter' --verbose
#
class reporter {

  Reporter { loglevel => info }

  reporter { 
    'reporter_message':
      echoonly => true,
      loglevel => notice,
      message  => 'Running example reporter class';
    'passwd_sum':
      exec     => ['sum', '/etc/passwd'];
    'ruby_version':
      ruby     => 'RUBY_VERSION';
    ['architecture', 'kernel', 'kernelversion', 'memorysize', 'osfamily', 
     'processorcount', 'puppetversion', 'swapsize', 'virtual']:;
  }
}
