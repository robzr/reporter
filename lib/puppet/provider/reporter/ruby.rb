# Ref: https://docs.puppet.com/guides/provider_development.html
#
Puppet::Type.type(:reporter).provide(:ruby) do
  require 'pp'

  desc 'Universal provider, should work across all POSIX systems.'

  def fact_or_die?(fact)
    if is_fact? fact
      true
    else
      raise Puppet::Error, "fact \"#{fact}\" is not a valid fact"
    end
  end

#  def self.instances
#    Puppet.notice("#Reporter#instances #{resource[:name]}")
#    []
#  end

  def self.prefetch(catalog)
#    Puppet.notice("#Reporter#prefetch(#{catalog.keys.inspect})")
    []
  end

  def output
    case type
    when :exec
      exec_command
    when :fact
      Facter.value(target.to_sym)
    when :message
      target
    when :ruby
      eval_command
    else
      raise Puppet::Error, "Unknown type: #{type}"
    end
  end

  def output=(x)
    nil
  end

  def types
    [:exec, :fact, :message, :ruby]
  end

  def type_or_die?(type)
    unless is_type? type.to_sym
      raise Puppet::Error, "Type must be #{types.join(', ')}"
    end
  end

  private

  def eval_command(command = target)
    eval command
  end

  def exec_command(command = target)
    if command.is_a? String
      # TODO: test w/ STDERR
      %x{ #{command} }.chomp
    elsif command.is_a?(Array) && RUBY_VERSION < '1.9.2'
      # TODO: test w/ STDERR
      IO.popen(command.join(' ')).readlines.join.chomp
    elsif command.is_a? Array
      # TODO: test w/ overriding ENV
      command_array = command + [:err => [:child, :out]]
      IO.popen(command_array).readlines.join.chomp
    end
  rescue Puppet::ExecutionFailure => e
    Puppet.notice("#Reporter exec error (#{command}) -> #{e.inspect}")
    nil
  rescue Errno::ENOENT => e
    Puppet.notice("#Reporter exec ENOENT (#{command}) -> #{e.inspect}")
    nil
  end

  def is_fact?(fact)
    Facter.list.include? fact.to_sym
  end

  def is_type?(type)
    types.include? type.to_sym
  end

  def target
    target_and_type[0]
  end

  def type
    target_and_type[1]
  end

  def target_and_type
    if resource[:type]
      target = resource[resource[:type].to_sym] || resource[:name]
      unless is_type? resource[:type] && target
        raise Puppet::Error, "\"#{target}\" is not a valid fact"
      end
      [resource[resource[:type].to_sym], resource[:type].to_sym]
    else
      if resource[:exec]
        [resource[:exec], :exec]
      elsif resource[:message]
        [resource[:message], :message]
      elsif resource[:ruby]
        [resource[:ruby], :ruby]
      else
        fact = resource[:fact] || resource[:name]
        [fact, :fact] if fact_or_die? fact
      end
    end
  end
end
