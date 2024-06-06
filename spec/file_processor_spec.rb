require_relative '../file_processor'

RSpec.describe FileProcessor do
  let(:filepath) { 'spec/support/fixtures/sample.txt' }
  let(:file_processor) { FileProcessor.new(filepath) }

  describe '#initialize' do
    it 'sets the filepath' do
      expect(file_processor.filepath).to eq(filepath)
    end

    it 'builds the index' do
      expect(file_processor.index).to be_a(Hash)
      expect(file_processor.index.keys).to include(0, 1, 2, 3, 4)
    end
  end

  describe '#fetch_line' do
    context 'when the line number exists' do
      it 'returns the correct line' do
        expect(file_processor.fetch_line(0)).to eq('line 1')
        expect(file_processor.fetch_line(1)).to eq('line 2')
        expect(file_processor.fetch_line(2)).to eq('line 3')
      end
    end

    context 'when the line number does not exist' do
      it 'returns nil' do
        expect(file_processor.fetch_line(7)).to be_nil
        expect(file_processor.fetch_line(-1)).to be_nil
      end
    end
  end
end
