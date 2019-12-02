wget https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml
sed -i 's/k8s.gcr.io/mirrorgooglecontainers/g' kubernetes-dashboard.yaml
sed -i '/targetPort:/a\ \ \ \ \ \ nodePort: 30001\n\ \ type: NodePort' kubernetes-dashboard.yaml

kubectl create -f kubernetes-dashboard.yaml
#kubectl get deployment kubernetes-dashboard -n kube-system
#kubectl get pods -n kube-system -o wide
#kubectl get services -n kube-system
#netstat -ntlp|grep 30001


#在Firefox浏览器输入Dashboard访问地址：https://192.168.10.205:30001

建立私钥： 
cd /etc/kubernetes/pki/
(umask 077; openssl genrsa -out dashboard.key 2048)


#建立一个证书签署请求：
openssl req -new -key dashboard.key  -out dashboard.csr -subj "/O=zhixin/CN=dashboard"

# 下面开始签署证书：
openssl  x509 -req -in dashboard.csr -CA ca.crt -CAkey ca.key  -CAcreateserial -out dashboard.crt -days 365

# 把上面生成的私钥和证书创建成secret
kubectl create secret generic dashboard-cert -n kube-system --from-file=dashboard.crt=./dashboard.crt  --from-file=dashboard.key=./dashboard.key 
kubectl get secret -n kube-system |grep dashboard

#创建一个serviceaccount，因为dashborad需要serviceaccount(pod之间登录验证的用户)验证登录。
kubectl create serviceaccount dashboard-admin -n kube-system
kubectl get sa -n kube-system |grep admin

#下面通过clusterrolebinding把dashboard-admin加入到clusterrole里面。
kubectl create clusterrolebinding dashboard-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:dashboard-admin

#生成token
kubectl describe secrets -n kube-system $(kubectl -n kube-system get secret | awk '/dashboard-admin/{print $1}')








