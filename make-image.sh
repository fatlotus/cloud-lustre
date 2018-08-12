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
	--scopes=default,compute-rw \
	--preemptible \
	--metadata-from-file=startup-script=setup-as-lustre.sh \
	$INSTANCE

gcloud compute instances tail-serial-port-output --zone=$ZONE $INSTANCE | tee setuplogs.txt

grep lustre-setup-success setuplogs.txt