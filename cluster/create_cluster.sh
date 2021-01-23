#!/bin/bash

sleep 15
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.5/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.5/manifests/metallb.yaml
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
kubectl apply -f manifests/metallb/config.yml

sleep 15
# Install nfs provisioner
helm install nfs-provisioner stable/nfs-client-provisioner --set nfs.server=nas.hnatekmar.xyz --set nfs.path=/k8s-data

sleep 15
# Install ingress
helm install ingress-nginx ingress-nginx/ingress-nginx --set controller.extraArgs.default-ssl-certificate=default/default-cert --set controller.extraArgs.enable-ssl-passthrough=true

sleep 15
# Install sacred
kubectl apply -k manifests/sacred_omniboard

sleep 15
# Install rancher
kubectl create namespace cattle-system
helm install rancher rancher-stable/rancher --namespace cattle-system --set hostname=rancher.hnatekmar.xyz --set ingress.tls.source=default/default-cert
