
module MockingHelper
  def mock!(name, *stubs)
    m = mock(name)
    instance_variable_set("@#{name.gsub(/\s+/, '_')}", m)
    m.stub(*stubs) if stubs.any?
    return m
  end
end
