# Ubuntu k8s setup, init and check
## Setup
```sh
wget https://raw.githubusercontent.com/estanionis/k8s/main/k8s-setup.sh

chmod +x k8s-setup.sh

./k8s-setup.sh
```
### Init master
```sh
wget https://raw.githubusercontent.com/estanionis/k8s/main/k8s-init-join.sh

chmod +x k8s-init-join.sh

./k8s-init-join.sh
```

```sh
for host in {k8s-1,k8s-2,k8s-3}; do scp kubeadm_join_command.sh "USERNAME"@$host:~/; done
```

#### Check
```sh
wget https://raw.githubusercontent.com/estanionis/k8s/main/k8s-check.sh

chmod +x k8s-check.sh

./k8s-check.sh
```
#### Tools
```sh
wget https://raw.githubusercontent.com/estanionis/k8s/main/k8s-tools.sh

chmod +x k8s-tools.sh

./k8s-tools.sh
```
