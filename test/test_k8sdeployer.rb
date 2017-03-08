require 'minitest/autorun'
require 'k8sdeployer'

class K8sdeployerTest < Minitest::Test
  def test_processFiles
     K8sdeployer.new.processFiles('test','demo2',true)
     assert(File.exist?('test/build/namespace-demo2-config.yaml'), 'test/build/namespace-demo-config.yaml does not exist')
     assert(File.exist?('test/build/deployment.yaml'), 'test/build/deployment.yaml does not exist')
     assert(File.exist?('test/build/service.yaml'), 'test/build/service.yaml does not exist')
     assert(File.exist?('test/build/namespace.yaml'), 'test/build/namespace.yaml does not exist')
  end
  
  def test_processFiles_without_config
     K8sdeployer.new.processFiles('test','demo',true)
     assert(File.exist?('test/build/deployment.yaml'), 'test/build/deployment.yaml does not exist')
     assert(File.exist?('test/build/service.yaml'), 'test/build/service.yaml does not exist')
     assert(File.exist?('test/build/namespace.yaml'), 'test/build/namespace.yaml does not exist')
  end

end

