0.prepare 
===
		set two groups for ansible:
* master 
* node

		and, put all the hosts in the front of the config file. 

---
		batch mkdirs		
```sh
./batch-mkdir.sh
```

---
1.set enviroment variables
===
```sh
cd env
```
	modify info in .env files, then
```sh
./run-me-only.sh
```
---
2.install kubectl
		in the stage of installing kubectl, one can run:
```sh
cd mk-kubeconfigs
ansible {{group.use.kubectl}} -m script -a ./mk-kubectl-kubeconfig.sh
```

---
3.install master
===
		cp .service files accordingly，
		then, useing the script batch-start.sh in dir system-unit.

---
4.install node
===
4.1 docker
---
		cd to dir docker-related, 
		first, run:
```sh
./batch-cp.sh
```
		then:
```shell
ansible {{group.using.docker}} -m script -a ./docker-install.sh
```

---
4.2other components
---
		using scripts in dir mk-kubeconfigs for kubelet and kube-proxy for convenience.

---
5.calico
===
		cd to the dir of calico, then
		then modify the values of Secret.data:
* etcd-key  -- with: $(cat /etc/kubernetes/ssl/etcd-key.pem | base64 | tr -d '\n')
* etcd-cert -- with: $(cat /etc/kubernetes/ssl/etcd.pem | base64 | tr -d '\n')
* etcd-ca   -- with: $(cat /etc/kubernetes/ssl/ca.pem | base64 | tr -d '\n')

		then:
```sh
kubectl create -f .
```

---
6.addons
===
		for addons, cd to the dir, and then:
```sh
kubectl create -f .
```
