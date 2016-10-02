require 'spec_helper'

RSpec.describe Enumerator::Lazy do
  describe '#scan' do
    context 'when calculating summation of 0 thorugh 9' do
      subject { [*0..9].lazy.scan(0, :+).to_a }

      it { is_expected.to eq [0, 0, 1, 3, 6, 10, 15, 21, 28, 36, 45] }
    end
  end
end
