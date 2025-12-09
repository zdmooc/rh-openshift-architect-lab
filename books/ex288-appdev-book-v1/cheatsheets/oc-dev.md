# oc — développeur
oc new-project <ns>
oc project <ns>
oc new-app <image|imagestream|template> [--name N] [--build-env K=V] [--env K=V]
oc start-build <bc> --from-dir=. --follow
oc set env dc/<name> KEY=VAL --overwrite
oc set probes dc/<name> --liveness --get-url=http://:8080/ --initial-delay-seconds=10
oc expose svc/<name>
oc get bc,is,dc,svc,route,pod -n <ns>
oc rollout status dc/<name>
oc rollout history dc/<name>
oc rollout undo dc/<name>
