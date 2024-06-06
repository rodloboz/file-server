require 'sinatra/base'

require_relative 'file_processor'

class LineServer < Sinatra::Base
  configure do
    set :filepath, ENV['FILE_TO_SERVE']
    set :processor, nil

    before do
      settings.processor ||= FileProcessor.new(settings.filepath)
    end
  end

  get '/lines/:line_number' do
    line_number = params[:line_number].to_i
    line_content = settings.processor.fetch_line(line_number)

    if line_content
      status 200
      body line_content
    else
      status 413
      body "Line number #{line_number} is out of range"
    end
  end
end
