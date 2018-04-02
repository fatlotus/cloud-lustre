#!/bin/bash -ex
#
# Bakes a CentOS 7 lustre image from the latest Lustre RPMs.
#
# These instructions were cobbled together from the wiki:
#   http://wiki.lustre.org/Installing_the_Lustre_Software

ZONE=us-central1-f
INSTANCE=build-lustre-image
FAMILY=centos-7-lustre

gcloud compute instances delete -q --zone=$ZONE $INSTANCE || true
gcloud compute instances create \
	--image-project=centos-cloud \
	--image-family=centos-7 \
	--zone=$ZONE \
	$INSTANCE

sleep 60

gcloud compute scp -q --zone=$ZONE make-image-setup.sh circleci@$INSTANCE:
gcloud compute ssh --zone=$ZONE circleci@$INSTANCE \
  --command=./make-image-setup.sh
gcloud compute instances stop --zone=$ZONE $INSTANCE

gcloud compute images create \
	--source-disk $INSTANCE \
	--source-disk-zone $ZONE \
	--family $FAMILY \
	"${FAMILY}-$(date +%s)"

gcloud compute instances delete -q --zone=$ZONE build-lustre-image