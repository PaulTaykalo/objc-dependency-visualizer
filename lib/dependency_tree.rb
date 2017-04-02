class DependencyTree

  attr_reader :links_count
  attr_reader :links

  def initialize
    @links_count = 0
    @links = []
  end

  def add(source, dest)
    @links_count += 1
    @links += [{ source: source, dest: dest}]
  end

  def connected?(source, dest)
    @links.any? { |item| item[:source] == source && item[:dest] == dest }
  end

end