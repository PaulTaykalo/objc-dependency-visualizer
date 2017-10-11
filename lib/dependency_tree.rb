module DependencyItemType
  CLASS = 'class'.freeze
  STRUCTURE = 'struct'.freeze
  PROTOCOL = 'protocol'.freeze
  UNKNOWN = 'unknown'.freeze
end

module DependencyLinkType
  INHERITANCE = 'inheritance'.freeze
  IVAR = 'ivar'.freeze
  CALL = 'call'.freeze
  PARAMETER = 'parameter'.freeze
  UNKNOWN = 'unknown'.freeze
end

class DependencyTree

  attr_reader :links_count
  attr_reader :links

  def initialize
    @links_count = 0
    @links = []
    @registry = {}
    @types_registry = {}
    @links_registry = {}
  end

  def add(source, dest, type = DependencyLinkType::UNKNOWN)
    register source
    register dest
    register_link(source, dest, type)

    return if connected?(source, dest)

    @links_count += 1
    @links += [{source: source, dest: dest}]

  end

  def connected?(source, dest)
    @links.any? {|item| item[:source] == source && item[:dest] == dest}
  end

  def isEmpty?
    @links_count.zero?
  end

  def register(object, type = DependencyItemType::UNKNOWN)
    @registry[object] = true
    if @types_registry[object].nil? || @types_registry[object] == DependencyItemType::UNKNOWN
      @types_registry[object] = type
    end
  end

  def isRegistered?(object)
    !@registry[object].nil?
  end

  def type(object)
    @types_registry[object]
  end

  def objects
    @types_registry.keys
  end

  def link_type(source, dest)
    @links_registry[link_key(source, dest)] || DependencyLinkType::UNKNOWN
  end

  def links_with_types
    @links.map do |l|
      type = link_type(l[:source], l[:dest])
      l[:type] = type unless type == DependencyLinkType::UNKNOWN
      l
    end
  end

  def filter
    @types_registry.each { |item, type|
      next if yield item, type
      @types_registry.delete(item)
      @registry.delete(item)
      selected_links = @links.select { |link| link[:source] != item && link[:dest] != item }
      filtered_links = @links.select { |link| link[:source] == item || link[:dest] == item }
      filtered_links.each { |link| remove_link_type(link) }
      @links = selected_links
    }
  end

  def filter_links
    @links = @links.select { |link|
      yield link[:source], link[:dest], link_type(link[:source], link[:dest])
    }
  end  

  def remove_link_type(link)
    source, dest = link[:source], link[:dest]
    return unless source && dest
    @links_registry.delete(link_key(source, dest))
  end

  private

  def register_link(source, dest, type)
    return unless source && dest
    link_key = link_key(source, dest)
    registered_link = @links_registry[link_key]
    if registered_link.nil? || registered_link == DependencyLinkType::UNKNOWN
      @links_registry[link_key] = type
    end
  end

  def link_key(source, dest)
    source + '!<->!' + dest
  end

end