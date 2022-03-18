require 'benchmark'
require 'matrix'

def main
  matrices = rand_matrices(3, 1_000_000)

  Benchmark.bmbm do |x|
    (1..10).each do |threads_amount|
      x.report("#{threads_amount} thread(s)") { job_with_n_threads(matrices, threads_amount) }
    end
  end
end

def job_with_n_threads(matrices, threads_amount)
  batches = get_batches(matrices, threads_amount)
  result = []
  threads = []

  threads_amount.times do |i|
    threads << Thread.new do
      result += determinants(batches[i])
    end
  end
  threads.each { |thr| thr.join }

  result
end

def rand_matrices(dimension, amount)
  matrices = []
  amount.times { matrices << Matrix.build(dimension) { rand } }
  matrices
end

def determinants(matrixes)
  matrixes.map {|m| m.determinant}
end

def get_batches(array, threads_amount)
  batches = []
  first = 0
  batch_size = 1 + array.size / threads_amount

  (1..threads_amount).each do |n|
    batches << array.slice(first, batch_size)
    first += batch_size
  end

  batches
end


# CPU

# MRI

#                    user     system      total        real
# 1 thread(s)    0.785012   0.000045   0.785057 (  0.787063)
# 2 thread(s)    0.824901   0.007862   0.832763 (  0.839676)
# 3 thread(s)    0.819248   0.000027   0.819275 (  0.824771)
# 4 thread(s)    0.826072   0.000000   0.826072 (  0.831693)
# 5 thread(s)    0.830769   0.004076   0.834845 (  0.841517)
# 6 thread(s)    0.834040   0.000001   0.834041 (  0.837145)
# 7 thread(s)    0.828143   0.003772   0.831915 (  0.837093)
# 8 thread(s)    0.822229   0.000009   0.822238 (  0.826083)
# 9 thread(s)    0.850590   0.003831   0.854421 (  0.860752)
# 10 thread(s)   0.860755   0.008024   0.868779 (  0.874629)

# JRuby

#                    user     system      total        real
# 1 thread(s)    1.370000   0.010000   1.380000 (  1.216216)
# 2 thread(s)    1.300000   0.010000   1.310000 (  0.668778)
# 3 thread(s)    1.500000   0.000000   1.500000 (  0.582577)
# 4 thread(s)    1.600000   0.010000   1.610000 (  0.496373)
# 5 thread(s)    1.540000   0.000000   1.540000 (  0.488317)
# 6 thread(s)    1.600000   0.010000   1.610000 (  0.533344)
# 7 thread(s)    1.760000   0.010000   1.770000 (  0.571953)
# 8 thread(s)    1.520000   0.000000   1.520000 (  0.465451)
# 9 thread(s)    1.730000   0.010000   1.740000 (  0.565107)
# 10 thread(s)   1.540000   0.020000   1.560000 (  0.500862)
