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
require 'erb'
require 'open3'
class K8sdeployer 
    
    
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
    
    def processFiles(directory,namespace,test)
       
        puts "process files in #{directory}..."
        k8sdeployorder = YAML.load_file("#{directory}/k8sdeployorder.yaml")
        if Dir.exist?( "#{directory}/build" ) then
            Dir.glob("#{directory}/build/*") {|file| File.delete(file) }
            Dir.delete("#{directory}/build")
        end
        Dir.mkdir("#{directory}/build")
        if File.exist?("#{directory}/namespace-config.yaml.erb") then
            renderer = ERB.new(File.read("#{directory}/namespace-config.yaml.erb"))
            namespaceconfig = YAML.load(renderer.result(binding()))
            File.write("#{directory}/build/namespace-#{namespace}-config.yaml",YAML.dump(namespaceconfig))
        else
            puts "No global namespace config file! processing without it..."
            namespaceconfig = Hash.new   
        end
 
        if File.exist?("#{directory}/namespace-#{namespace}-config.yaml.erb") then
            renderer = ERB.new(File.read("#{directory}/namespace-#{namespace}-config.yaml.erb"))
            namespaceconfigspecific= YAML.load(renderer.result(binding()))
            namespaceconfig.merge(namespaceconfigspecific)
            File.write("#{directory}/build/namespace-#{namespace}-config.yaml",YAML.dump(namespaceconfig))
        else
            puts "No namespace specific config file! processing without it..."               
        end
        namespaceErb= "apiVersion: v1\nkind: Namespace\nmetadata:\n  name: <%= namespace %>"
        renderer = ERB.new(namespaceErb)        
        File.write("#{directory}/build/namespace.yaml",renderer.result(binding()))
        
        k8sdeployorder.each do |item|
            renderer = ERB.new(File.read("#{directory}/k8s/#{item}"))
            itemcontent = renderer.result(binding())
            File.write("#{directory}/build/#{item[/(.*)\.erb/,1]}", itemcontent)
        end
        if test then
            #test only no deployment
            return 
        end
        
        # deploy to kubernetes
        puts "deploying namespace ..."
        execCmd("kubectl apply -f #{directory}/build/namespace.yaml")
        k8sdeployorder.each do |item|
            puts "deploying #{directory}/build/#{item[/(.*)\.erb/,1]}..." 
            execCmd("kubectl apply -f #{directory}/build/#{item[/(.*)\.erb/,1]}")
        end
    end
end
