# ky13 (kritchie@redhat.com)
## IMPORTANT: Change the FROM line in the Dockerfile to the location of your OSE OS image before running the following commands
## This template has the replicas set to 1 spark master and 5 spark workers
## Be sure to run 'oadm policy add-scc-role-to-user anyuid -z default' if you want to run containers as root user

# Build the docker image
docker build .

# Tag the aforementioned image 
docker tag imageID yourOSERepo:5000/openshift/spark

# Push the tagged image to your internal OSE registry (may need to authenticate to OSE registry (docker login -u userName -p "$(oc whoami -t)" -e email@email yourOSERepo:5000))
docker push yourOSERepo:5000/openshift/spark

# Create a template using, injecting relevant variables
oc process -f template.yaml -v SPARK_IMAGE=yourOSERepo:5000/openshift/spark > template.json

oc create -f template.json 
