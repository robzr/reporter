# reporter

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with reporter](#setup)
    * [Setup requirements](#setup-requirements)
    * [Beginning with reporter](#beginning-with-reporter)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

This module provides a simplified interface for recording & extracting of facts, 
static strings, system commands and ruby commands via Puppet reporting.

Creates a new resource type, Reporter, which can be used to run arbitrary
shell or Ruby commands, facts, or static strings, which are then recorded in
the native Puppet report, and can be extracted by the (soon to be included)
reporter script, which allows for simple scanning for changes across time,
aggregateing output for multiple hosts, or querying hosts.

## Setup

### Setup Requirements

Since reporter includes a new resource type, it does require pluginsync to be
enabled.

### Beginning with reporter

Simply install the module using `puppet module install robzr-reporter`, and
write at least one resource definition using the Reporter resource type.

To extract the reported output, you can manually examine the puppet reporting
files, or use the soon-to-be included reporter utility.

## Usage

After installing the reporter modules, you simply declare some Reporter 
resources, like:
```
  reporter { 
    'passwd_sum':
      exec    => 'sum /etc/passwd';
    'ruby_version':
      format  => 'Ruby version is: %s',
      ruby    => 'RUBY_VERSION';
    'puppet_version':
      logonly => true,
      fact    => 'puppetversion';
    'static_message':
      echoonly => true,
      message  => 'Echo a static message';
    'processorcount': ;
  }
```

## Reference

Reporter provides a single resource type, which will be resolved on the agent,
with the output reported (by default) to the Puppet log and into the Puppet 
report file for later extraction.

The default behavior registers a change for easy retrieval from a Puppet report
file via the resource.events.desired_value property.  This can be modified
by using the logonly paramter (which does not register a change, but does
log to the output), or via echoonly, which bypasses Puppet completely by 
outputting directly to STDOUT.  The Puppet log level can be altered with the
loglevel meta-parameter, in order to suppress output in normal runs.

A reporter resource is interpeted in one of four ways - as a Puppet parsed static
message, fact, shell command or ruby command.  These can be specified by using
one of the parameters exec, fact, message, or ruby.  The type parameter can
also be used to explicitely label the type.  If no type or parameter is 
used, the default is to interpret the resource name as a fact.  The default
behavior or reporter is to record a change, which is how the output is recorded.

- ```exec => '/bin/command parameter1 ...'``` runs a shell command with normal shell parsing
- ```exec => ['/bin/command', 'parameter1']``` runs a command without shell parsing
- ```fact => 'factname'``` resolves a fact
- ```message => "Puppet Parsed String"``` records a string, as parsed by Puppet
- ```ruby => '"StRiNg".downcase'``` runs arbitrary ruby commands
- ```source => 'puppet:///modules/reporter/file.sh'``` runs executable (not yet implemented)

A few additional parameters are supplied in order to alter the behavior:

- ```echoonly => true``` will not log or record a change; only prints to STDOUT
- ```format => 'Output: %s'``` Output format in sprintf syntax
- ```loglevel => info``` can be used to suppress notice output
- ```logonly => true``` will not record a change, but does log
- ```type => message``` forces a type, uses resource name for target
- ```withpath => false``` will not prepend the resource path to log output

## Examples
```
  # Records facts (default behavior with no type specified)
  reporter {
    ['operatingsystem', 'osfamily', 'puppetversion', 'swapfree']: ;
  }

  # Quietly records a directory listing from /etc
  reporter {
    'ls_etc':
      loglevel => info,
      exec => 'ls -l /etc';
  }

  # Using Puppet's built in string parsing with a static message
  reporter {
    'apache_vhostdir':
      message => "Directory: ${apache::params::vhostdir}";
  }

  # Bypass puppet reporting and logging
  reporter {
    'dont_run':
      echoonly => true,
      message  => 'You should not be running this module!!!';
  }

  # Print output from a command as a warning log entry
  reporter {
    'previous_login':
      format => '%s logged in before you.',
      loglevel => warning,
      logonly => true,
      exec  => 'last | head -2 | tail -1 | cut -f1 -d\ ';
  }
```

## Limitations

Only tested on POSIX (Linux, Mac) systems.  Works with legacy Puppet and Ruby versions
for maximum compatibility.

## Development

Contact me [via GitHub](https://github.com/robzr/reporter/issues) with requests, issues, or if you would like to contribute.

## Release Notes/Contributors/Etc.

- 0.1.0 - Initial stable release

### TODO

- Add ruby script and module for parsing Puppet report files to extract reports
- Create a source parameter to serve executible files
- Look into resource collectors for more sophisticated installation
- Test & document using with notify/subscribe to chain events
