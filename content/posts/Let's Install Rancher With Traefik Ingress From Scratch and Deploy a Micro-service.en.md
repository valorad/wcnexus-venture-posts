---
title: "Let's Install Rancher With Traefik Ingress From Scratch and Deploy a Micro-service"
date: 2021-04-23T19:24:01-06:00
draft: false
featured_image : "https://i.imgur.com/wqlpDhI.png"
tags: ["docker", "kubernetes", "rancher", "traefik", "micro-service"]
---


# Let's Install Rancher With Traefik Ingress From Scratch and Deploy a Micro-service
![Cover](https://i.imgur.com/wqlpDhI.png)

This note will describe how to install Rancher with Traefik ingress on a single-node Kubernetes Cluster, on an Arch Linux VM, on our local environment.

Quick terminologies:

[Rancher][WhyRancher]: A Kubernetes orchestration platform. With Rancher, you can manage multiple Kubernetes clusters easily. There are also tons of well-made applications on the platform ready to deploy at once.

[Traefik Proxy][TraefikWelcome]: A smart edge router that automatically configures reverse proxy to the services in your containers. Traefik supports normal Docker containers or complex platforms like Kubernetes.

I will also try to provide installation command lines for other Linux distributions as possible.

It is known that systemd-less system DOES NOT WORK (e.g. Artix, Void)

## Chapter 0: Preparation

At least one computer (bare-metal / VM). We assume a single node scenario here (no high availability).

1. Please check [Hardware Requirements][RancherHardwareRequirements] before proceeding.

2. (optional) Archlinux and friends can install `yay`, for easier download from AUR.

``` bash

git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -is

```

3. Install and configure OpenSSH

To install, run:

``` bash

# ==> Archlinux, Manjaro and friends
sudo pacman -S openssh

# ==> Debian, Ubuntu and friends
sudo apt install openssh-server

```

Edit `/etc/ssh/sshd_config` and set:

``` conf

AllowTcpForwarding yes

```

4. Switch to your normal Linux user and generate an openssh private key.

``` bash

ssh-keygen -t ed25519
cat ~/.ssh/id_ed25519.pub > ~/.ssh/authorized_keys
chmod 700 ~/.ssh
chmod 400 ~/.ssh/authorized_keys
chmod 400 ~/.ssh/id_ed25519

```

5. Try to test your connection. Troubleshooting section of [Archlinux SSH_keys][archlinuxSSH_keys] wiki page has more details.

6. Install `snapd`, so it would be easier to install `kubectl` and `helm` in chapter 2.

``` bash

# ==> Archlinux, Manjaro and friends
yay -S snapd

sudo systemctl enable --now snapd.socket

# enable classic snap support
sudo ln -s /var/lib/snapd/snap /snap

# It is suggested to reboot your PC

# =================================================

# ==> Debian, Ubuntu and friends
sudo apt install snapd

# It is suggested to reboot your PC

```

## Chapter 1: Docker

Docker (to be specific: `containerd` that shipped with Docker) is the heart of Kubernetes that cannot live without, so we have to make sure Docker is properly installed.

In chapter 2, we will use Rancher Kubernetes Engine (RKE) to help us spin up Kubernetes, so please be sure to install a supported docker version.

Please confirm the supported docker versions on the [RKE Requirements][RKEDockerReq] page.

``` bash

# ==> Archlinux, Manjaro and friends
sudo pacman -S docker

# (OR) you can search the old version docker on Archlinux Archive: https://archive.archlinux.org/
# sudo pacman -U https://archive.archlinux.org/packages/d/docker/docker-1%3A18.09.2-1-x86_64.pkg.tar.xz

# add yourself to the docker group
sudo usermod -aG docker [LinuxUserName]

# (remember to log out and log back in)

# enable and start docker
sudo systemctl enable docker

sudo systemctl start docker

# =================================================

# ==> Debian, Ubuntu and friends:
# Please follow the official installation guide:
# https://docs.docker.com/engine/install/debian/
# https://docs.docker.com/engine/install/ubuntu/
# The following command lines are extracted from Debian guide

sudo apt install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update

sudo apt install docker-ce docker-ce-cli containerd.io

```

run `docker version` to do a final check

    Client:
    Version:           20.10.6
    API version:       1.41
    Go version:        go1.16.3
    Git commit:        370c28948e
    Built:             Mon Apr 12 14:10:41 2021
    OS/Arch:           linux/amd64
    Context:           default
    Experimental:      true

    Server:
    Engine:
    Version:          20.10.6
    API version:      1.41 (minimum version 1.12)
    Go version:       go1.16.3
    Git commit:       8728dd246c
    Built:            Mon Apr 12 14:10:25 2021
    OS/Arch:          linux/amd64
    Experimental:     false
    containerd:
    Version:          v1.4.4
    GitCommit:        05f951a3781f4f2c1911b05e61c160e9c30eaa8e.m
    runc:
    Version:          1.0.0-rc93
    GitCommit:        12644e614e25b05da6fd08a38ffa0cfe1903fdec
    docker-init:
    Version:          0.19.0
    GitCommit:        de40ad0

## Chapter 2: Kubernetes

Rancher Kubernetes Engine can be installed "on almost any Linux OS with Docker installed" (with personal doubt), so we will use it to spin up Kubernetes easily and fastly.

1. Download the RKE binary file from [Github][RKEGithubInstall], remember to add it to $PATH.

Or install RKE from the OS package manager.

``` bash
# ==> Archlinux, Manjaro and friends
yay -S rke-bin
```

2. Create a folder to contain the RKE config file and later cluster secrets and connection information.

3. Create a config file `rke.config.yaml` in that folder.

Here is the config file that I use for single node scenario:

``` yaml

nodes:
  - address: vm-loto-arch-nexus-0 # change it to your computer host name
    user: valorad
    ssh_key_path: /home/valorad/.ssh/id_ed25519 # point to your ssh private key.
    role:
      - controlplane
      - etcd
      - worker

```

Check [Rancher Documentation][RKEConfigOptions] for more configuration options.

4. Spin up RKE

``` bash
rke up --config rke.config.yaml
```

Successful result:

    INFO[0000] Running RKE version: v1.2.7
    INFO[0000] Initiating Kubernetes cluster
    INFO[0000] [dialer] Setup tunnel for host [vm-loto-arch-nexus-0]
    INFO[0000] Checking if container [cluster-state-deployer] is running on host [vm-loto-arch-nexus-0], try #1
    INFO[0000] Pulling image [rancher/rke-tools:v0.1.72] on host [vm-loto-arch-nexus-0], try #1
    ......
    INFO[0208] [addons] Metrics Server deployed successfully
    INFO[0208] [ingress] Setting up nginx ingress controller
    INFO[0208] [addons] Saving ConfigMap for addon rke-ingress-controller to Kubernetes
    INFO[0208] [addons] Successfully saved ConfigMap for addon rke-ingress-controller to Kubernetes
    INFO[0208] [addons] Executing deploy job rke-ingress-controller
    INFO[0218] [ingress] ingress controller nginx deployed successfully
    INFO[0218] [addons] Setting up user addons
    INFO[0218] [addons] no user addons defined
    INFO[0218] Finished building Kubernetes cluster successfully

The file `kube_config_rke.config.yaml` is generated after a successful deployment of RKE. It contains the information we need to connect to the Kubernetes cluster.

5. Install and configure `kubectl`.

``` bash
sudo snap install kubectl --classic
```

Set the KUBECONFIG environment variable

``` bash
# bash, sh
export KUBECONFIG=/path/to/kube_config_rke.config.yaml # (to save permanently, add this line to ~/.bash_rc or /etc/environment)

# fish shell
set -Ux KUBECONFIG /path/to/kube_config_rke.config.yaml

```

Try running `kubectl get nodes`. A successful result will look like this:

    NAME                   STATUS   ROLES                      AGE   VERSION
    vm-loto-arch-nexus-0   Ready    controlplane,etcd,worker   15m   v1.20.5


6. Install `helm`, which is a Rancher installation prerequisite in Chapter 3.

``` bash
sudo snap install helm --classic
helm repo add stable https://charts.helm.sh/stable
```

## Chapter 3: Rancher

Rancher can be deployed via docker or installed on an existing Kubernetes cluster.

Here we will deploy the rancher on the Kubernetes cluster, with a self-signed certificate.

1. Install cert-manager

``` bash

# Create the namespace for cert-manager. The name MUST be exactly "cert-manager"
kubectl create namespace cert-manager

# Add the Jetstack Helm repository
helm repo add jetstack https://charts.jetstack.io
helm repo update

# install cert-manager CRDs (Custom Resource Definitions) as part of the Helm release
helm install \
    cert-manager jetstack/cert-manager \
    --namespace cert-manager \
    --create-namespace \
    --version v1.3.1 \
    --set installCRDs=true
    # change version if necessary

```

Try running  `kubectl get pods --namespace cert-manager`

A successful result will look like:

    NAME                                       READY   STATUS    RESTARTS   AGE
    cert-manager-7998c69865-zmvl6              1/1     Running   0          23s
    cert-manager-cainjector-7b744d56fb-5b2cg   1/1     Running   0          23s
    cert-manager-webhook-7d6d4c78bc-xgvz5      1/1     Running   0          23s

2. Install rancher latest

``` bash

# Create a Namespace for Rancher. The name MUST be exactly "cattle-system"
kubectl create namespace cattle-system

# Add the Rancher Helm Chart Latest Repository
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
helm repo update

# Install Rancher with Helm and Rancher-generated Certificates
helm install rancher rancher-latest/rancher \
    --namespace cattle-system \
    --set hostname=vm-loto-arch-nexus-0 # change this to your hostname

```
Wait for a couple of seconds (Could be long depending on your machine, mine was like 1 min.)

Then run `kubectl -n cattle-system get deploy rancher`

A successful result will look like this:

    NAME      READY   UP-TO-DATE   AVAILABLE   AGE
    rancher   3/3     3            3           104s

Now visit your host machine in the browser (e.g. https://vm-loto-arch-nexus-0/)

If the browser warns you about the invalid certificate, it's okay to proceed, since Rancher is using a self-signed certificate.

When you see this page, then congratulations! Rancher has now been successfully deployed.

![RancherSetInitialPassword](https://i.imgur.com/f7jflqn.png)

Set a password for your admin.

Choose "I'm only going to use the cluster Rancher was installed on", proceed to the main page, and have fun!

![RancherClusterExplorer](https://i.imgur.com/ilGtluB.png)

## Chapter 4: Traefik Ingress

(Chapter 4 was heavily inspired by [this awesome video][RancherTraefikVideo] by Techno Tim. Kudos to him!)

Remember your first day of Kubernetes? You probably tried to deploy several pods, and link them to a service. The service was running in NodePort mode, so you used `kube-proxy` to map the service port to your local machine, then you could access your micro-services. 

But with ingress installed, Kubernetes can then communicate with the outside world directly without using `kube-proxy`, so we can reach our micro-services deployed on the cluster more easily.

There are several ingresses we can choose from, like Nginx ingress, or in this chapter, [Traefik][TraefikWelcome] ingress.

1. Install MetalLB

Traefik ingress requires connection to an external load balancer. This is typically designed for cloud providers like AWS or GKE, which support load balancing out of the box. However, if you try to deploy a "LoadBalancer" type service in your local environment, you will see services hang forever.

[MetalLB][MetalLBConcepts] is an implementation of network load-balancers for bare metal clusters, which will help create subnet IP for your services, so "LoadBalancer" type service will no longer be stuck in the pending state, and therefore Traefik ingress will function normally.

To install MetalLB, we do:

``` bash
# Create metallb-system namespace
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.6/manifests/namespace.yaml
# Deploy MetalLB
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.6/manifests/metallb.yaml
# Create a MetalLB secret
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
```

Create a MetalLB config file called `metallb.config.yaml`

``` yaml
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  # Be sure to change the 3rd subnet to make it different from your local devices in "addresses". e.g. One of your LAN device IP is 192.168.1.170, then you shouldn't use 192.168.1.201-192.168.1.250
  config: |
    address-pools:
      - name: default
        protocol: layer2
        addresses:
          - 192.168.77.201-192.168.77.250
```

Lastly, apply this config map.

``` bash
kubectl apply -f /path/to/metallb.config.yaml
```

Now Go to Rancher UI, switch to `Cluster Manager`, Go to `local` project -> `Default` project, then you should see `metallb-system` namespace in the list.

![MetalLBInRancherUI](https://i.imgur.com/5v8rgW9.png)

We will test if load balancing is working after installing Traefik ingress.

2. Install Traefik ingress

You normally would install Rancher Apps in `Default` project, but Traefik ingress is special and has to be installed in Rancher `System` project, `kube-system` namespace.

Proceed to App dashboard in System cluster

![ProceedToSystemAppDashboard](https://i.imgur.com/3bNWQH7.png)

Launch the "traefik" app under "library" section

![TraefikInRancherLibrary](https://i.imgur.com/bSpcyWh.png)

**(Very important!)** Under "Namespace" section click "Use an existing namespace", then select "kube-system".

![TraefikClickUseAnExistingNamespace](https://i.imgur.com/84aCejm.png)

Keep `Service Type` as "L4 Balancer"

In this note, we won't bother with HTTPS, so we leave `SSL` to "False"

`Enable` the Traefik Dashboard and set a `Domain` you like.

![TraefikFillInForm](https://i.imgur.com/XbWWltt.png)

Hit launch when you are ready.

After launching Traefik, you will be redirected back to the Apps dashboard.

Don't worry if Traefik is red (not available) at first. Wait for a couple of seconds, you will see it turns green, which means deployment is successful.

![TraefikInAppDashboard](https://i.imgur.com/fEXGKRF.png)

Go to the Traefik details, you should see 2 endpoints with the IP falling into the range you configured at MetalLB config, and 1 endpoint with your domain name set up when launching the Traefik app. You should also see an active ingress rule.

![TraefikInAppDetails](https://i.imgur.com/wJ0OAk1.png)

To access the Traefik dashboard, head over to your router settings and map the domain you entered to the host IP.

![RouterTraefikDomain](https://i.imgur.com/vNgFeXg.png)

Now visit your domain, et voilà!

![TraefikDashboardInit](https://i.imgur.com/g8dsV9p.png)

## Chapter 5: Deploy a micro-service

In this chapter, I will explain how to deploy a micro-serivce on Rancher cluster, by deploying my personal website "wcnexus.com" for example.

The wcnexus.com image is special because it is hosted on the Github Packages repository, instead of Docker Hub. Plus, it is a private image that needs authentication to download.

![WCNexusGithubRegistry](https://i.imgur.com/dCeuxYa.png)

Therefore, we need to store the access token on Rancher before pulling it.

First, generate a personal access token on Github, with at least "read:packages" access

![GenerateTokenOnGithub](https://i.imgur.com/9NXZ0ZC.png)

Then go back to Rancher UI, go to `local` cluster -> `Default` project

![localClusterDefaultProject](https://i.imgur.com/AbSJzTY.png)

Select `Resource` -> `Secrets`

![ResourceThenSecrets](https://i.imgur.com/Q19FB0K.png)

Switch to `Registry Credentials` Tab then hit `Add Registry`

![RegistryCredentialsThenAddRegistry](https://i.imgur.com/gAvglAf.png)

Give a `Name`, then select `Custom` Address, enter "docker.pkg.github.com" as shown on the GitHub packages page.

Fill in your `Username` and the generated access token as `Password`.

Hit save.

(Note: you don't need to do `docker login` on your host, as Rancher won't read your docker credentials)

![RegistryFillInCredentials](https://i.imgur.com/ekLRaLj.png)

Now go to `Resource` -> `Workloads` and deploy a new workload

![ResourceThenWorkloads](https://i.imgur.com/PSbeseQ.png)

Specify the `Name`, `Docker Image` and use the default namespace. Then hit save.

![CreateANewWorkflow](https://i.imgur.com/XJwCqDA.png)

A successful deployment looks like this:

![WorkflowDetails](https://i.imgur.com/QGCu2PJ.png)

We have a service running, but we cannot access it yet. Thus, we now create an ingress.

Head to `Load Balancing` tab and add a new ingress

![LoadBalancingAddNewIngress](https://i.imgur.com/MLxwIIW.png)

Give this ingress a name, make sure to use the default namespace. 

Under `Rules` section, choose "Specify a hostname to use", and enter a domain name for your micro-service.

Point the `Target` to the workload you just created, and the port to the server running inside your docker container.

(wcnexus v3 is using node.js server (koa.js), the port is therefore 3000 as most koa.js servers do. That's why I specify the port as 3000)

![LoadBalancingFillInForm](https://i.imgur.com/UIYPdOQ.png)

Hit save.

Immediately, if you visit the Traefik dashboard, you will see a new backend and frontend have been created. This indicates that Traefik has been successfully linked to your service. If you increase the pod numbers in service deployment, you will see new entries under `Backends`, too.

![TraefikDashboardWithServiceIngressAdded](https://i.imgur.com/ppBFo7h.png)

Similarly to accessing the Traefik dashboard, you need to configure a new host entry in your router.

![RouterServiceDomain](https://i.imgur.com/k3jqOgX.png)

All done. Visit the service domain and we can see the website is up and running.

![WebsiteDeployedOnRancher](https://i.imgur.com/BXa57gS.png)

## Conclusions

Congratulations! Your micro-service is running on Rancher. This has not been an easy task, has it?

In this article we have covered the very basics of creating a single-node Kubernetes cluster, installing Rancher on it, configuring Traefik ingress, and deploying our micro-service in the cluster. We used RKE to help us quickly spin up Kubernetes, so we needed to make sure having installed a supported Docker version. We used Rancher to only manage the cluster that it is installed on. We installed MetalLB, the very important dependency for Traefik ingress to work correctly in our local environment. And lastly, we added access credentials to Rancher and deployed a private service from Github.

## Notes and Easter Eggs

### Troubleshoot

Q: Docker cannot start:

    × docker.service - Docker Application Container Engine
        Loaded: loaded (/usr/lib/systemd/system/docker.service; enabled; vendor preset: disabled)
        Active: failed (Result: exit-code) since Wed 2021-04-21 15:13:28 EDT; 1s ago
    TriggeredBy: × docker.socket
        Docs: https://docs.docker.com
        Process: 624 ExecStart=/usr/bin/dockerd -H fd:// (code=exited, status=1/FAILURE)
    Main PID: 624 (code=exited, status=1/FAILURE)
            CPU: 193ms

    Apr 21 15:13:28 vm-loto-arch systemd[1]: docker.service: Scheduled restart job, restart counter is at 3.
    Apr 21 15:13:28 vm-loto-arch systemd[1]: Stopped Docker Application Container Engine.
    Apr 21 15:13:28 vm-loto-arch systemd[1]: docker.service: Start request repeated too quickly.
    Apr 21 15:13:28 vm-loto-arch systemd[1]: docker.service: Failed with result 'exit-code'.
    Apr 21 15:13:28 vm-loto-arch systemd[1]: Failed to start Docker Application Container Engine.

    (dockerd: Error starting daemon: Devices cgroup isn't mounted)

A: Linux kernel is too new. Either downgrade the Linux kernel or install a newer Docker.

### Easter Eggs

1. At first, I tried deploying RKE on Artix Linux: a linux distribution equals Arch Linux minus systemd.

No systemd, no heavy burden. The system runs faster, right? Happy story!

I was installing RKE happily, until I got this:

    INFO[0046] [worker] Successfully started Worker Plane..
    INFO[0046] [controlplane] Now checking status of node ivoire-artix-nexus-0, try #1
    INFO[0051] [controlplane] Now checking status of node ivoire-artix-nexus-0, try #2
    INFO[0056] [controlplane] Now checking status of node ivoire-artix-nexus-0, try #3
    INFO[0061] [controlplane] Now checking status of node ivoire-artix-nexus-0, try #4
    INFO[0066] [controlplane] Now checking status of node ivoire-artix-nexus-0, try #5
    ERRO[0071] Host ivoire-artix-nexus-0 failed to report Ready status with error: host ivoire-artix-nexus-0 not ready
    INFO[0071] [controlplane] Processing controlplane hosts for upgrade 1 at a time
    INFO[0071] Processing controlplane host ivoire-artix-nexus-0
    INFO[0071] [controlplane] Now checking status of node ivoire-artix-nexus-0, try #1
    INFO[0076] [controlplane] Now checking status of node ivoire-artix-nexus-0, try #2
    INFO[0081] [controlplane] Now checking status of node ivoire-artix-nexus-0, try #3
    INFO[0086] [controlplane] Now checking status of node ivoire-artix-nexus-0, try #4
    INFO[0091] [controlplane] Now checking status of node ivoire-artix-nexus-0, try #5
    ERRO[0096] Failed to upgrade hosts: ivoire-artix-nexus-0 with error [host ivoire-artix-nexus-0 not ready]
    FATA[0096] [controlPlane] Failed to upgrade Control Plane: [[host ivoire-artix-nexus-0 not ready]]


RKE cannot get spun up because of the lack of systemd. Which means:

      ____                         ___                 _
     / ___| __ _ _ __ ___   ___   / _ \__   _____ _ __| |
    | |  _ / _` | '_ ` _ \ / _ \ | | | \ \ / / _ \ '__| |
    | |_| | (_| | | | | | |  __/ | |_| |\ V /  __/ |  |_|
     \____|\__,_|_| |_| |_|\___|  \___/  \_/ \___|_|  (_)       (generated by figlet)

2. Then I tried CentOS because it is a system so nice that even has the "cutting edge" `4.18.0-144.el8` kernel with utmost user customization and support.

Well at least I thought it in this way, until:

    mount: unknown filesystem type 'btrfs'
      ____                         ___                 _
     / ___| __ _ _ __ ___   ___   / _ \__   _____ _ __| |
    | |  _ / _` | '_ ` _ \ / _ \ | | | \ \ / / _ \ '__| |
    | |_| | (_| | | | | | |  __/ | |_| |\ V /  __/ |  |_|
     \____|\__,_|_| |_| |_|\___|  \___/  \_/ \___|_|  (_)       (generated by figlet)

What?! A `4.18.0` kernel can't even recognize Btrfs? That's the greatest joke for the day, huh? However, it is what it is in CentOS. According to [RedHat Rhel 8 Changelog][Rhel8FileSystemsAndStorage], Btrfs has been removed for unconvincing reasons.

In my personal view, Btrfs is such an elegant file system that solves so many problems in legacy file systems (copy on write), bringing so much flexibility in system management (sub-volumes and snapshots). With all due respect, a modern Linux system that drops Btrfs support is complete unusable rubbish that reverted to the 1980s! Redhat says alright if you want your Btrfs, go use Fedora, but if you want stability, go use trash. That's not fair. What if, in my case, a user needs 90% stability but also needs 10% customization? A total denial only diverts these users to other distributions. Not CentOS, not RHEL, not Fedora!

Okay in fact the game is not over yet. Forget about Btrfs and we can continue with ext4.

I deliberately disabled `firewalld`, then installed Docker, downloaded the RKE binary, created the RKE config, and spin it up!

Then...

    INFO[0019] [remove/rke-log-linker] Successfully removed container on host [vm-salisto-centOS-nexus-0]
    INFO[0019] [etcd] Successfully started etcd plane.. Checking etcd cluster health
    WARN[0110] [etcd] host [vm-salisto-centOS-nexus-0] failed to check etcd health: failed to get /health for host [vm-salisto-centOS-nexus-0]: Get "https://vm-salisto-centOS-nexus-0:2379/health": Unable to access the service on vm-salisto-centOS-nexus-0:2379. The service might be still starting up. Error: ssh: rejected: connect failed (Connection refused)
    FATA[0110] [etcd] Failed to bring up Etcd Plane: etcd cluster is unhealthy: hosts [vm-salisto-centOS-nexus-0] failed to report healthy. Check etcd container logs on each host for more information
      ____                         ___                 _
     / ___| __ _ _ __ ___   ___   / _ \__   _____ _ __| |
    | |  _ / _` | '_ ` _ \ / _ \ | | | \ \ / / _ \ '__| |
    | |_| | (_| | | | | | |  __/ | |_| |\ V /  __/ |  |_|
     \____|\__,_|_| |_| |_|\___|  \___/  \_/ \___|_|  (_)       (generated by figlet)

I am sure the firewall has been disabled completely, at least from the looks of `firewalld`.

No matter how I try disabling `firewalld`, it just keeps rejecting ssh to the etcd cluster.

Maybe try adding 20+ lines of firewall rules one by one will eventually work. Maybe Fedora won't have such ridiculous firewall issues. But anyway I completely lost my patience with the CentOS family.

3. Back to Arch Linux

At first, I was following the RKE installation guide, which specifies only 3 old docker versions: 18.09.2, 18.06.2, and 17.03.2.

I thought these 3 are the only versions supported by RKE, so I tried to install 18.09.2, which is an old version that only exists in [ArchLinux Archive][ArchLinuxArchive].

``` bash
sudo pacman -U https://archive.archlinux.org/packages/d/docker/docker-1%3A18.09.2-1-x86_64.pkg.tar.xz
```

Then bang! Docker won't even start, as shown in Troubleshoot section.

      ____                         ___                 _
     / ___| __ _ _ __ ___   ___   / _ \__   _____ _ __| |
    | |  _ / _` | '_ ` _ \ / _ \ | | | \ \ / / _ \ '__| |
    | |_| | (_| | | | | | |  __/ | |_| |\ V /  __/ |  |_|
     \____|\__,_|_| |_| |_|\___|  \___/  \_/ \___|_|  (_)       (generated by figlet)

Later I reviewed the [RKE Requirements][RKEDockerReq] page and figured out the latest version of Docker is supported.

So after installing the latest Docker, there was no more issue.

Yay! It finally worked!

(P.s. I tried Debian, it also works.)

## Further readings

Installing RKE: https://rancher.com/docs/rke/latest/en/installation/

Setting up $KUBECONFIG: https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/

Installing Helm: https://helm.sh/docs/intro/quickstart/

Installing Cert Manager: https://cert-manager.io/docs/installation/kubernetes/#installing-with-helm

Installing Rancher 2.5: https://rancher.com/docs/rancher/v2.5/en/installation/install-rancher-on-k8s/

Installing MetalLB: https://metallb.universe.tf/installation/

Traefik Kubernetes Ingress Documentation: https://doc.traefik.io/traefik/providers/kubernetes-ingress/


<!-- Links in this file -->
[WhyRancher]: https://rancher.com/why-rancher/
[TraefikWelcome]: https://doc.traefik.io/traefik/
[RancherHardwareRequirements]: https://rancher.com/docs/rancher/v2.5/en/installation/requirements/#hardware-requirements
[archlinuxSSH_keys]: https://wiki.archlinux.org/index.php/SSH_keys
[RKEDockerReq]: https://rancher.com/support-maintenance-terms/all-supported-versions/rancher-v2.5.7/
[DockerRKEInstallScript]: https://rancher.com/docs/rke/latest/en/os/#installing-docker
[RKEGithubInstall]: https://github.com/rancher/rke/#latest-release
[RKEConfigOptions]: https://rancher.com/docs/rke/latest/en/config-options/
[rancherRequiredPorts]: https://rancher.com/docs/rke/latest/en/os/#ports
[RancherTraefikVideo]: https://youtu.be/pAM2GBCDGTo
[MetalLBConcepts]: https://metallb.universe.tf/concepts/
[Rhel8FileSystemsAndStorage]: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/considerations_in_adopting_rhel_8/file-systems-and-storage_considerations-in-adopting-rhel-8
[ArchLinuxArchive]: https://archive.archlinux.org/
