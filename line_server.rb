require 'sinatra/base'

require_relative 'file_processor'

class LineServer < Sinatra::Base
  configure do
    set :filepath, ENV['FILE_TO_SERVE']
    set :processor, FileProcessor.new(settings.filepath)

    at_exit do
      settings.processor.shutdown
    end
  end

  get '/lines/:line_number' do
    line_number_param = params[:line_number]
    if line_number_param !~ /^\d+$/ || line_number_param.to_i <= 0
      status 400
      return body "Invalid line number: #{line_number_param}"
    end

    line_number = line_number_param.to_i
    line_content = settings.processor.fetch_line(line_number - 1)

    if line_content
      status 200
      body line_content
    else
      status 413
      body "Line number #{line_number} is out of range"
    end
  end
end
