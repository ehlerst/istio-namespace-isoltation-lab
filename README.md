# istio-namespace-isoltation-lab
namespace isolation lab

## Just a lab to kick the tires on isolation and gauge how and what it does.

Base lab setup contains config of roughly `1020862` when isolating the after size is `845321` This value is exponential based on how many services are in your cluster. The lab only has 4. 

### What you really lose.
mTLS is lost when you isloate, you are essentially breaking the mesh.

```sh
~/bin/logcli query '{mesh="cluster.local"}' |tr ',' '\n' | grep downstream_tls_version 
2023/08/20 15:35:24 http://localhost:3100/loki/api/v1/query_range?direction=BACKWARD&end=1692563724191015386&limit=30&query=%7Bmesh%3D%22cluster.local%22%7D&start=1692560124191015386
2023/08/20 15:35:24 Common labels: {cluster="Kubernetes", exporter="OTLP", mesh="cluster.local"}
"downstream_tls_version":"-"
"downstream_tls_version":"-"
"downstream_tls_version":"-"
"downstream_tls_version":"-"
"downstream_tls_version":"TLSv1.3"
"downstream_tls_version":"-"
"downstream_tls_version":"TLSv1.3"
"downstream_tls_version":"TLSv1.3"
"downstream_tls_version":"-"
"downstream_tls_version":"TLSv1.3"
"downstream_tls_version":"-"
"downstream_tls_version":"-"
"downstream_tls_version":"-"
"downstream_tls_version":"-"
"downstream_tls_version":"-"
"downstream_tls_version":"TLSv1.3"
"downstream_tls_version":"-"
"downstream_tls_version":"TLSv1.3"
"downstream_tls_version":"TLSv1.3"
"downstream_tls_version":"-"
"downstream_tls_version":"TLSv1.3"
"downstream_tls_version":"-"
"downstream_tls_version":"-"
"downstream_tls_version":"-"
"downstream_tls_version":"-"
"downstream_tls_version":"TLSv1.3"
"downstream_tls_version":"-"
"downstream_tls_version":"TLSv1.3"
"downstream_tls_version":"TLSv1.3"
"downstream_tls_version":"-"

```