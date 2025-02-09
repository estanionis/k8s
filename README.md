# Ubuntu k8s setup, init and check
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

### Join node
```sh
wget https://raw.githubusercontent.com/estanionis/k8s/main/k8s-init-join.sh

chmod +x k8s-init-join.sh

./k8s-init-join.sh
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
