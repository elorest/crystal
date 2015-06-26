require "./**"
# The Benchmark module provides methods for benchmarking Crystal code, giving
# detailed reports on the time taken for each task.
#
# ### Measure the time to construct the string given by the expression: `"a"*1_000_000_000`
#
# ```
# require "benchmark"
#
# puts Benchmark.measure { "a"*1_000_000_000 }
# ```
#
# This generates the following output:
#
# ```text
#  0.190000   0.220000   0.410000 (  0.420185)
# ```
#
# This report shows the user CPU time, system CPU time, the sum of
# the user and system CPU times, and the elapsed real time. The unit
# of time is seconds.
#
# ### Do some experiments sequentially using the `#bm` method:
#
# ```
# require "benchmark"
#
# n = 5000000
# Benchmark.bm do |x|
#  x.report("times:") { n.times do ; a = "1"; end }
#  x.report("upto:") { 1.upto(n) do ; a = "1"; end }
# end
# ```
#
# The result:
#
# ```text
#            user     system      total        real
# times:   0.010000   0.000000   0.010000 (  0.008976)
# upto:    0.010000   0.000000   0.010000 (  0.010466)
# ```
#
# Make sure to always benchmark code by compiling with the `--release` flag.
module Benchmark
  extend self

  # Main interface of the `Benchmark` module. Yields a `Job` to which
  # one can report the benchmarks. See the module's description.
  def bm
    report = BM::Job.new
    yield report
    report.execute
    report
  end

  def ips(calculation = 5, warmup = 2)
    job = Ips::Job.new(calculation, warmup)
    yield job
    job.execute
    job.report
    job
  end

  # Returns the time used to execute the given block.
  def measure(label = "") : BM::Tms
    t0, r0 = Process.times, Time.now
    yield
    t1, r1 = Process.times, Time.now
    BM::Tms.new(t1.utime  - t0.utime,
                     t1.stime  - t0.stime,
                     t1.cutime - t0.cutime,
                     t1.cstime - t0.cstime,
                     (r1.ticks - r0.ticks).to_f / TimeSpan::TicksPerSecond,
                     label)
  end

  # Returns the elapsed real time used to execute the given block.
  #
  # ```
  # Benchmark.realtime { "a" * 100_000 } #=> 00:00:00.0005840
  # ```
  def realtime : TimeSpan
    r0 = Time.now
    yield
    Time.now - r0
  end
end
