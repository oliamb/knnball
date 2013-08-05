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

    # Retrieve the nearest point from the given coord array.
    #
    # available keys for options are :root and :limit
    #
    # Wikipedia tell us (excerpt from url http://en.wikipedia.org/wiki/Kd%5Ftree#Nearest%5Fneighbor%5Fsearch)
    #
    # Searching for a nearest neighbour in a k-d tree proceeds as follows:
    # 1. Starting with the root node, the algorithm moves down the tree recursively,
    #    in the same way that it would if the search point were being inserted
    #    (i.e. it goes left or right depending on whether the point is less than or
    #    greater than the current node in the split dimension).
    # 2. Once the algorithm reaches a leaf node, it saves that node point as the "current best"
    # 3. The algorithm unwinds the recursion of the tree, performing the following steps at each node:
    #    1. If the current node is closer than the current best, then it becomes the current best.
    #    2. The algorithm checks whether there could be any points on the other side of the splitting
    #       plane that are closer to the search point than the current best. In concept, this is done
    #       by intersecting the splitting hyperplane with a hypersphere around the search point that
    #       has a radius equal to the current nearest distance. Since the hyperplanes are all axis-aligned
    #       this is implemented as a simple comparison to see whether the difference between the splitting
    #       coordinate of the search point and current node is less than the distance (overall coordinates) from
    #       the search point to the current best.
    #       1. If the hypersphere crosses the plane, there could be nearer points on the other side of the plane,
    #          so the algorithm must move down the other branch of the tree from the current node looking for
    #          closer points, following the same recursive process as the entire search.
    #       2. If the hypersphere doesn't intersect the splitting plane, then the algorithm continues walking
    #          up the tree, and the entire branch on the other side of that node is eliminated.
    # 4. When the algorithm finishes this process for the root node, then the search is complete.
    #
    # Generally the algorithm uses squared distances for comparison to avoid computing square roots. Additionally,
    # it can save computation by holding the squared current best distance in a variable for comparison.
    def nearest(coord, options = {})
      return nil if root.nil?
      return nil if coord.nil?

      results = (options[:results] ? options[:results] : ResultSet.new({limit: options[:limit] || 1}))
      root_ball = options[:root] || root

      # keep the stack while finding the leaf best match.
      parents = []

      best_balls = []
      in_target = []

      # Move down to best match
      current_best = nil
      current = root_ball
      while current_best.nil?
        dim = current.dimension-1
        if(current.complete?)
          next_ball = (coord[dim] <= current.center[dim] ? current.left : current.right)
        elsif(current.leaf?)
          next_ball = nil
        else
          next_ball = (current.left.nil? ? current.right : current.left)
        end
        if ( next_ball.nil? )
          current_best = current
        else
          parents.push current
          current = next_ball
        end
      end

      # Move up to check split
      parents.reverse!
      results.add(current_best.quick_distance(coord), current_best.value)
      parents.each do |current_node|
        dist = current_node.quick_distance(coord)
        if results.eligible?( dist )
          results.add(dist, current_node.value)
        end

        dim = current_node.dimension-1
        if current_node.complete?
          # retrieve the splitting node.
          split_node = (coord[dim] <= current_node.center[dim] ? current_node.right : current_node.left)
          best_dist = results.barrier_value
          if( (coord[dim] - current_node.center[dim]).abs < best_dist)
            # potential match, need to investigate subtree
            nearest(coord, root: split_node, results: results)
          end
        end
      end
      return results.limit == 1 ? results.items.first : results.items
    end

    # Retrieve the parent to which this coord should belongs to
    def parent_ball(coord)
      current = root
      d_idx = current.dimension-1
      result = nil
      while(result.nil?)
        if(coord[d_idx] <= current.center[d_idx])
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
        d_idx = current.dimension-1
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

    # naive implementation
    def count
      root.count
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


__END__

     ,x,
    /   \
  x      x
/     o   `x
|      x´  `--x
x

     ,x,
    / | \
  x   | x\
/     |---`x----->
|     |o | |
x     | `x´
      |  |
      v  v