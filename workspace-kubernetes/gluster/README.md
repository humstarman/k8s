###Prerequisites
===
enable required kernel modulers<br>
run script: prepare-kernel-modules.sh<br>
on each glusterfs node<br>
(using ansible)<br>

###1. install glusterfs
===
		modify field named GlusterVer in script glusterfs-install.sh to set expected version
then, run glusterfs-install.sh on each glusterfs node
(using ansible)
after the installation, replace VOL_FOR_GLUSTER item in script config-glusterfs.sh according to yout practical situation 
then, run the script on each glusterfs node
(using ansible)

2. config glusterfs
===
2.1 config /etc/hosts
---
replace the information of hosts in script config-etc-hosts.sh according to yout practical situation
then, run the script on each glusterfs node
(using ansible)
2.2 add glusterfs nodes into the glusterfs cluster 
---
!!! only run this on one node
for example, there are three nodes in the cluster, which are node-1, node-2 and node-3
on node-1, run:
$ gluster peer probe node-2
$ gluster peer probe node-3

---
after that, run:
$ gluster peer status
to check

3. config volume
===
3.1 create a volume
---
for the type of Distribute, run:
$ gluster volume create k8s-volume transport tcp node-1:/opt/gfs_data node-2:/opt/gfs_data node-3:/opt/gfs_data force
for the type of Replicate:3, run:
$ gluster volume create k8s-volume replica 3 transport tcp node-1:/opt/gfs_data node-2:/opt/gfs_data node-3:/opt/gfs_data force
3.2 check
---
using:
$ gluster volume info
3.3 start
---
start the glusterfs volume, using:
$ gluster volume start ${VOLUME_NAME}

4. tune glusterfs
===
modify tune-glusterfs.sh according to yout practical situation
then, run the script

5. using glusterfs in kubernetes 
===
5.0 prerequisites
---
may need:
glusterfs
glusterfs-fuse
5.1 apply endpoints
---
for instace:
$ cat glusterfs-endpoints.yaml
apiVersion: v1
kind: Endpoints
metadata:
  name: glusterfs-cluster
subsets:
- addresses:
  - ip: 172.31.78.215
  - ip: 172.31.78.216
  - ip: 172.31.78.217
  ports:
  - port: 1990
    protocol: TCP
5.2 apply service 
---
for instace:
$ cat glusterfs-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: glusterfs-cluster
spec:
  type: ClusterIP
  ports:
  - port: 1990
    protocol: TCP
    targetPort: 1990

After all above, your can create pv and pvc objects to use gluster distributed file system.
