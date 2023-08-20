#!/bin/bash
RATING_POD="$(kubectl -n ratings get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}')"
REVIEWS_POD="$(kubectl -n reviews get pod -l app=reviews -o jsonpath='{.items[0].metadata.name}')"
PRODUCT_POD="$(kubectl -n productpage get pod -l app=productpage -o jsonpath='{.items[0].metadata.name}')"
DETAILSV1_POD="$(kubectl -n details get pod -l app=details,version=v1 -o jsonpath='{.items[0].metadata.name}')"
DETAILSV2_POD="$(kubectl -n details get pod -l app=details,version=v2 -o jsonpath='{.items[0].metadata.name}')"


kubectl -n ratings exec -it $RATING_POD -c ratings -- curl -s -o /dev/null -I -w "%{http_code}" productpage.productpage:9080/productpage 
echo ""
kubectl -n reviews exec -it $REVIEWS_POD -c reviews -- curl -s -o /dev/null -I -w "%{http_code}" productpage.productpage:9080/productpage 
echo ""

istioctl -n ratings pc all $RATING_POD -o json |wc -c
istioctl -n reviews pc all $REVIEWS_POD -o json |wc -c
istioctl -n productpage pc all $PRODUCT_POD -o json |wc -c
istioctl -n details pc all $DETAILSV1_POD -o json |wc -c
istioctl -n details pc all $DETAILSV2_POD -o json |wc -c


istioctl -n ratings pc all ratings-v1-5ffb4bcbbb-hcdm2 -o json |jq '.configs[] | select(.["@type"] == "type.googleapis.com/envoy.admin.v3.ClustersConfigDump") |  .dynamic_active_clusters[] | select( .cluster.name == "outbound|9080||reviews.reviews.svc.cluster.local" )' |wc -l


echo "namespace isolating ratings host"

echo "size before:"
istioctl -n ratings pc all $RATING_POD -o json |wc -c

kubectl apply -f istio/apps/isolate-ratings.yaml
sleep 1
istioctl -n ratings pc all $RATING_POD -o json |wc -c

echo "testing queries to product"
kubectl -n ratings exec -it $RATING_POD -c ratings -- curl -s -o /dev/null -I -w "%{http_code}" productpage.productpage:9080/productpage 
echo ""
kubectl -n reviews exec -it $REVIEWS_POD -c reviews -- curl -s -o /dev/null -I -w "%{http_code}" productpage.productpage:9080/productpage
echo ""

echo "removing product from the rating side-car"
kubectl apply -f istio/apps/isolate-ratings-complete.yaml

sleep 1
istioctl -n ratings pc all $RATING_POD -o json |wc -c

echo "testing queries to product mTLS STRICT"
kubectl -n ratings exec -it $RATING_POD -c ratings -- curl -s -o /dev/null -I -w "%{http_code}" productpage.productpage:9080/productpage 
echo ""

echo "changing ratings to PERMISSIVE"
kubectl -n ratings apply -f istio/apps/mtls_permissive.yaml
sleep 1
echo "testing queries to product"
kubectl -n ratings exec -it $RATING_POD -c ratings -- curl -s -o /dev/null -I -w "%{http_code}" productpage.productpage:9080/productpage 
echo ""

echo "changing product to PERMISSIVE"
kubectl -n productpage apply -f istio/apps/mtls_permissive.yaml
sleep 1
echo "testing queries to product"
kubectl -n ratings exec -it $RATING_POD -c ratings -- curl -s -o /dev/null -I -w "%{http_code}" productpage.productpage:9080/productpage 
echo ""


kubectl delete -f istio/apps/isolate-ratings-complete.yaml
kubectl -n ratings delete -f istio/apps/mtls_permissive.yaml
kubectl -n productpage delete -f istio/apps/mtls_permissive.yaml