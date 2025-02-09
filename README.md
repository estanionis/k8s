# Ubuntu k8s setup, init and check (1 control-plane, 3 worker nodes)
## Setup
```sh
wget https://raw.githubusercontent.com/estanionis/k8s/main/k8s-setup.sh

chmod +x k8s-setup.sh

./k8s-setup.sh
```
### Init control-plane
```sh
wget https://raw.githubusercontent.com/estanionis/k8s/main/k8s-init-join.sh

chmod +x k8s-init-join.sh

./k8s-init-join.sh
```

```sh
wget https://raw.githubusercontent.com/estanionis/k8s/main/k8s-scp-join.sh

chmod +x k8s-scp-join.sh

./k8s-scp-join.sh
```

### Check Health
```sh
wget https://raw.githubusercontent.com/estanionis/k8s/main/k8s-check.sh

chmod +x k8s-check.sh

./k8s-check.sh
```

### Join Node to k8s cluster
```sh
wget https://raw.githubusercontent.com/estanionis/k8s/main/k8s-init-join.sh

chmod +x k8s-init-join.sh

./k8s-init-join.sh
```

#### Tools
```sh
wget https://raw.githubusercontent.com/estanionis/k8s/main/k8s-tools.sh

chmod +x k8s-tools.sh

./k8s-tools.sh
```
