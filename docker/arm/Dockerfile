FROM hypriot/rpi-ruby:2.2.2
MAINTAINER theOpenBit <tob at schoenesnetz.de>

RUN apk update && apk add curl 
RUN curl -O https://storage.googleapis.com/kubernetes-release/release/v1.5.2/bin/linux/amd64/kubectl
RUN chmod +x kubectl && chmod +x kubectl

COPY bin /k8sdeployer/bin
COPY lib /k8sdeployer/lib
COPY Rakefile k8sdeployer.gemspec LICENSE.md /k8sdeployer/
RUN ls /k8sdeployer
RUN cd /k8sdeployer && rake test
RUN cd /k8sdeployer && gem build k8sdeployer.gemspec
RUN cd /k8sdeployer && gem install -l k8sdeployer-$(cat /k8sdeployer/k8sdeployer.gemspec | grep version | sed  -r "s/s.version.*=.*'(.*)'/\1/" |sed -e "s/ //g").gem
RUN rm -rf /k8sdeployer
ENV PATH=$PATH:/

VOLUME k8swork
WORKDIR k8swork
ENTRYPOINT ["k8sdeployer"]

