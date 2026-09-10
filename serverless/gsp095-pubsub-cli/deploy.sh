#!/bin/bash
set -e

gcloud pubsub topics create myTopic
gcloud pubsub subscriptions create --topic myTopic mySubscription

gcloud pubsub topics publish myTopic --message "Hello Avinash"
gcloud pubsub subscriptions pull mySubscription --auto-ack
