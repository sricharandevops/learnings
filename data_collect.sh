
#!/bin/bash

if [ $# -gt 0 ]; then
    echo "your arguements are $1"
else
    echo "  expected args : 'master' for master node(M* only)  or  for all other hosts 'agent'"
    echo " $0 master or $0 agent "
exit
fi


##Functions
filename=robin-host-data_$(hostname).log

collect_host_data()
{
commands=("uptime" "service kubelet status"  "service docker status" "service dockershim status" "docker images"  "service ntpd status"  "df -h" "uname -a" "ip addr show" "free -g" )
filename=robin-host-data_$(hostname).log

echo " ## collecting host information  from `hostname -f` on `date`##" > $filename
echo " server time: $(date)"
for x in  "${commands[@]}"
do
y=$(echo ~~~~~~~~~~~~~~~~${x}~~~~~~~~~~~~~|sed 's/./~/g')
echo "     $y     " >>$filename
echo "    command: ${x^^} on $(hostname)     " >> $filename
echo "     $y     " >>$filename
echo " " >> $filename
$x >> $filename
done
}

cluster_info()
{
clust_commands=("robin version" "docker version" "kubectl version" "robin license info" "robin instance list" "robin app list" "robin drive list" "robin volume list" "robin host list" "robin host list --services" "robin ap report" "kubectl get nodes" "kubectl get all --all-namespaces -o wide" "docker images" "kubectl get pvc --all-namespaces" "kubectl get pv --all-namespaces" "kubectl version" "robin config list")

filename=robin-cluster-data.log

echo " Collecting some basic cluster wide information ..." > $filename
date >> $filename
echo >> $filename
for i in "${clust_commands[@]}"
do

j=$(echo ~~~~~~~~~${i}~~~~~~~~~~~~~~~~~|sed 's/./~/g')
  echo "     ${j}     " >> $filename
  echo "      command: ${i^^}                      " >> $filename
  echo "     ${j}     " >> $filename
  echo >> $filename
  $i >> $filename
  echo >> $filename
done

}

cert_data()
{
echo "~~~~~~ capturing certificate expiry information ~~~~~" >>$filename
for c in $(ls /etc/kubernetes/pki/*.crt) ; do echo $c ;  openssl x509 -in $c -text -noout | grep 'Not After' ; done >> $filename
for c in $(ls /etc/kubernetes/pki/etcd/*.crt) ; do echo $c ;  openssl x509 -in $c -text -noout | grep 'Not After' ; done >> $filename
for c in $(ls /var/lib/kubelet/pki/*.crt) ; do echo $c ;  openssl x509 -in $c -text -noout | grep 'Not After' ; done >> $filename
}

if [ $1 = "master" ];then
echo "Running master functions"
cluster_info
collect_host_data
cert_data
echo " collect robin-cluster-data.log and robin-host-data_$(hostname -s).log from this host "
elif [ $1 = "agent" ];then
echo "running agent functions"
collect_host_data
#cert_data
else
echo "wrong arguement passed "
exit
fi