#!/usr/bin/env bash

ARG1="$1"
ARG2="$2"

set -eu

if [ -z "ARG1" ]; then
  echo "Usage: $0 (up | down | stop | create | describe | zkStatus | pub | sub)"
  exit 1
fi

ACTION="$ARG1"
PROJECT_NAME="kafka-cluster-task"

if ! [[ "$ACTION" =~ ^(up|down|stop|create|describe|zkStatus|pub|sub)$ ]]; then
    echo "Unknown action $ACTION"
    echo "Usage: $0 (up | down | stop | create | describe | zkStatus | pub | sub)"
    exit 1
fi

# docker compose up the containers
if [ "$ACTION" = "up" ]; then
    docker-compose --project-name "$PROJECT_NAME" up
    exit 0
fi

# Stop up the containers
if [ "$ACTION" = "down" ]; then
    docker-compose --project-name "$PROJECT_NAME" down
    exit 0
fi

# Check ZooKeeper status
if [ "$ACTION" = "zkStatus" ]; then
    for i in 1 2 3; do
        zooKeeperNode="${PROJECT_NAME}_zookeeper-${i}_1"
        echo "****************"
        echo "$zooKeeperNode"
        docker exec -it "$zooKeeperNode" ./bin/zkServer.sh status
    done
    exit 0
fi

# Stop a single Kafka node to test failover
if [ "$ACTION" = "stop" ]; then
    node="$ARG2"
    if ! [[ "$node" =~ ^(1|2|3)$ ]]; then
        echo "Usage: $0 $ACTION (1 | 2 | 3)"
        exit 1
    fi
    node_name="kafka-${node}"
    echo "Stopping ${node_name}"
    docker-compose --project-name "$PROJECT_NAME" stop "$node_name"
    exit 0
fi

# The rest of the actions require a topic

# Get topic name
TOPIC="$ARG2"
if [ -z "$TOPIC" ]; then
    echo "Usage: $0 $ACTION TOPIC"
    exit 1
fi

# pub sub actions
if [ "$ACTION" = "create" ]; then
    echo "Creating topic \"$TOPIC\""
    docker run --rm -i --net=host \
        wurstmeister/kafka kafka-topics.sh \
        --create \
        --zookeeper localhost:2181 \
        --replication-factor 3 \
        --partitions 1 \
        --topic "$TOPIC"
elif [ "$ACTION" = "describe" ]; then
    docker run --rm -i --net=host \
        wurstmeister/kafka kafka-topics.sh \
        --describe \
        --zookeeper localhost:2181 \
        --topic "$TOPIC" \
        exit 0
elif [ "$ACTION" = "pub" ]; then
    echo "Type to publish to topic \"$TOPIC\""
    docker run --rm -i --net=host \
        wurstmeister/kafka kafka-console-producer.sh \
        --topic "$TOPIC" \
        --bootstrap-server localhost:8001
elif [ "$ACTION" = "sub" ]; then
    echo "Receiving messages from topic \"$TOPIC\""
    docker run --rm -i --net=host \
        wurstmeister/kafka kafka-console-consumer.sh \
        --topic "$TOPIC" \
        --from-beginning \
        --bootstrap-server localhost:8001
fi


