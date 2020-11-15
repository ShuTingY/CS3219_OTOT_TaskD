This repo is for my AY2020/21 S1 CS3219 OTOT task D

# Kafka Cluster Failover Demo

Kafka cluster with Zookeeper ensemble, deployed in Docker.

## Content

This project contains a docker-compose.yml file for creating a 3-node Kafka cluster, managed by a 3-node ZooKeeper ensemble, both with failover.

This project also includes a bash script for the ease of execution of common procedures.

## Steps to test Kafka broker failover

### Make the helper bash script executable

The helper shell script avoid us from typing long Docker commands.

### Start the containers

`bash runscript.sh up`

This will spin up both the 3-node ZooKeeper ensemble and 3-node Kafka cluster.

The ZooKeeper servers are reachable at host ports 2181, 2182, and 2183. The Kafka brokers are reachable at host ports 8001, 8002, and 8003.

### (FYI:View ZooKeeper Ensemble status )

To view the ZooKeeper ensemble status, run:

`bash runscript.sh  zkStatus`


This should indicate which instance is the leader.


### Create a topic

To create a topic named `channel`, open another terminal window and type:

`bash runscript.sh create channel`

You can also create topics other than `channel` by changing the topic name in the command.

### Subscribe to the topic

To subscribe to the topic we have just created, run:

`bash runscript.sh sub channel`

You can also subscribe to another topic.

You can run multiple subscribers subscribing to the same or different topics.

### Publish to the topic

To publish to the `channel` topic, open another terminal window and type:

`bash runscript.sh pub channel`

Then type a message and press Enter.

If you have the subscriber from the previous step open in another terminal window, you should see the message there.

Similarly, you can run multiple publishers publishing to the same or different topics.

### Describe the topic

To view information related to the topic, open another terminal window and type:

`bash runscript.sh  describe channel`

Among other things, the returned information includes the leader broker of the topic (which should be a number from 1 to 3)

### Kill the leader broker of the topic

To verify that the topic can still work properly even after its leader broker dies, let's kill its leader broker.

Without closing the subscriber and publisher, run:

`bash runscript.sh  stop BROKER_ID`

Where `BROKER_ID` is the ID of the leader broker we discovered from the last step.

For example, if the output of the previous step shows that 2 is the leader, the leader broker ID is 2. To kill it, we should run:

`bash runscript.sh stop 2`

### Test that the topic still works

Now, run `bash runscript.sh describe events` again to verify that a new leader has been elected for the topic.

you may still publish to the topic. The subscribers should still be able to receive the messages.

### Stop and remove the containers

`bash runscript.sh down`
