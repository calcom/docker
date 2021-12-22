<!-- PROJECT LOGO -->
<div align="right">
  <a href="https://github.com/calendso/calendso">
    <img src="https://cal.com/logo.svg" alt="Logo" width="160" height="65">
  </a><br/>
  <a href="https://cal.com">Website</a>
  ·
  <a href="https://github.com/calendso/calendso-docker/issues">Community Support</a>
</div>

# calendso-docker

The Docker configuration for Calendso is an effort powered by people within the community. Calendso does not provide official support for Docker, but we will accept fixes and documentation. Use at your own risk.

## Requirements

Make sure you have `docker` & `docker-compose` installed on the server / system.

## Getting Started

1. Clone calendso-docker

    ```bash
    git clone --recursive https://github.com/calendso/docker.git calendso-docker
    ```

2. Change into the directory

    ```bash
    cd calendso-docker
    ```

3. Rename `.env.example` to `.env` and update `.env` if needed.

4. Build and start calendso

    ```bash
    docker-compose up --build
    ```

5. Start prisma studio

    ```bash
    docker-compose exec calendso npx prisma studio
    ```

6. Open a browser to [http://localhost:5555](http://localhost:5555) to look at or modify the database content.

7. Click on the `User` model to add a new user record.

8. Fill out the fields (remembering to encrypt your password with [BCrypt](https://bcrypt-generator.com/)) and click `Save 1 Record` to create your first user.

9. Open a browser to [http://localhost:3000](http://localhost:3000) and login with your just created, first user.

## Git Submodules

This repository uses a git submodule.

If you cloned the repository without using `--recursive`, then you can initialize and clone the submodule with the following steps.

1. Init the submodule

    ```bash
    git submodule init
    ```

2. Update the submodule

    ```bash
    git submodule update --remote
    ```

For more advanced usage, please refer to the git documentation: [https://git-scm.com/book/en/v2/Git-Tools-Submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules)

## Install calendso on kubernetes

1. Create a locally calendso image with tag

    ```bash
    cd calendso-docker
    docker build -t calendso:2.1 .
    ```

2.  Create a tag TARGET_IMAGE that refers to SOURCE_IMAGE

    ```bash
    docker tag calendso:2.1 PathRepository/calendso:2.1
    ```

3. Pull calendso image from the repository

    ```bash
    docker push PathRepository/calendso:2.1
    ```
    => Note: May you need to login before this step !

4. Configuration

    The following table lists the configurable parameters of calendso-chart and their default values.
    
| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `JWT_SECRET` | Reference to the secret to be used when pulling images | `[]` |
| `image.repository` | Image repository | `quay.io/jetstack/cert-manager-controller` |
| `image.tag` | Image tag | `v0.6.2` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `replicaCount`  | Number of cert-manager replicas  | `1` |
| `DATABASE_URL` | Reference to the url of the database | `[]` |
| `BASE_URL` | Reference to the url of calendso application after its installation | `[]` |
| `GOOGLE_API_CREDENTIALS` | Reference to Google API credentials. You can get this from https://console.cloud.google.com/apis/dashboard | `[]` |
| `MS_GRAPH_CLIENT_ID` | Reference to the application (client) ID from https://portal.azure.com/#blade/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/RegisteredApps | `[]` |
| `MS_GRAPH_CLIENT_SECRET` | Reference to the application (SecretClient) ID from https://portal.azure.com/#blade/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/RegisteredApps  | `[]` |
| `ZOOM_CLIENT_ID` | Used for ZOOM integration, you can get this from https://marketplace.zoom.us/ | `[]` |
| `ZOOM_CLIENT_SECRET` | Used for ZOOM integration, you can get this from https://marketplace.zoom.us/ | `[]` |
| `NEXT_PUBLIC_TELEMETRY_KEY` | used to allow calendso to collect anonymous usage | `[]` |
| `DAILY_API_KEY` | Used for the Daily integration | `[]` |
| `EMAIL_FROM` | Configures the global From: header whilst sending emails. | `[]` |
| `CRON_API_KEY` | Reference to ApiKey for cronjobs | `[]` |
| `clusterResourceNamespace` | Override the namespace used to store DNS provider credentials etc. for ClusterIssuer resources | Same namespace as cert-manager pod
| `leaderElection.Namespace` | Override the namespace used to store the ConfigMap for leader election | Same namespace as cert-manager pod
| `extraArgs` | Optional flags for cert-manager | `[]` |
| `extraEnv` | Optional environment variables for cert-manager | `[]` |
| `rbac.create` | If `true`, create and use RBAC resources | `true` |
| `serviceAccount.create` | If `true`, create a new service account | `true` |
| `serviceAccount.name` | Service account to be used. If not set and `serviceAccount.create` is `true`, a name is generated using the fullname template |  |
| `resources` | CPU/memory resource requests/limits | |
| `securityContext.enabled` | Enable security context | `false` |
| `securityContext.fsGroup` | Group ID for the container | `1001` |
| `securityContext.runAsUser` | User ID for the container | `1001` |
| `nodeSelector` | Node labels for pod assignment | `{}` |
| `affinity` | Node affinity for pod assignment | `{}` |
| `tolerations` | Node tolerations for pod assignment | `[]` |
| `ingressShim.defaultIssuerName` | Optional default issuer to use for ingress resources |  |
| `ingressShim.defaultIssuerKind` | Optional default issuer kind to use for ingress resources |  |
| `ingressShim.defaultACMEChallengeType` | Optional default challenge type to use for ingresses using ACME issuers |  |
| `ingressShim.defaultACMEDNS01ChallengeProvider` | Optional default DNS01 challenge provider to use for ingresses using ACME issuers with DNS01 |  |
| `podAnnotations` | Annotations to add to the cert-manager pod | `{}` |
| `podDnsPolicy` | Optional cert-manager pod [DNS policy](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pods-dns-policy) |  |
| `podDnsConfig` | Optional cert-manager pod [DNS configurations](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pods-dns-config) |  |
| `podLabels` | Labels to add to the cert-manager pod | `{}` |
| `priorityClassName`| Priority class name for cert-manager and webhook pods | `""` |
| `http_proxy` | Value of the `HTTP_PROXY` environment variable in the cert-manager pod | |
| `https_proxy` | Value of the `HTTPS_PROXY` environment variable in the cert-manager pod | |
| `no_proxy` | Value of the `NO_PROXY` environment variable in the cert-manager pod | |
| `webhook.enabled` | Toggles whether the validating webhook component should be installed | `true` |
| `webhook.replicaCount` | Number of cert-manager webhook replicas | `1` |
| `webhook.podAnnotations` | Annotations to add to the webhook pods | `{}` |
| `webhook.extraArgs` | Optional flags for cert-manager webhook component | `[]` |
| `webhook.resources` | CPU/memory resource requests/limits for the webhook pods | |
| `webhook.image.repository` | Webhook image repository | `quay.io/jetstack/cert-manager-webhook` |
| `webhook.image.tag` | Webhook image tag | `v0.6.2` |
| `webhook.image.pullPolicy` | Webhook image pull policy | `IfNotPresent` |
| `webhook.caSyncImage.repository` | CA sync image repository | `quay.io/munnerz/apiextensions-ca-helper` |
| `webhook.caSyncImage.tag` | CA sync image tag | `v0.1.0` |
| `webhook.caSyncImage.pullPolicy` | CA sync image pull policy | `IfNotPresent` |

 All these Values built-in object provides access to the values passed into calendso-chart through the Values.yaml file.
Specify each parameter using the --set key=value[,key=value] argument to helm install or modify them in values.yaml as below.

    * Put the repository of calendso image in values.yaml
    ```
    image:
        repository: #your calendso docker image repo
        pullPolicy: IfNotPresent
        tag: ""
    ```

    for example here we used calendso:2.1 so the image will be like this

    =>  image:
         repository: PathRepository/calendso
         pullPolicy: IfNotPresent
         tag: "2.1"

    * Upgrading calendso helm chart

    To install the chart from the Helm repository with the release name yourReleaseName
    ```bash
        helm upgrade --install -n yourNamespace yourReleaseName path/Calendso-Chart
    ```
5. Access prisma studio
 
    * Show pod's name
    ```bash
        kubectl get pods -n yourNamespace
    ```
    In two separate console:

    * Start prisma studio
    ```bash
        kubectl exec -n yourNamespace podsName -- npx prisma studio
    ```
    
    * Forward port:5555
    ```bash
    kubectl port-forward -n yourNamespace podsName 5555:5555
    ```
6. You can now access prisma studio from your computer

    * Open a browser to http://127.0.0.1:5555 to look at or modify the database content.
    
    * Click on the User model to add a new user record.

    * Fill out the fields (remembering to encrypt your password with https://bcrypt-generator.com/) and click Save 1 Record to create your first user.

    * Open a browser to a link in the variable Base_Url indicated in .env.example and login with your just created, first user.

## Troubleshooting

* SSL edge termination: If running behind a load balancer which handles SSL certificates, you will need to add the environmental variable `NODE_TLS_REJECT_UNAUTHORIZED=0` to prevent requests from being rejected. Only do this if you know what you are doing and trust the services/load-balancers directing traffic to your service.


