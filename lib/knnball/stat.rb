# encoding: UTF-8

# Copyright (C) 2011 Olivier Amblet <http://olivier.amblet.net>
#
# knnball is freely distributable under the terms of an MIT license.
# See LICENSE or http://www.opensource.org/licenses/mit-license.php.



module KnnBall
  module Stat
    
    # sort an array with the goal of having the median at the middle.
    #
    # Values on the left will be lesser or equal to the median and
    # values on the right higher than or equal to the median.
    def self.median!(data, &cmp_block)
      midx = median_index(data)
      left = 0
      right = data.size-1
      pidx = pivot!(data, midx, 0, data.size-1, &cmp_block)
      while pidx != midx do
        if(pidx < midx)
          left = pidx + 1
        else
          right = pidx - 1
        end
        pidx = pivot!(data, midx, left, right, &cmp_block)
      end
      return data[midx]
    end
    
    # @param data an array of data that will be changed in place
    # @param pivot index of the pivot value in data
    # @return the final index of the pivot
    def self.pivot!(data, pivot, left = 0, right = data.size-1, &cmp_block)
      value = data[pivot]
      cmp_block = Proc.new {|a, b| a <=> b} if cmp_block.nil?
      
      # push pivot value at the end of data
      data[pivot], data[right] = data[right], data[pivot]
      
      # swap position if current idx <= pivot value
      for i in (left..right-1)
        if(cmp_block.call(data[i], value) < 1)
          data[left], data[i] = data[i], data[left]
          left = left + 1
        end
      end
      
      # push the pivot value just after the last index
      data[left], data[right] = data[right], data[left]
      return left
    end
    
    def self.median_index(data)
      (data.size % 2 == 0) ? (data.size - 1)/ 2 : data.size / 2
    end
  end
end