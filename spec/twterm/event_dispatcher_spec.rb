require 'spec_helper'

RSpec.describe Twterm::EventDispatcher do
  let(:event_dispatcher) { described_class.instance }

  describe '#dispatch' do
    subject { event_dispatcher.dispatch(event) }

    let(:event) { Twterm::Event::Base.new }

    it { is_expected.to eq event_dispatcher }
  end

  describe '.instance' do
    subject { described_class.instance }

    it { is_expected.to be_kind_of described_class }
  end
end
