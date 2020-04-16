require "spec_helper"

RSpec.describe Sygna::PrivateInfo do
  before(:all) do
    @setting = YAML.load(File.read(File.join('spec', 'fixtures', "settings.yml")))

    Sygna.configure do |config|
      config.private_key = @setting["private_key"]
    end
  end

  it "encode and decode sensitive data" do
    hash_data = { "name" => "Nic" }
    public_key_hex = OpenSSL::PKey::EC.new(@setting["public_key"]).public_key.to_bn.to_s(16)

    encoded_private_info = described_class.encode(hash_data, public_key_hex)
    decoded_private_info = described_class.decode(encoded_private_info)

    expect(encoded_private_info).to be_kind_of(String)
    expect(JSON.parse(decoded_private_info)).to eq(hash_data)
  end
end