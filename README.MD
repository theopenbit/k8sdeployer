# Introduction
This simple ruby script is used for deploying k8s types in different namespaces.
For each namespace it is possible to declare a specific config file containing 
the values used in the namespace.

Normally helm (https://github.com/kubernetes/helm) is used for it in a more professional way.
But if you do not want to install helm on your cluster (may be if you are using a tiny pi) 
this scipt would be helpful

# Usage
Make sure ```kubectl``` is on your PATH and configured to point to your kubernetes cluster.
Maybe export your kubeconfig: ```export KUBECONFIG=<path to your kubeconfig>
```
cd test

#test file processing for namespace 'demo2' no deployment 
#all scripts are written in the subdirectory 'build'
../k8sdeployer.rb -n demo2 -t

#file processing and deployment to kubernetes for namespace 'demo2' 
../k8sdeployer.rb -n demo2 

```
The template files to be processes are placed in the subdirectory ```k8s```.
The order how the files are deployed, is configured in the file ```k8sdeployorder.yaml```.
All namespace specific values are placed in a file ```namespace-<nameOfNamespace>-config.yaml.erb```
Default values for all namespaces are placed in a file ``namespace-config.yaml.erb```
Both config files are optional

# Usage using the docker container
If you are using the docker image theopenbit/k8sdeployer, you have to map your files as volume into the container.
The kubeconfig directory have to mapped into the container same as its host path either. Take a look at the example and the usage will be clear:

```docker run -v <pathToYourWorkingDir>:/k8swork -v <hostPathOfKubeconfig>:<hostPathOfKubeconfig> -e KUBECONFIG=<hostPathOfKubeconfig>/kubeconfig.conf theopenbit/k8sdeployer -n <namespace>  -d /k8swork```
