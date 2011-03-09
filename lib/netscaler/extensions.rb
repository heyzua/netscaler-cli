
# Alter the standard Array class
class Array
  def to_s
    base = ""
    each do |e|
      base << e.to_s
      base << "\n"
    end
    base
  end

  def to_json(prefix=nil)
    value = if prefix
              prefix.dup
            else
              ""
            end
    if empty?
      return value << "[]"
    end

    indent = if prefix
               "  " << prefix
             else
               "  "
             end

    value << "[\n"
    
    each_with_index do |e, i|
      value << indent
      value << e.to_json(indent)
      value << ",\n" unless i == length - 1
    end

    value << "\n"
    value << prefix if prefix
    value << "]\n"
  end
end

class String
  def to_json(prefix=nil)
    "\"#{self}\""
  end
end
