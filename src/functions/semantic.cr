module Crycord
  def semantic(v1 : String, v2 : String) : Bool | Int32
    iv1 = v1.split(".").map { |v| v.to_i }
    iv2 = v2.split(".").map { |v| v.to_i }
    compare = iv1 <=> iv2
    return compare
  end

  def semantic_array(arr : Array(String)) : String | Nil
    return unless arr.size > 0
    sorted_array = arr.sort { |a, b| semantic(a, b) }.reverse!
    return sorted_array[0]
  end

  def check_semantic(semantic : String) : Bool
    return !semantic.index(/^[0-9]+\.[0-9]+\.[0-9]+$/).nil?
  end

  def find_version_folder(path : Path) : Path | Nil
    arr = [] of String
    Dir.open(path.to_s).each_child do |item|
      arr << item if check_semantic(item)
    end
    sem_arr = semantic_array(arr)
    return if sem_arr.nil?
    return path.join(sem_arr)
  end
end
