Gem::Specification.new do |s|
  s.name        = 'k8sdeployer'
  s.version     = '0.0.1.pre'
  s.date        = Date.today.to_s
  s.summary     = 'k8sdeployer'
  s.description = 'A simple gem to deploy templated k8s configs'
  s.authors     = ['theOpenBit']
  s.email       = 'tob@schoenesnetz.de'
  s.files       = ['lib/k8sdeployer.rb', 'LICENSE.md']
  s.homepage    =
    'https://github.com/theopenbit/k8sdeployer'
  s.license     = 'GPL-3.0'
  s.executable  = 'k8sdeployer'
end
