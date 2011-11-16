module MethodExecution
  def execute_method(*arguments, &block)
    focus = self.class.instance_variable_get('@metadata')

    # find the nearest method name
    while focus = focus[:example_group] do
      method = /^(?:(\#)|(\.|:))([\w?!=~]+)$/.match(focus[:description]) and break
    end

    arguments = @arguments || [] if arguments.empty?
    block = @block unless block_given?

    if method[1]
      # instance method
      result = subject.send(method[3], *arguments, &block)
    else
      # class method or scope
      result = described_class.send(method[3], *arguments, &block)
    end

    # this verifies all previously set method expectations
    # thusly, state verification takes place _after_ behaviour
    RSpec::Mocks.verify

    return result
  end

  # shortcut
  alias execute execute_method
end



