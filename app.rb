require 'elasticsearch'

HOST = URI.parse(ENV.fetch('HOST'))
PORT = ENV.fetch('PORT', HOST.scheme == 'https' ? 443 : 80)
client = Elasticsearch::Client.new(host: HOST, port: PORT, log: true)

dir = './../fluentd-benchmark-v1/data/**/*.json'
require 'json'

timestamp = Time.now.to_datetime.rfc3339

Dir.glob(dir).each do |f|
  pn = Pathname.new(f)
  File.open(f) do |fs|
    d = JSON.parse(fs.read).merge(
      'name' => pn.basename.to_s.gsub('.json', ''),
      'timestamp' => timestamp
    )
    client.create(index: 'fluentd_stats', type: 'benchmark', body: d)
  end
end
