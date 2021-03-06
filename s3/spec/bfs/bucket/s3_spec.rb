require 'spec_helper'

sandbox  = { bucket: 'bsm-bfs-unittest' }.freeze
run_spec = \
  begin
    s = Aws::S3::Client.new
    s.head_bucket(bucket: sandbox[:bucket])
    true
  rescue StandardError
    false
  end

RSpec.describe BFS::Bucket::S3, if: run_spec do
  let(:prefix) { "x/#{SecureRandom.uuid}/" }

  subject do
    described_class.new sandbox[:bucket], prefix: prefix
  end
  after :all do
    bucket = described_class.new sandbox[:bucket], prefix: 'x/'
    bucket.ls.each {|name| bucket.rm(name) }
  end

  it_behaves_like 'a bucket'

  it 'should resolve from URL' do
    bucket = BFS.resolve("s3://#{sandbox[:bucket]}?acl=private")
    expect(bucket).to be_instance_of(described_class)
    expect(bucket.name).to eq(sandbox[:bucket])
    expect(bucket.acl).to eq(:private)
  end

  it 'should enumerate over a large number of files' do
    bucket = described_class.new sandbox[:bucket], prefix: 'm/'
    expect(bucket.ls('**/*').count).to eq(2121)
  end
end
