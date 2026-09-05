#!/bin/bash
set -e

export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")
[ -z "$REGION" ] && export REGION="us-central1"
export PROJECT_ID=$GOOGLE_CLOUD_PROJECT

gcloud config set run/region $REGION
gcloud services enable run.googleapis.com cloudbuild.googleapis.com firestore.googleapis.com

cd /tmp
rm -rf pet-theory
git clone https://github.com/rosera/pet-theory.git
cd pet-theory/lab08

# Phase 1: Prototype v0.1
cat << 'MAIN_V1' > main.go
package main

import (
  "fmt"
  "log"
  "net/http"
  "os"
)

func main() {
  port := os.Getenv("PORT")
  if port == "" {
      port = "8080"
  }
  http.HandleFunc("/v1/", func(w http.ResponseWriter, r *http.Request) {
      fmt.Fprintf(w, "{status: 'running'}")
  })
  log.Println("Pets REST API listening on port", port)
  if err := http.ListenAndServe(":"+port, nil); err != nil {
      log.Fatalf("Error launching Pets REST API server: %v", err)
  }
}
MAIN_V1

cat << 'DOCKER_V1' > Dockerfile
FROM gcr.io/distroless/base-debian12
WORKDIR /usr/src/app
COPY server .
CMD [ "/usr/src/app/server" ]
DOCKER_V1

go build -o server

gcloud artifacts repositories create my-repo \
    --repository-format=docker \
    --location=$REGION \
    --description="Docker repository for REST API" 2>/dev/null || true

gcloud builds submit --tag ${REGION}-docker.pkg.dev/$PROJECT_ID/my-repo/rest-api:0.1

gcloud run deploy rest-api \
  --image ${REGION}-docker.pkg.dev/$PROJECT_ID/my-repo/rest-api:0.1 \
  --region $REGION \
  --allow-unauthenticated \
  --max-instances=2

# Phase 2: Firestore Test Data Import
gcloud storage buckets create gs://$PROJECT_ID-customer --default-storage-class=standard --location=$REGION 2>/dev/null || true
gcloud storage cp -r gs://spls/gsp645/2019-10-06T20:10:37_43617 gs://$PROJECT_ID-customer/
gcloud beta firestore import gs://$PROJECT_ID-customer/2019-10-06T20:10:37_43617/

# Phase 3: Connected Service v0.2
cat << MAIN_V2 > main.go
package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"

	"cloud.google.com/go/firestore"
	"github.com/gorilla/handlers"
	"github.com/gorilla/mux"
	"google.golang.org/api/iterator"
)

var client *firestore.Client

func main() {
	var err error
	ctx := context.Background()
	client, err = firestore.NewClient(ctx, "$PROJECT_ID")
	if err != nil {
		log.Fatalf("Error initializing Cloud Firestore client: %v", err)
	}

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	r := mux.NewRouter()
	r.HandleFunc("/v1/", rootHandler)
	r.HandleFunc("/v1/customer/{id}", customerHandler)

	log.Println("Pets REST API listening on port", port)
	cors := handlers.CORS(
		handlers.AllowedHeaders([]string{"X-Requested-With", "Authorization", "Origin"}),
		handlers.AllowedOrigins([]string{"https://storage.googleapis.com"}),
		handlers.AllowedMethods([]string{"GET", "HEAD", "POST", "OPTIONS", "PATCH", "CONNECT"}),
	)

	if err := http.ListenAndServe(":"+port, cors(r)); err != nil {
		log.Fatalf("Error launching Pets REST API server: %v", err)
	}
}

func rootHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "{status: 'running'}")
}

func customerHandler(w http.ResponseWriter, r *http.Request) {
	id := mux.Vars(r)["id"]
	ctx := context.Background()
	customer, err := getCustomer(ctx, id)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		fmt.Fprintf(w, \`{"status": "fail", "data": '%s'}\`, err)
		return
	}
	if customer == nil {
		w.WriteHeader(http.StatusNotFound)
		msg := fmt.Sprintf("\`Customer \\"%s\\" not found\`", id)
		fmt.Fprintf(w, fmt.Sprintf(\`{"status": "fail", "data": {"title": %s}}\`, msg))
		return
	}
	amount, err := getAmounts(ctx, customer)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		fmt.Fprintf(w, \`{"status": "fail", "data": "Unable to fetch amounts: %s"}\`, err)
		return
	}
	data, err := json.Marshal(amount)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		fmt.Fprintf(w, \`{"status": "fail", "data": "Unable to fetch amounts: %s"}\`, err)
		return
	}
	fmt.Fprintf(w, fmt.Sprintf(\`{"status": "success", "data": %s}\`, data))
}

type Customer struct {
	Email string \`firestore:"email"\`
	ID    string \`firestore:"id"\`
	Name  string \`firestore:"name"\`
	Phone string \`firestore:"phone"\`
}

func getCustomer(ctx context.Context, id string) (*Customer, error) {
	query := client.Collection("customers").Where("id", "==", id)
	iter := query.Documents(ctx)

	var c Customer
	for {
		doc, err := iter.Next()
		if err == iterator.Done {
			break
		}
		if err != nil {
			return nil, err
		}
		err = doc.DataTo(&c)
		if err != nil {
			return nil, err
		}
	}
	return &c, nil
}

func getAmounts(ctx context.Context, c *Customer) (map[string]int64, error) {
	if c == nil {
		return map[string]int64{}, fmt.Errorf("Customer should be non-nil: %v", c)
	}
	result := map[string]int64{
		"proposed": 0,
		"approved": 0,
		"rejected": 0,
	}
	query := client.Collection(fmt.Sprintf("customers/%s/treatments", c.Email))
	if query == nil {
		return map[string]int64{}, fmt.Errorf("Query is nil: %v", c)
	}
	iter := query.Documents(ctx)
	for {
		doc, err := iter.Next()
		if err == iterator.Done {
			break
		}
		if err != nil {
			return nil, err
		}
		treatment := doc.Data()
		result[treatment["status"].(string)] += treatment["cost"].(int64)
	}
	return result, nil
}
MAIN_V2

go build -o server

gcloud builds submit --tag ${REGION}-docker.pkg.dev/$PROJECT_ID/my-repo/rest-api:0.2

gcloud run deploy rest-api \
  --image ${REGION}-docker.pkg.dev/$PROJECT_ID/my-repo/rest-api:0.2 \
  --region $REGION \
  --allow-unauthenticated \
  --max-instances=2

echo "Deployment completed successfully."
