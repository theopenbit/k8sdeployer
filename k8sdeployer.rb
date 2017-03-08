#!/usr/bin/ruby
#
# deploy into k8s based on templating
# no need for helm in your k8s cluster
# you only need to declare your yaml-files 
# in the directory k8s and define a config file
# for each namespace you want to deploy the
# file into. The order used during deploying is
# defined in the file k8sdeployorder.yml
# 
# kubectl must be in PATH
# The enviroment variable KUBECONFIG must be set
#
# author theOpenBit <tob at schoenesnetz.de>
# license gpl v3 https://www.gnu.org/licenses/gpl.txt
#
#
require 'yaml' 
require 'optparse'
require 'erb'
require 'open3'
def execCmd(cmd)
    Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
       while line = stderr.gets
         puts line
       end
       
       while line = stdout.gets
         puts line
       end
        
       exit_status = wait_thr.value
       unless exit_status.success?
         puts stderr  
         abort "FAILED !!! #{cmd}"
       end
    end
end
options = {}
optparse = OptionParser.new do |opts|
  opts.banner = "Usage: k8sdeployer.rb [options]"

  opts.on("-n", "--namespace name",String,"the namespace where to deploy into") do |n|
    options[:namespace] = n
  end
  
  opts.on("-t", "--test","process files without deployment") do |t|
    options[:test] = t
  end

end

begin
   optparse.parse!
   mandatory = [:namespace]
   missing = mandatory.select{ |param| options[param].nil? }
   raise OptionParser::MissingArgument, missing.join(', ') unless missing.empty?
rescue OptionParser::ParseError => e
   puts e
   puts optparse
   exit 1
end
namespace = options[:namespace]
k8sdeployorder = YAML.load_file("k8sdeployorder.yaml")
puts "process files..."
if Dir.exist?( "build" ) then
    Dir.glob("build/*") {|file| File.delete(file) }
    Dir.delete("build")
end
Dir.mkdir("build")
if File.exist?("namespace-#{namespace}-config.yaml.erb") then
    renderer = ERB.new(File.read("namespace-#{namespace}-config.yaml.erb"))
    namespaceconfig = YAML.load(renderer.result())
    File.write("build/namespace-#{namespace}-config.yaml",YAML.dump(namespaceconfig))
else
    puts "No namespace specific config file! processing without it..."
    namespaceconfig = Hash.new   
end

renderer = ERB.new(File.read("namespace.yaml.erb"))
File.write("build/namespace.yaml",renderer.result())

k8sdeployorder.each do |item|
   renderer = ERB.new(File.read("k8s/#{item}"))
   itemcontent = renderer.result()
   File.write("build/#{item[/(.*)\.erb/,1]}", itemcontent)
end
if options[:test] then
    #test only no deployment
    exit 
end
# deploy to kubernetes
puts "deploying namespace ..."
execCmd("kubectl apply -f build/namespace.yaml")
k8sdeployorder.each do |item|
   puts "deploying build/#{item[/(.*)\.erb/,1]}..." 
   execCmd("kubectl apply -f build/#{item[/(.*)\.erb/,1]}")
end


