# encoding: utf-8
class Hash
  
  def simple(keys)
    (self.keys & keys).each_with_object({}) { |key, hsh| hsh[key] = self[key]; hsh }
  end

end