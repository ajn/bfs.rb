require 'spec_helper'

RSpec.describe BFS::TempWriter do
  let(:closer) { proc {} }
  subject { described_class.new 'test', &closer }

  it 'should behave like a File' do
    missing = ::File.public_instance_methods - subject.public_methods
    expect(missing).to be_empty
  end

  it 'should support custom params' do
    subject = described_class.new 'test', perm: 0o640, &closer
    expect(subject.stat.mode).to eq(0o100640)
    expect(subject.close).to be_truthy
  end

  it 'should exectute a closer block' do
    expect(closer).to receive(:call).with(subject.path)
    expect(subject.close).to be_truthy
  end
end
