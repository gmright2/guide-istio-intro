@echo off

set LIVE_DEPLOYMENT=%1

IF %LIVE_DEPLOYMENT% == "blue" goto BLUE_DEPLOYMENT
IF %LIVE_DEPLOYMENT% == "green" goto GREEN_DEPLOYMENT

echo %LIVE_DEPLOYMENT% is an invalid option
exit 1

:BLUE_DEPLOYMENT
set WEIGHT_BLUE=100
set WEIGHT_GREEN=0
set TEST_WEIGHT_BLUE=0
set TEST_WEIGHT_GREEN=100
echo "Setting blue as live..."
goto DEPLOY

:GREEN_DEPLOYMENT
set WEIGHT_BLUE=0
set WEIGHT_GREEN=100
set TEST_WEIGHT_BLUE=100
set TEST_WEIGHT_GREEN=0
echo "Setting green as live..."

:DEPLOY
echo apiVersion: networking.istio.io/v1alpha3^
kind: VirtualService^
metadata:^
  name: hello-virtual-service^
spec:^
  hosts:^
  - "example.com"^
  gateways:^
  - hello-gateway^
  http:^
  - route:^
    - destination:^
        port:^
          number: 9080^
        host: hello-service^
        subset: blue^
      weight: 100^
    - destination:^
        port:^
          number: 9080^
        host: hello-service^
        subset: green^
      weight: 0^
---^
apiVersion: networking.istio.io/v1alpha3^
kind: VirtualService^
metadata:^
  name: hello-test-virtual-service^
spec:^
  hosts:^
  - "test.example.com"^
  gateways:^
  - hello-gateway^
  http:^
  - route:^
    - destination:^
        port:^
          number: 9080^
        host: hello-service^
        subset: blue^
      weight: 0^
    - destination:^
        port:^
          number: 9080^
        host: hello-service^
        subset: green^
      weight: 100^
---^
apiVersion: networking.istio.io/v1alpha3^
kind: DestinationRule^
metadata:^
  name: hello-destination-rule^
spec:^
  host: hello-service^
  subsets:^
  - name: blue^
    labels:^
      version: blue^
  - name: green^
    labels:^
      version: green^
> tmp-traffic.yaml

kubectl apply -f tmp-traffic.yaml
DEL tmp-traffic.yaml
