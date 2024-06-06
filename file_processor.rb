require 'connection_pool'

class FileProcessor
  attr_reader :filepath, :index, :pool

  def initialize(filepath)
    @filepath = filepath
    @index = {}
    @pool = ConnectionPool.new(size: 5, timeout: 5) { File.open(filepath, 'r') }
    build_index
  end

  def fetch_line(line_number)
    offset = index[line_number]
    return nil unless offset

    pool.with do |file|
      file.seek(offset)
      return file.readline.chomp
    end
  rescue EOFError
    nil
  end

  private

  def build_index
    offset = 0
    pool.with do |file|
      file.each_line.with_index do |line, line_number|
        index[line_number] = offset
        offset += line.bytesize
      end
    end
  end
end
