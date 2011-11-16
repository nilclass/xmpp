
class XMPP::Client::Callbacks
  def initialize
    @map = Hash.new { |h, k| h[k.to_sym] = [] }
  end

  def add(type, &block)
    @map[type.to_sym].push(block)
    return build_id(type)
  end

  def remove(*ids)
    ids.each do |id|
      type, index = parse_id(id)
      @map[type][index] = nil
    end
  end

  def once(type, &block)
    id = add(type) { |*args|
      block.call(*args)
      remove(id)
    }
  end

  def call(type, *args)
    $stderr.puts "CALLING CALLBACKS: #{type} (have: #{@map[type.to_sym].size})"
    @map[type.to_sym].each do |cb|
      cb.call(*args) if cb
    end
  rescue => exc
    $stderr.puts "FAILED TO EXECUTE CALLBACKS FOR #{type}:", "#{exc.message} (#{exc.class})", *exc.backtrace
  end

  private

  def build_id(type)
    return "#{type}-#{(@map[type].size - 1)}"
  end

  def parse_id(id)
    _, type, index = *id.match(/^(\w+)-(\d+)$/)
    return [type.to_sym, index.to_i]
  end
end
