#!/usr/bin/env bash

#*******************************************************************************
# Copyright (c) 2019 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html,
# or the MIT License which is available at https://opensource.org/licenses/MIT.
# SPDX-License-Identifier: EPL-2.0 OR MIT
#*******************************************************************************

# Bash strict-mode
set -o errexit
set -o nounset
set -o pipefail

# Parameters:
release_name=${1:-}
namespace="infocenter"
hostname="help.eclipse.org"
dockerhub_repo="eclipsecbi/eclipse-infocenter"
nginx_image="eclipsefdn/nginx:stable-alpine"

# Verify inputs
if [[ -z "${release_name}" && $# -lt 1 ]]; then
  printf "ERROR: a release name must be given.\n"
  exit 1
fi

create_license_header() {
  local file=${1:-}
  local year="2019"
  cat <<EOF > ${file}
#*******************************************************************************
# Copyright (c) ${year} Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html,
# or the MIT License which is available at https://opensource.org/licenses/MIT.
# SPDX-License-Identifier: EPL-2.0 OR MIT
#*******************************************************************************
EOF
}

create_route () {
  local release_name=${1:-}
  local namespace_name=${2:-}
  local host_name=${3:-}
  local file_name="${release_name}/route.yml"
  create_license_header ${file_name}
  cat <<EOF >> ${file_name}
apiVersion: "route.openshift.io/v1"
kind: "Route"
metadata:
  labels:
    infocenter.version: "${release_name}"
  namespace: "${namespace_name}"
  annotations:
    haproxy.router.openshift.io/timeout: 60s
  name: "infocenter-${release_name}"
spec:
  host: "${host_name}"
  path: "/${release_name}"
  port:
    targetPort: "http"
  tls:
    insecureEdgeTerminationPolicy: "Redirect"
    termination: "edge"
  to:
    kind: "Service"
    name: "infocenter-${release_name}"
    weight: 100
EOF
}

create_service () {
  local release_name=${1:-}
  local namespace_name=${2:-}
  local file_name="${release_name}/service.yml"
  create_license_header ${file_name}
  cat <<EOF >> ${file_name}
apiVersion: "v1"
kind: "Service"
metadata:
  labels:
    infocenter.version: "${release_name}"
  namespace: "${namespace_name}"
  name: "infocenter-${release_name}"
spec:
  ports:
  - name: "http"
    port: 80
    protocol: "TCP"
    targetPort: 8080
  selector:
    infocenter.version: "${release_name}"
EOF
}

create_nginx_configmap () {
  local release_name=${1:-}
  local namespace_name=${2:-}
  local file_name="${release_name}/nginx-configmap.yml"
  create_license_header ${file_name}
  cat <<EOF >> ${file_name}
apiVersion: v1
kind: ConfigMap
metadata:
  labels:
    infocenter.version: "${release_name}"
  namespace: "${namespace_name}"
  name: nginx-config-${release_name}
data:
  nginx.conf: |-
    worker_processes  1;
    error_log  /var/log/nginx/error.log warn;
    pid        /var/run/nginx.pid;
    events {
      worker_connections  1024;
    }
    http {
      include       /etc/nginx/mime.types;
      default_type  application/octet-stream;
      sendfile        on;
      keepalive_timeout  65;
      server {
        listen 8080;
        location /${release_name}/ {
          proxy_pass           http://127.0.0.1:8086/help/;
        }
      }
    }
EOF
}

create_statefulset () {
  local release_name=${1:-}
  local namespace_name=${2:-}
  local file_name="${release_name}/statefulset.yml"
  local sha256="$(docker inspect --format='{{index .RepoDigests 0}}' "${dockerhub_repo}:${release_name}" | sed -E 's/.*sha256:(.*)/\1/g')"
  local infocenter_image=${dockerhub_repo}:${release_name}@sha256:${sha256}
  echo "Image name: ${infocenter_image}"
  
  create_license_header ${file_name}
  cat <<EOF >> ${file_name}
apiVersion: apps/v1
kind: StatefulSet
metadata:
  labels:
    infocenter.version: "${release_name}"
  namespace: "${namespace_name}"
  name: "infocenter-${release_name}"
spec:
  replicas: 1
  selector:
    matchLabels:
      infocenter.version: "${release_name}"
  serviceName: "infocenter-${release_name}"
  template:
    metadata:
      labels:
        infocenter.version: "${release_name}"
      name: "infocenter-${release_name}"
    spec:
      terminationGracePeriodSeconds: 1200
      containers:
      - name: infocenter-${release_name}
        image: ${infocenter_image}
        imagePullPolicy: IfNotPresent
        command:
          - /infocenter/startDockerInfoCenter.sh
        livenessProbe:
          httpGet:
            path: /help/index.jsp
            port: 8086
            scheme: HTTP
          initialDelaySeconds: 480
          periodSeconds: 60
          failureThreshold: 2
          timeoutSeconds: 90
        readinessProbe:
          httpGet:
            path: /help/index.jsp
            port: 8086
          periodSeconds: 60
          timeoutSeconds: 90
          initialDelaySeconds: 60
        ports:
        - containerPort: 8086
          protocol: TCP
        resources:
          requests:
            cpu: 500m
          limits:
            cpu: 2
            memory: 1.5Gi
        volumeMounts:
        - name: workspace
          mountPath: "/infocenter/workspace"
      - name: nginx
        image: ${nginx_image}
        ports:
        - containerPort: 8080
        volumeMounts:
        - name: nginx-config
          mountPath: /etc/nginx/nginx.conf
          subPath: nginx.conf
      volumes:
      - name: workspace
        emptyDir: {}
      - name: nginx-config
        configMap:
          name: nginx-config-${release_name}
EOF
}

mkdir -p ${release_name}
create_route ${release_name} ${namespace} ${hostname}
create_service ${release_name} ${namespace}
create_nginx_configmap ${release_name} ${namespace}
create_statefulset ${release_name} ${namespace}

