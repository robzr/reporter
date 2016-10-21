#
# See https://docs.puppet.com/guides/custom_types.html
#
Puppet::Type.newtype(:reporter) do
  require 'pp'

  @doc = <<-EOF
    Allows for reporting of arbitrary command output or facts.
  EOF

  newparam(:name, :namevar => true) do
    desc "The name of the reporter."
  end

  newparam(:echoonly, :boolean => true, :parent => Puppet::Parameter::Boolean) do
    desc "When set, will echo output but not log or record a change."
    defaultto false
  end

  newparam(:exec) do
    desc "Command to execute, output is reported."
    newvalues(/^.*$/)
  end

  newparam(:fact) do
    desc "Fact to report."
    validate { |fact| provider.fact_or_die? fact }
  end

  newparam(:format) do
    desc "Sprintf format to use for output."
    defaultto 'Format: %s'
  end

  newparam(:logonly, :boolean => true, :parent => Puppet::Parameter::Boolean) do
    desc "When set, will log output but not record a change."
    defaultto false
  end

  newparam(:message) do
    desc "Static message."
    newvalues(/^.*$/)
  end

  newparam(:ruby) do
    desc "Ruby command(s), return value is reported."
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
    desc "Output to report."

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
