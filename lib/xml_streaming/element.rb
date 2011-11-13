
class XMLStreaming::Element
  attr :name
  attr :prefix
  attr :attributes
  attr :uri
  attr :namespaces
  attr :text
  attr :children

  # FIXME: spec this, if you use it outside of the specs!
  def self.simple(name, text='', attrs={})
    name, prefix = *name.split(':')
    new(name, attrs, prefix, nil, []).tap {|e|
      e.add_text(text)
    }
  end

  def initialize(name, attrs, prefix, uri, ns)
    @name, @attributes, @prefix, @uri, @namespaces =
      name, attrs, prefix, uri, ns
    @text = ''
    @children = []
  end

  def add_text(text)
    @text += text
  end

  def add_child(element)
    @children.push(element)
  end

  def finalize!
    @finalized = true
  end

  def to_xml(part=nil)
    full_name = prefix ? [prefix, name].join(':') : name
    case part
    when :start
      start_xml(full_name)
    when :end
      end_xml(full_name)
    else
      [start_xml(full_name),
        children.map { |child|
          child.to_xml
        }.join(''),
        end_xml(full_name)
      ].join('')
    end
  end

  def finalized?
    @finalized ? true : false
  end

  def all_attributes
    attrs = uri ? attributes.merge(:xmlns => uri) : attributes.dup
    namespaces.each do |prefix, namespace|
      attrs["xmlns:#{prefix}".to_sym] = namespace if prefix
    end
    return attrs
  end

  private

  def start_xml(full_name)
    ["<#{full_name}",
      (all_attributes.any? ?
        all_attributes.each_pair.inject('') { |attr_string, (name, value)|
          escaped_value = value.gsub('"') { "\\\"" }
          attr_string + " #{name}=\"#{escaped_value}\""
        } :
        ''),
      '>'
    ].join('')
  end

  def end_xml(full_name)
    "</#{full_name}>"
  end
end

