require 'benchmark'

def count_file_lines_size(file)
  File.open(file + "_with_count", "a") do |with_count|
    File.open(file, "r").each_line do |line| 
      with_count.write("#{line.chomp} - #{line.size}\n")
    end
  end
end

def count_files_ls(files)
  files.each do |file|
    count_file_lines_size(file)
  end
end

def create_random_file(file_name, lines_amount)
  lines_amount.times do
    string = (1..rand(100)).map { ('a'..'z').to_a.sample }.join
    File.open(file_name, "a") {|f| f.write("#{string}\n") }
  end
end

def create_files(n, lines_amount)
  files = []
  
  n.times do |i|
    file_name = "file_#{i+1}"
    files << file_name
    create_random_file(file_name, lines_amount)
  end

  files
end

def main
  files = create_files(1_000, 100)

  Benchmark.bmbm do |x|
    (1..10).each do |threads_amount|
      x.report("#{threads_amount} thread(s)") { job_with_n_threads(files, threads_amount) }
    end
  end
end

def job_with_n_threads(files, threads_amount)
  batches = get_batches(files, threads_amount)
  result = []
  threads = []

  threads_amount.times do |i|
    threads << Thread.new do
      result += count_files_ls(batches[i])
    end
  end
  threads.each { |thr| thr.join }

  result
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

# MRI

    # Rehearsal ------------------------------------------------
    # 1 thread(s)    0.252474   0.060226   0.312700 (  0.323633)
    # 2 thread(s)    0.238244   0.075965   0.314209 (  0.317228)
    # 3 thread(s)    0.265053   0.059595   0.324648 (  0.323655)
    # 4 thread(s)    0.276723   0.067194   0.343917 (  0.348487)
    # 5 thread(s)    0.264352   0.082745   0.347097 (  0.349833)
    # 6 thread(s)    0.280085   0.058824   0.338909 (  0.349283)
    # 7 thread(s)    0.275327   0.048878   0.324205 (  0.321108)
    # 8 thread(s)    0.260595   0.064227   0.324822 (  0.323815)
    # 9 thread(s)    0.277095   0.058907   0.336002 (  0.333989)
    # 10 thread(s)   0.287088   0.044188   0.331276 (  0.335401)
    # --------------------------------------- total: 3.297785sec

    #                    user     system      total        real
    # 1 thread(s)    0.227262   0.047473   0.274735 (  0.278596)
    # 2 thread(s)    0.249039   0.072578   0.321617 (  0.305899)
    # 3 thread(s)    0.246992   0.071843   0.318835 (  0.313351)
    # 4 thread(s)    0.251777   0.063808   0.315585 (  0.317725)
    # 5 thread(s)    0.295731   0.032650   0.328381 (  0.337154)
    # 6 thread(s)    0.272388   0.055646   0.328034 (  0.327736)
    # 7 thread(s)    0.261581   0.057053   0.318634 (  0.322315)
    # 8 thread(s)    0.284332   0.035285   0.319617 (  0.324085)
    # 9 thread(s)    0.260824   0.055939   0.316763 (  0.324427)
    # 10 thread(s)   0.269459   0.067248   0.336707 (  0.338060)


# JRuby

# Rehearsal ------------------------------------------------
# 1 thread(s)    1.210000   0.100000   1.310000 (  0.648400)
# 2 thread(s)    0.280000   0.050000   0.330000 (  0.205334)
# 3 thread(s)    0.270000   0.050000   0.320000 (  0.226542)
# 4 thread(s)    0.980000   0.100000   1.080000 (  0.536158)
# 5 thread(s)    0.160000   0.090000   0.250000 (  0.156428)
# 6 thread(s)    0.170000   0.070000   0.240000 (  0.139091)
# 7 thread(s)    0.240000   0.040000   0.280000 (  0.158707)
# 8 thread(s)    0.420000   0.070000   0.490000 (  0.321078)
# 9 thread(s)    0.240000   0.030000   0.270000 (  0.166199)
# 10 thread(s)   0.260000   0.050000   0.310000 (  0.198403)
# --------------------------------------- total: 4.880000sec

#                    user     system      total        real
# 1 thread(s)    0.120000   0.050000   0.170000 (  0.178757)
# 2 thread(s)    0.180000   0.030000   0.210000 (  0.133105)
# 3 thread(s)    0.180000   0.050000   0.230000 (  0.164376)
# 4 thread(s)    0.530000   0.110000   0.640000 (  0.354050)
# 5 thread(s)    0.150000   0.060000   0.210000 (  0.112375)
# 6 thread(s)    0.180000   0.050000   0.230000 (  0.123553)
# 7 thread(s)    0.170000   0.030000   0.200000 (  0.113725)
# 8 thread(s)    0.280000   0.050000   0.330000 (  0.205001)
# 9 thread(s)    0.160000   0.030000   0.190000 (  0.110059)
# 10 thread(s)   0.170000   0.060000   0.230000 (  0.115279)
