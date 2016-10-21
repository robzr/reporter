#
# See https://docs.puppet.com/guides/custom_types.html
#
Puppet::Type.newtype(:reporter) do
  require 'pp'

  @doc = <<-EOF
    Allows for reporting of arbitrary command output or facts.
  EOF

  newparam(:name, :namevar => true) do
    desc 'The name of the reporter, if used alone is parsed as a fact.'
  end

  newparam(:echoonly, :boolean => true, :parent => Puppet::Parameter::Boolean) do
    desc 'When set, will print to STDOUT but not log or record a change.'
    defaultto false
  end

  newparam(:exec) do
    desc 'Executes command, uses output. String for shell parsing, array to bypass.'
    newvalues(/^.*$/)
  end

  newparam(:fact) do
    desc 'Specifies a fact to report.'
    validate { |fact| provider.fact_or_die? fact }
  end

  newparam(:format) do
    desc 'Sprintf format to use for output - defaults to "%s" (output only).'
    defaultto 'Format: %s'
  end

  newparam(:logonly, :boolean => true, :parent => Puppet::Parameter::Boolean) do
    desc 'When set, will log output but not record a change.'
    defaultto false
  end

  newparam(:message) do
    desc 'Static message, will be parsed by Puppet.'
    newvalues(/^.*$/)
  end

  newparam(:ruby) do
    desc 'Ruby command(s), return value is reported.'
    newvalues(/^.*$/)
  end

  # TODO: make this work
#  newparam(:source) do
#    desc "Provide a script to run"
#  end

  newparam(:type) do
    desc "Type of reporter resource (defaults to fact)"
    validate { |type| provider.valid_type_or_die? type }
  end

  newparam(:withpath) do
    desc "Whether to show the full object path. Defaults to false."
    defaultto :false

    newvalues(:true, :false)
  end


  newproperty(:output) do
    desc 'String or text to log, report or echo.'

    def retrieve
      :absent
    end

    # Determines if it is considered a "change" or not
    def insync?(is)
      if @resource[:echoonly]
        puts @resource[:output]
        true
      elsif @resource[:logonly]
        case @resource[:withpath]
        when :true
          send(@resource[:loglevel], @resource[:output])
        else
          Puppet.send(@resource[:loglevel], @resource[:output])
        end
        true
      else
        false
      end
    end

    defaultto {
      if @resource[:format]
        @resource[:format] % provider.output
      else
        provider.output
      end
    }
  end
end
