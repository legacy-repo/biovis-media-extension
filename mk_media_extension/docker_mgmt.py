# -*- coding:utf-8 -*-
from __future__ import unicode_literals

import logging
import requests
import docker


class Docker:
    def __init__(self, base_url='unix://var/run/docker.sock'):
        self.logger = logging.getLogger('choppy-media-extension.docker_mgmt.Docker')
        self.base_url = base_url
        self.client = docker.DockerClient(base_url=base_url)

    def run_docker(self, image_name, volume_dict, ports, **kwargs):
        """
        Run a container.

        :param: image_name: docker image.
        :type: image_name: str
        :param: volume_dict: host path as key and container path as value.
        :type: volume_dict: dict

        :return: None
        """
        self._exist_docker()
        volumes = {volume: {'bind': mounts, 'mode': 'ro'}
                   for volume, mounts in volume_dict.items()}
        try:
            labels = {"choppy_report_plugin": image_name}
            container = self.client.containers.run(image_name,
                                                   auto_remove=True,
                                                   labels=labels,
                                                   detach=True,
                                                   ports=ports,
                                                   volumes=volumes,
                                                   **kwargs)
            self.logger.debug(container.logs())
            self.logger.info('Launch %s successfully.' % image_name)
            return container
        except docker.errors.ImageNotFound:
            self.logger.error('No such image: %s' % image_name)
            return None
        except docker.errors.APIError as err:
            self.logger.error('Unknown error: %s' % str(err))
            return None

    def get_docker(self, container_id):
        self._exist_docker()
        try:
            container = self.client.containers.get(container_id)
            return container
        except docker.errors.NotFound:
            self.logger.error('No such container: %s' % container_id)
        except docker.errors.APIError as err:
            self.logger.error('Unknown error: %s' % str(err))
        finally:
            return None

    def restart_docker(self, container_id):
        self._exist_docker()
        container = self.get(container_id)
        if container:
            self.logger.info('Restart the container: %s' % container_id)
            try:
                container.restart()
            except docker.errors.APIError as err:
                self.logger.error('Unknown error: %s' % str(err))

    def stop_docker(self, container_id):
        self._exist_docker()
        container = self.get(container_id)
        if container:
            self.logger.info('Stop the container: %s' % container_id)
            try:
                container.stop()
            except docker.errors.APIError as err:
                self.logger.error('Unknown error: %s' % str(err))

    def clean_containers(self, filters=dict()):
        self._exist_docker()
        try:
            filters.update({
                'label': 'choppy_report_plugin'
            })
            containers = self.client.containers.list(filters=filters)
            for container in containers:
                container.remove(force=True)
        except (docker.errors.APIError, Exception) as err:
            self.logger.critical("Clean Containers: %s" % str(err))

    def _exist_docker(self):
        """
        Test whether docker daemon is running.
        """
        try:
            self.client.ping()
        except requests.exceptions.ConnectionError:
            raise Exception("Cannot connect to the Docker daemon."
                            " Is the docker daemon running?")
