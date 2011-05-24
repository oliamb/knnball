# encoding: UTF-8

# Copyright (C) 2011 Olivier Amblet <http://olivier.amblet.net>
#
# knnball is freely distributable under the terms of an MIT license.
# See LICENSE or http://www.opensource.org/licenses/mit-license.php.



module KnnBall
  
  # KD-Tree implementation
  class KDTree
    attr_accessor :root
    
    def initialize(root = nil)
      @root = root
    end
    
    def nearest(coord, &cmp_block)
      return nil if root.nil?
      return nil if coord.nil?
      
      # Find the parent to which this coord should belongs to
      # This will be our best first try
      result = parent(coord)
      smallest = result.distance(coord)
      
      # Starting back from the root, we check all rectangle that
      # might overlap the smallest one.
      best = [smallest]
      better_one = root.nearest(coord, best)
      return (better_one || result).value
    end
    
    # Retrieve the parent to which this coord should belongs to
    def parent(coord)
      current = root
      idx = current.dimension-1
      result = nil
      while(result.nil?)
        if(coord[idx] <= current.coord[idx])
          if current.left.nil?
            result = current 
          else
            current = current.left
          end
        else
          if current.right.nil?
            result = current 
          else
            current = current.right
          end
        end
        idx = current.dimension-1
      end
      return result
    end
    
    def empty?
      root.nil?
    end
    
    def to_a
      return root.to_a
    end
    
    def each(&proc)
      raise "tree is nil" if @root.nil?
      each_ball(@root, &proc)
    end
    
    def map(&proc)
      res = []
      self.each {|b| res << yield(b) }
      return res
    end
    
    def to_s
      "<KDTree @root=#{@root.to_s}>"
    end
    
    private
    
    def each_ball(b, &proc)
      return if b.nil?
      
      yield(b)
      each_ball(b.left, &proc) unless (b.left.nil?)
      each_ball(b.right, &proc) unless (b.right.nil?)
      return
    end
  end 
end