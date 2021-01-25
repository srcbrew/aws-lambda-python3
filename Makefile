build: src/requirements.txt
	sam build --use-container

layer: src/requirements.txt
	docker run --rm -it -v $(CURDIR):/app -v ~/.cache/pip:/root/.cache/pip -w /app python:3.8 bash -c "pip install --target ./package/python -r src/requirements.txt --upgrade"

testing:
	sam package --template-file template.yaml --output-template-file testing.yaml \
		--s3-bucket aws-sam-app-xecvb21m4lus --s3-prefix hello-world --region us-east-1
	sam deploy --template-file testing.yaml --stack-name hello-world --no-confirm-changeset \
		--capabilities CAPABILITY_IAM \
		--s3-bucket aws-sam-app-xecvb21m4lus --s3-prefix hello-world --region us-east-1
		
deploy-jp:
	sam package --template-file template.yaml --output-template-file testing.yaml \
		--s3-bucket aws-sam-app-xecvb21m4lus --s3-prefix hello-world --region us-east-1
	sam deploy --template-file testing.yaml --stack-name hello-world --no-confirm-changeset \
		--capabilities CAPABILITY_IAM \
		--s3-bucket aws-sam-app-xecvb21m4lus --s3-prefix hello-world --region us-east-1

run:
	sam local invoke --event ./assets/events/etl.json

sync-jobs:
	./assets/job/operationdaily/sync.sh

.PHONY: build deploy-jp deploy-au run sync-jobs
