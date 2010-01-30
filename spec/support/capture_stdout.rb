require 'stringio'

module Kernel
  def capture_stdout(&block)
    org_stdout, $stdout = $stdout, StringIO.new
    yield
    return $stdout.string
  ensure
    $stdout = org_stdout
  end

  def capture_stderr(&block)
    org_stderr, $stderr = $stderr, StringIO.new
    yield
    return $stderr.string
  ensure
    $stderr = org_stderr
  end

  def capture_stdio(&block)
    stderr, stdout = "", ""
    stderr = capture_stderr do
      stdout = capture_stdout(&block)
    end
    return [stdout, stderr]
  end
end