#!/bin/bash
RATING_POD="$(kubectl -n ratings get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}')"
kubectl -n ratings exec -it $RATING_POD -c ratings -- curl productpage.productpage:9080/productpage |wc -c