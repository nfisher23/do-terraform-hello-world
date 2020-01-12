# set current kubectl context to the terraform-created digital ocean cluster
doctl k c kubeconfig save "$(doctl k c list | grep hello | awk '{print $1}')" --set-current-context
kubectl cluster-info # sanity

# create redis master via deployment and expose a ClusterIP load balancer
kubectl apply -f deployments/guestbook/redis-master-deployment.yml
sleep 3
kubectl apply -f services/guestbook/redis-master-service.yaml

# do the same for the redis slaves
kubectl apply -f deployments/guestbook/redis-slave-deployment.yml
sleep 3
kubectl apply -f services/guestbook/redis-slave-service.yaml

# deploy the frontend application, which is configured to look at
# redis master and slaves, then expose a LoadBalancer for it
kubectl apply -f deployments/guestbook/frontend-deployment.yml
sleep 3
kubectl apply -f services/guestbook/frontend-service.yaml

sleep 5
# get the ip address so we can play with it
FRONTEND_IP="null"
while [ "$FRONTEND_IP" == "null" ]; do
  FRONTEND_IP=$(kubectl get service frontend -o json | jq -r ".status.loadBalancer.ingress[0].ip")
  echo "waiting for load balancer..."
  sleep 5
done

echo "ip: $FRONTEND_IP"

exit 0