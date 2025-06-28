# k8s-cluster-terraform
Kubernetes cluster on AWS running Quote services
🔧 AWS + Kubernetes Multi-AZ Strategy
1. Use a VPC with Subnets in Multiple AZs

    Create a VPC with at least 2–3 public and private subnets, one in each AZ.

    Terraform can automate this.

    For HA, place:

        Control Plane (Master) in one AZ

        Worker Nodes in other AZs

        Or run multiple masters in separate AZs (requires etcd HA too)

2. Attach a Load Balancer Across All AZs

    Use an AWS Network Load Balancer (NLB) or Application Load Balancer (ALB).

    It will automatically route traffic to healthy nodes across AZs.

    Expose Kubernetes API or Ingress controller via NLB/ALB.

3. Set Up Kubernetes topology.kubernetes.io/zone Labels

    Kubernetes will automatically detect AZs and label nodes.

    You can use these for pod anti-affinity rules to prevent multiple pods of the same app landing in the same AZ.

4. Ensure EBS Volumes Use Multi-AZ Storage or Avoid Zonal Lock-In

    For stateful apps (like databases), EBS volumes are AZ-specific.

    Use EFS or S3 for shared storage or run replicas in each AZ.

    Auto scaler instead of static ec2 instances

Auto-join workers by injecting the kubeadm join command at runtime

Add Calico/Flannel CNI in master user_data

Attach an EBS CSI driver or ingress controller

 Update your Terraform code to provision an AWS ALB or ELB
✅ Update your Kubernetes manifests to use NodePort and let ALB/ELB target that port
✅ Install Nginx Ingress or EngineX on master if you want to control routing internally
After EC2s are up:

    SSH into the first node, initialize the cluster:

sudo kubeadm init --pod-network-cidr=192.168.0.0/16

    Save the kubeadm join ... command from output.

    On all worker nodes, run the kubeadm join command.

    On master, set up config:

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

    Install networking plugin (Calico):

kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

🌐 Add Ingress and Load Balancer:

    Install NGINX Ingress Controller:

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.2.1/deploy/static/provider/cloud/deploy.yaml

    If you use AWS ELB/NLB, expose services with type: LoadBalancer and AWS will create a public-facing ELB.


✅ Next Steps

After applying the Terraform:

    SSH into the first node:

ssh -i ~/.ssh/id_rsa ubuntu@<master_ip>

Initialize the master:

sudo kubeadm init --pod-network-cidr=192.168.0.0/16

Set up local kubeconfig:

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

Copy the kubeadm join ... command and run it on the other two nodes.

Would you like me to:

    Create example YAML files for Calico, NGINX Ingress, and a test app

    Add the Terraform block to automatically kubectl apply them?

Let me know if you'd like manual kubeadm init (safer for first-time users) or full automated joining and cluster setup via Terraform.

k8s-cluster-project/
├── install-kubeadm.sh
├── main.tf
├── providers.tf
├── variables.tf
├── outputs.tf
├── manifests/
│   ├── dev/
│   │   ├── calico.yaml
│   │   ├── ingress-nginx.yaml
│   │   └── app-deployment.yaml
│   └── prod/
│       ├── calico.yaml
│       ├── ingress-nginx.yaml
│       └── app-deployment.yaml
ACM certificate and Let's Encrypt automation

Helm chart support per environment

Backend config for remote Terraform state (e.g., in S3) 




mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

👉 This allows kubectl to communicate securely with the cluster API as an admin user.


👉 Use Jenkins credentials store for SSH key instead of hardcoding path.
👉 Archive kubeconfig from master as an artifact to download/manage locally.
👉 Add a destroy stage to tear down infra.
👉 Add Flannel or Calico CNI deployment after kubeadm init.