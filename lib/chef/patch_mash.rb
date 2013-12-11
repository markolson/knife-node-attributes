class Chef
  class Node
    class ImmutableMash
      def to_hash
        h = {}
        self.each do |k,v|
          if v.respond_to?('to_hash')
            h[k] = v.to_hash
          elsif v.respond_to?('each')
            h[k] = []
            v.each do |i|
              if i.respond_to?('to_hash')
                h[k].push(i.to_hash)
              else
                h[k].push(i)
              end
            end
          elsif v == true or v == false
            h[k] = "#{v}"
          else
            h[k] = v
          end
        end
        return h
      end
    end
  end
end