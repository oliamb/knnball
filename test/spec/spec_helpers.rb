module KnnBall
  module SpecHelpers

    # Solve the problem using the simpliest brute force
    # implementation to compare solutions with the
    # kd-tree algorithm.
    def brute_force(point, data, count=1)
      res = data.map do |p2|
        euc = Math.sqrt((p2[:point][0] - point[:point][0])**2.0 + (p2[:point][1] - point[:point][1])**2.0)
        [p2, euc]
      end
      results = res.sort {|a, b| a.last <=> b.last}[0..9].map{|r| r.first}

      if(count == 1)
        results.first
      else
        results[0..count-1]
      end
    end
  end
end