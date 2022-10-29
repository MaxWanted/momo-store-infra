# Momo Store aka Пельменная №2
[www.momostore.ru](https://www.momostore.ru/) 

##### Gitlab repositories  <br>
- Application - [momo-store](https://gitlab.praktikum-services.ru/m.a.derkach.cloud/momo-store)
- Infrastructure - [momo-infra](https://gitlab.praktikum-services.ru/m.a.derkach.cloud/momo-infra)

*Backend: Golang* <br>
*Frontend: HTML + JavaScript* <br>
*Current release: 1.0.0* <br>

# Application <br>
---  

#### Frontend <br>
```sh
npm install
NODE_ENV=production VUE_APP_API_URL=http://localhost:8081 npm run serve
```

#### Backend <br>
```sh
go run ./cmd/api
go test -v ./... 
```

#### Docker <br>
You can run app in Docker without CI/CD pipeline.
```sh
git clone https://gitlab.praktikum-services.ru/m.a.derkach.cloud/momo-store.git
cd momo-store
docker-compose -f docker-compose-standalone.yml up -d --build
```
open http://localhost:8000

# Infrastructure  <br>       
--- 
```sh
git clone https://gitlab.praktikum-services.ru/m.a.derkach.cloud/momo-infra.git
cd momo-infra
```

You can use **Terraform** to provision a **Kubernetes** cluster in YandexCloud.
Before you need to install [**YC-CLI**](https://cloud.yandex.com/en/docs/cli/operations/install-cli)
```sh
export YC_TOKEN=`yc iam create-token`
cd terraform/k8s-cluster
terraform apply main.tf  -var "yc_token=${YC_TOKEN}"
```

#### Deployment in cluster <br>
**kubectl** <br>
```sh
cd kubernetes
kubectl apply -f backend
cd kubernetes
kubectl apply -f frontend
```

**helm** <br>
```sh
cd helm-charts
helm upgrade --install momo-store  momo-store/  --atomic
```

**Prometheus** <br>
 >You can configure rules for alerting 
 >helm-charts/prometheus/rules/momo-store.yaml
```sh
cd helm-charts 
helm install prometheus prometheus/ --atomic
kubectl port-forward pods/<"prometheus pod's name"> 8081:9090 -n default
```
open dashboard http://localhost:8081

**Grafana** <br>
```sh
cd helm-charts 
helm install grafana grafana/ --atomic
kubectl port-forward pods/<"grafana pod's name"> 8080:3000 -n default
```
open dashboard http://localhost:8080

**Alertmanager** <br>
 >You can configure notification to Slack
 >helm install alermanager alertmanager/ --set slack_hook_url="https://hooks.slack.com/services/..."
```sh
cd helm-charts 
helm install alertmanager alertmanager/ --atomic
```

# Developing <br>
---
There are 2 branch - *main* and  *develop*.
```sh
git checkout develop
git merge --no-ff myfeature
git branch -d myfeature
git push origin develop
```
> [Git flow](https://nvie.com/posts/a-successful-git-branching-model/)

**Helm versioning** <br>
Change code then change version in main Chart.yaml (version: x.y.z), commit and push

> Given a version number MAJOR.MINOR.PATCH, increment the: <br>
> MAJOR version when you make incompatible API changes <br>
> MINOR version when you add functionality in a backwards compatible manner <br>
> PATCH version when you make backwards compatible bug fixes <br>
> https://semver.org