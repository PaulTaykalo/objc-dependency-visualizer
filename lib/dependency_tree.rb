class DependencyTree

  attr_reader :links_count
  attr_reader :links

  def initialize
    @links_count = 0
    @links = []
    @registry = {}
  end

  def add(source, dest)
    @links_count += 1
    @links += [{ source: source, dest: dest}]
    register source
    register dest
  end

  def connected?(source, dest)
    @links.any? { |item| item[:source] == source && item[:dest] == dest }
  end

  def isEmpty?
    @links_count.zero?
  end

  def register(object)
    @registry[object] = true
  end
  def isRegistered?(object)
    !@registry[object].nil?
  end


end