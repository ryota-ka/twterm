require 'twterm/image_builder/user_name_image_builder'

RSpec.describe Twterm::ImageBuilder::UserNameImageBuilder do

  describe '#build' do
    let(:json) {
      json = JSON.parse(fixture('user.json'), symbolize_names: true)

      json[:screen_name] = screen_name
      json[:name] = name

      json
    }
    let(:user) { Twterm::User.new(Twitter::User.new(json)) }
    let(:builder) { described_class.new(user) }
    let(:image) { builder.build }
    let(:screen_name) { 'alice42' }
    let(:name) { 'Alice' }

    it "builds an image containing user's screen name" do
      expect(image.to_s).to include screen_name
    end

    it "builds an image containing user's name" do
      expect(image.to_s).to include name
    end
  end
end
