def find_project_output_directory(derived_data_paths, project_prefix, project_suffix_pattern, target_names)

  return nil unless derived_data_paths

  paths = []

  # looking for derived data
  derived_data_paths.each do |derived_data_path|
    IO.popen("find #{derived_data_path} -depth 1 -name \"#{project_prefix}#{project_suffix_pattern}\" -type d  -exec find {} -name \"i386\" -o -name \"armv*\" -o -name \"x86_64\" -type d \\; ") { |f|
      f.each do |line|
        paths << line
      end
    }
  end

  $stderr.puts "There were #{paths.length} directories found"
  if paths.empty?
    $stderr.puts "Cannot find projects that starts with '#{project_prefix}'"
    exit 1
  end

  filtered_by_target_paths = paths

  if target_names != nil && target_names.length > 0
    filtered_by_target_paths = paths.find_all { |path| 
       target_names.any? { |target| /#{target}[^\.]*\.build\/Objects-normal/.match path }
    }
    $stderr.puts "After target filtration there is #{filtered_by_target_paths.length} directories left"
    if paths.empty?
      $stderr.puts "Cannot find projects that starts with '#{project_prefix}'' and has target name that starts with '#{target_names}'"
      exit 1
    end

    paths_sorted_by_time = filtered_by_target_paths.sort_by { |f| File.ctime(f.chomp) }
    last_modified_dirs = target_names.map { |target|
      filtered_by_target = filtered_by_target_paths.find_all { |path| /#{target}[^\.]*\.build\/Objects-normal/.match path }
      last_modified_dir = filtered_by_target.last.chomp
      $stderr.puts "Last modifications for #{target} were in\n#{last_modified_dir}\ndirectory at\n#{File.ctime(last_modified_dir)}"
      last_modified_dir
    }
    return last_modified_dirs

  end

  paths_sorted_by_time = filtered_by_target_paths.sort_by { |f| File.ctime(f.chomp) }

  last_modified_dir = paths_sorted_by_time.last.chomp
  $stderr.puts "Last modifications were in\n#{last_modified_dir}\ndirectory at\n#{File.ctime(last_modified_dir)}"

  [last_modified_dir]
end

def is_primitive_swift_type?(dest)
    /^(BOOL|alignofValue|anyGenerator|anyGenerator|assert|assertionFailure|debugPrint|debugPrint|dump|dump|fatalError|getVaList|isUniquelyReferenced|isUniquelyReferencedNonObjC|isUniquelyReferencedNonObjC|max|max|min|abs|alignof|min|numericCast|numericCast|numericCast|numericCast|precondition|preconditionFailure|print|print|readLine|sizeof|sizeofValue|strideof|strideofValue|swap|transcode|unsafeAddressOf|unsafeBitCast|unsafeDowncast|unsafeUnwrap|withExtendedLifetime|withExtendedLifetime|withUnsafeMutablePointer|withUnsafeMutablePointers|withUnsafeMutablePointers|withUnsafePointer|withUnsafePointers|withUnsafePointers|withVaList|withVaList|zip|Any|AnyClass|BooleanLiteralType|CBool|CChar|CChar16|CChar32|CDouble|CFloat|CInt|CLong|CLongLong|CShort|CSignedChar|CUnsignedChar|CUnsignedInt|CUnsignedLong|CUnsignedLongLong|CUnsignedShort|CWideChar|ExtendedGraphemeClusterType|Float32|Float64|FloatLiteralType|IntMax|IntegerLiteralType|StringLiteralType|UIntMax|UnicodeScalarType|Void|AnyBidirectionalCollection|AnyBidirectionalIndex|AnyForwardCollection|AnyForwardIndex|AnyRandomAccessCollection|AnyRandomAccessIndex|AnySequence|Array|ArraySlice|AutoreleasingUnsafeMutablePointer|Bool|COpaquePointer|CVaListPointer|Character|ClosedInterval|CollectionOfOne|ContiguousArray|Dictionary|DictionaryGenerator|DictionaryIndex|DictionaryLiteral|Double|EmptyGenerator|EnumerateGenerator|EnumerateSequence|FlattenBidirectionalCollection|FlattenBidirectionalCollectionIndex|FlattenCollectionIndex|FlattenSequence|Float|GeneratorSequence|HalfOpenInterval|IndexingGenerator|Int|Int16|Int32|Int64|Int8|JoinGenerator|JoinSequence|LazyCollection|LazyFilterCollection|LazyFilterGenerator|LazyFilterIndex|LazyFilterSequence|LazyMapCollection|LazyMapGenerator|LazyMapSequence|LazySequence|ManagedBufferPointer|Mirror|MutableSlice|ObjectIdentifier|PermutationGenerator|Range|RangeGenerator|RawByte|Repeat|ReverseCollection|ReverseIndex|ReverseRandomAccessCollection|ReverseRandomAccessIndex|Set|SetGenerator|SetIndex|Slice|StaticString|StrideThrough|StrideThroughGenerator|StrideTo|StrideToGenerator|String|String.CharacterView|String.CharacterView.Index|String.UTF16View|String.UTF16View.Index|String.UTF8View|String.UTF8View.Index|String.UnicodeScalarView|String.UnicodeScalarView.Generator|String.UnicodeScalarView.Index|UInt|UInt16|UInt32|UInt64|UInt8|UTF16|UTF32|UTF8|UnicodeScalar|Unmanaged|UnsafeBufferPointer|UnsafeBufferPointerGenerator|UnsafeMutableBufferPointer|UnsafeMutablePointer|UnsafePointer|Zip2Generator|Zip2Sequence)$/.match(dest) != nil
end

def is_filtered_swift_type?(dest)
  /(ClusterType|ScalarType|LiteralType)$/.match(dest) != nil #or /^([a-z])/.match(dest) != nil
end

def is_filtered_objc_type?(dest)
  /^(dispatch_)|(DISPATCH_)/.match(dest) != nil #or /^([a-z])/.match(dest) != nil
end

def is_valid_dest?(dest, exclusion_prefixes)
  dest != nil and /^(#{exclusion_prefixes})/.match(dest) == nil and /^(<\s)?\w/.match(dest) != nil and !is_primitive_swift_type?(dest) and !is_filtered_swift_type?(dest) and !is_filtered_objc_type?(dest)
end
