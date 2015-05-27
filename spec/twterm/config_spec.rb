describe Twterm::Config do
  MOCK_CONFIG_PATH = 'spec/resources/config'.freeze

  let(:config) { described_class.new }

  describe '#[]' do
    it 'returns config value from config_file_path' do
      allow(config).to receive(:config_file_path).and_return(MOCK_CONFIG_PATH)

      expect(config[:access_token]).to eq 'token'
    end
  end

  describe '#[]=' do
    context 'when fail to load config file' do
      it 'set new value to config file' do
        allow(config).to receive(:config_file_path).and_return('invalid path')
        allow(config).to receive(:save_config_to_file).and_return(nil)

        expect(config[:access_token]).to be_nil
        config[:access_token] = 'new_token'
        expect(config[:access_token]).to eq 'new_token'
      end
    end

    it 'can set some value' do
      allow(config).to receive(:config_file_path).and_return(MOCK_CONFIG_PATH)
      allow(config).to receive(:save_config_to_file).and_return(nil)

      config[:access_token] = 'new_token'
      expect(config[:access_token]).to eq 'new_token'
    end
  end
end
