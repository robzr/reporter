class reporter {

  notify {
    'running_reporter':
      message => 'Running reporter module.';
  }

  reporter { 
    ['uptime', 'puppetversion']: ;
    'passwdsum':
      exec     => ['sum', '/etc/passwd'];
    'ruby_version':
      logonly => true,
      ruby     => 'RUBY_VERSION',
      loglevel => warning;
    'test_message':
      message => 'hi';
  }
}
