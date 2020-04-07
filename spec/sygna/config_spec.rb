require "spec_helper"

RSpec.describe Sygna::Config do
  describe ".configure" do
    before do
      described_class.instance = described_class.new
    end

    let(:settings) { YAML.load(File.read(File.join('spec', 'fixtures', "settings.yml"))) }

    it "makes Sygna configured" do
      expect(Sygna).not_to be_configured

      Sygna.configure do |config|
        config.private_key = settings["private_key"]
      end

      expect(Sygna).to be_configured
    end
  end
end