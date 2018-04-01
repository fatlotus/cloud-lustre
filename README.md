# Lustre Build Automation for GCP

Latest build: 
![CircleCI](https://img.shields.io/circleci/project/github/fatlotus/cloud-lustre.svg)

This repository uses CircleCI workflows to build a new lustre image on GCP.

## Usage

To boot an instance from this project, file a bug to get access to the image
project. Then create the instance from the source project:

```sh
gcloud compute instances create my-instance \
	--image-project=lustre-on-gcp \
	--image-family=centos-7-lustre \
```