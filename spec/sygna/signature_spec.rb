require "spec_helper"

RSpec.describe Sygna::Signature do
  before(:all) do
    @setting = YAML.load(File.read(File.join('spec', 'fixtures', "settings.yml")))

    Sygna.configure do |config|
      config.private_key = @setting["private_key"]
    end
  end

  it "sign and verify object" do
    object = { "key" => "value" }
    public_key_hex = OpenSSL::PKey::EC.new(@setting["public_key"]).public_key.to_bn.to_s(16)

    signature = described_class.sign(object)
    is_verified = described_class.verify(object, signature, public_key_hex)

    expect(signature).to be_kind_of(String)
    expect(signature.size).to eq(128)
    expect(is_verified).to be_truthy
  end
end