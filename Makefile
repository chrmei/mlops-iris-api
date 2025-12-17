links:
	@echo "Prometheus: http://localhost:9090"
	@echo "Grafana: http://localhost:3000"


build-api:
	docker build -t mlops-iris-api -f ./src/api/Dockerfile .

run-api:
	docker run --rm -d --name iris-api -p 8000:8000 mlops-iris-api

stop-api:
	docker stop iris-api

test-api-direct:
	curl -X POST "http://localhost:8000/predict" -H "Content-Type: application/json" -d '{"petal_length":6.5, "petal_width":0.8}'

test-api-nginx:
	curl -X POST "http://localhost:8080/predict" -H "Content-Type: application/json" -d '{"petal_length":6.5, "petal_width":0.8}'

test-api-ssl:
	curl -X POST "https://localhost/predict" -H "Content-Type: application/json" -d '{"petal_length":6.5, "petal_width":0.8}' --cacert ./deployments/nginx/certs/nginx.crt

test-api-basic-auth:
	curl -X POST "https://localhost/predict" -H "Content-Type: application/json" -d '{"petal_length":6.5, "petal_width":0.8}' --user admin:admin --cacert ./deployments/nginx/certs/nginx.crt

test-load-balancer:
	ab -n 1000 -c 100 -p request.json -T application/json http://localhost:8080/predict

test-rate-limit:
	for i in {1..20}; do curl -s -o /dev/null -w "%{http_code}\n" -X POST "https://localhost/predict" -H "Content-Type: application/json" -d '{"petal_length":6.5, "petal_width":0.8}'     --user "admin:admin" --cacert ./deployments/nginx/certs/nginx.crt; done


start-project:
	docker-compose -p mlops up -d --build

stop-project:
	docker-compose -p mlops down

rerun: build-api stop-project start-project

generate-certificate:
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ./deployments/nginx/certs/nginx.key -out deployments/nginx/certs/nginx.crt -subj "/CN=localhost"

generate-htpasswd:
	htpasswd -c ./deployments/nginx/.htpasswd admin