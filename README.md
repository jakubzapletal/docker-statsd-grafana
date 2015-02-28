# StatsD + Graphite + Grafana dockerfile

This image contains a default configuration of original [Etsy StatsD](https://github.com/etsy/statsd/) based on [jakubzapletal/ubuntu:14.04.1](https://github.com/jakubzapletal/docker-ubuntu/tree/14.04.1)
and comes bundled with [Grafana](http://grafana.org/).

## Using the Docker Hub
 
This image is published under [Jakub Zapletal's repository on the Docker Hub](https://hub.docker.com/u/jakubzapletal/) and all you need as a prerequisite is having Docker installed on your machine.
The container exposes the following ports:

- `80`: Grafana web interface (`http://localhost:80`)
- `8125/udp`: StatsD port
- `8126`: StatsD admin TCP interface

There are the prepared volumes:

- `/opt/graphite/storage/whisper`: Saving data
- `/src/dashboards`: Expects a file `default.json` which contains pre-configured dashboard for Grafana

To start a container with this image you just need to run the following command:

```bash
docker run -d -p 80:80 -p 8125:8125/udp -p 8126:8126 -v <LOCAL_PATH>:/opt/graphite/storage/whisper -v <LOCAL_PATH>:/src/dashboards --name statsd jakubzapletal/statsd
```

If you already have services running on your host that are using any of these ports, you may wish to map the container
ports to whatever you want by changing left side number in the `-p` parameters. Find more details about mapping ports
in the [Docker documentation](http://docs.docker.com/userguide/dockerlinks/).

## Building the image yourself

The Dockerfile and supporting configuration files are available in the Github repository. This comes specially handy if you want to change any configuration or simply if you want to know how the image was built.
