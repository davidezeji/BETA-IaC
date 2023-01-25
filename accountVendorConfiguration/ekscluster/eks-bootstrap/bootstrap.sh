# export efs_id=$1
# export efs_csi_iam_role_arn=$2
# export service_account_name=$3
# export region="us-west-2"
#sh bootsrap.sh efs-id iam-role-arn


if [ ! $(which kubectl) ]
then
  curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.23.13/2022-10-31/bin/linux/amd64/kubectl
  sudo mv kubectl /usr/local/bin/
  sudo chmod a+x /usr/local/bin/kubectl
fi


#if helm install required.
if [ ! $(which helm) ]
then
  HELM_DOWNLOAD_URL=https://get.helm.sh/helm-v3.5.4-linux-amd64.tar.gz
  wget -q $HELM_DOWNLOAD_URL
  tar -zxvf helm-v3.5.4-linux-amd64.tar.gz
  sudo mv linux-amd64/helm /usr/local/bin/helm
  sudo chmod a+x /usr/local/bin/helm
fi

aws eks update-kubeconfig --region $region --name $cluster_name
if [ $? -ne 0 ]
then
  echo "Unable to connect to eks, hence exitting the script"
fi

echo "Creating efs service account-"
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app.kubernetes.io/name: aws-efs-csi-driver
  name: ${service_account_name}
  namespace: kube-system
  annotations:
    eks.amazonaws.com/role-arn: $efs_csi_iam_role_arn
EOF
echo "Status - $?"


echo "installing efs csi driver-"
helm repo add aws-efs-csi-driver https://kubernetes-sigs.github.io/aws-efs-csi-driver/
helm repo update
helm upgrade -i aws-efs-csi-driver aws-efs-csi-driver/aws-efs-csi-driver \
    --namespace kube-system \
    --set image.repository=602401143452.dkr.ecr.${region}.amazonaws.com/eks/aws-efs-csi-driver \
    --set controller.serviceAccount.create=false \
    --set controller.serviceAccount.name=${service_account_name}
echo "Status - $?"
sleep 5



#efs-storageclass.yaml -- replace efs id
echo "Creating efs storage class-"
cat <<EOF | kubectl apply -f -
---
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: efs-sc
provisioner: efs.csi.aws.com
parameters:
  provisioningMode: efs-ap
  fileSystemId: $efs_id
  directoryPerms: "700"
  gidRangeStart: "1000"
  gidRangeEnd: "2000"
  basePath: "/dynamic_provisioning"
EOF

#Multus INstall:
echo "Multus pod install -"
    kubectl apply -f https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/master/config/multus/v3.7.2-eksbuild.1/aws-k8s-multus.yaml
echo "Status - $?"

#Whereabouts:
echo "Whereabouts pod install-"
    wget https://github.com/k8snetworkplumbingwg/whereabouts/archive/refs/tags/v0.5.4.tar.gz
    tar -xzf v0.5.4.tar.gz
    kubectl apply -f whereabouts-0.5.4/doc/crds/
echo "Status - $?"

#Test Pod deploy
echo "Test pod deploy-"
kubectl apply -f eks-bootstrap/test-pod.yaml
echo "Status - $?"