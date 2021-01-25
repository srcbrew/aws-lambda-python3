FUNC = hello-world-HelloWorldFunction-P1SJZMP8NQLW
AWS = aws --region us-east-1 --output json --no-cli-pager
PROD_VER = 2

build: src/requirements.txt
	sam build --use-container

layer: src/requirements.txt
	docker run --rm -it -v $(CURDIR):/app -v ~/.cache/pip:/root/.cache/pip -w /app python:3.8 bash -c "pip install --target ./package/python -r src/requirements.txt --upgrade"

setup:
	# $(AWS) cloudformation delete-stack --stack-name hello-world-setup
	$(AWS) cloudformation update-stack --stack-name hello-world-setup --template-body file://setup.yaml \
		--capabilities CAPABILITY_AUTO_EXPAND

testing:
	sam package --template-file template.yaml --output-template-file testing.yaml \
		--s3-bucket aws-sam-app-xecvb21m4lus --s3-prefix hello-world --region us-east-1
	sam deploy --template-file testing.yaml --stack-name hello-world --no-confirm-changeset \
		--capabilities CAPABILITY_IAM \
		--s3-bucket aws-sam-app-xecvb21m4lus --s3-prefix hello-world --region us-east-1

run:
	sam local invoke --event ./assets/events/etl.json

version:
	$(AWS) lambda get-function --function-name $(FUNC)
	$(AWS) lambda publish-version --function-name $(FUNC) --description "bump version to v3"

production:
	$(AWS) lambda update-alias --function-name $(FUNC) --name stable --function-version $(PROD_VER)

.PHONY: build layer setup testing
