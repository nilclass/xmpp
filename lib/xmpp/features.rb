
class XMPP::Features < XMLStreaming::Stanza
  register(:features, self)

  def starttls?
    children.select {|child| child.name == 'starttls' }.any?
  end

  def mechanisms?
    children.select {|child| child.name == 'mechanisms' }.any?
  end

  def mechanisms
    children.select { |child|
      child.name == 'mechanisms'
    }.first.children.map { |mech|
      mech.name == 'mechanism' ? mech.text : nil
    }.compact
  end

  def to_s
    "#<XMPP::Features #{children.map(&:name).join(', ')}>"
  end
end
