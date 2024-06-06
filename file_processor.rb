class FileProcessor
  attr_reader :filepath, :index

  def initialize(filepath)
    @filepath = filepath
    @index = {}
    build_index
  end

  def fetch_line(line_number)
    offset = index[line_number]
    return nil unless offset

    File.open(filepath, 'r') do |file|
      file.seek(offset)
      return file.readline.chomp
    end
  rescue EOFError
    nil
  end

  private

  def build_index
    offset = 0
    File.open(filepath, 'r') do |file|
      file.each_line.with_index do |line, line_number|
        index[line_number] = offset
        offset += line.bytesize
      end
    end
  end
end
