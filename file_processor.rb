require 'connection_pool'

class FileProcessor
  attr_reader :filepath, :index, :pool, :sparse_factor

  def initialize(filepath)
    @filepath = filepath
    @index = {}
    @sparse_factor = calculate_sparse_factor
    @pool = ConnectionPool.new(size: 5, timeout: 5) { File.open(filepath, 'r') }
    build_index
  end

  def fetch_line(line_number)
    closest_line_number = (line_number / sparse_factor) * sparse_factor
    offset = index[closest_line_number]
    return nil unless offset

    pool.with do |file|
      file.seek(offset)
      current_line_number = closest_line_number
      while current_line_number <= line_number
        line = file.readline.chomp
        return line if current_line_number == line_number

        current_line_number += 1
      end
    end
  rescue EOFError
    nil
  end

  private

  def calculate_sparse_factor
    file_size_in_bytes = File.size(filepath)

    # 1 index entry per MB
    sparse_factor = (file_size_in_bytes / (1024 * 1024)).to_i
    [sparse_factor, 1].max
  end

  def build_index
    offset = 0
    pool.with do |file|
      file.each_line.with_index do |line, line_number|
        index[line_number] = offset if (line_number % sparse_factor).zero?
        offset += line.bytesize
      end
    end
  end
end
