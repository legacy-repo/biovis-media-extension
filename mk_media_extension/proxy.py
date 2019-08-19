# -*- coding:utf-8 -*-

import os
import json
import logging
import requests
from flask import current_app


class config:
    proxy_admin_url = current_app.config.get("PROXY_ADMIN_URL")
    reverse_proxy_url = current_app.config.get("REVERSE_PROXY_URL")


def pretty_json(obj):
    return json.dumps(obj, sort_keys=True, indent=2 * " ")


def handle_json_response(r, output=False):
    if r.ok:
        result = r.json()
        if output:
            print(pretty_json(result))
        return result
    else:
        print(r.text)


def error(message):
    raise RuntimeError(message)


class KongApi:
    def __init__(self, proxy_admin_url, reverse_proxy_url):
        self.proxy_admin_url = proxy_admin_url
        self.reverse_proxy_url = reverse_proxy_url
        self.form_header = {"Content-type": "application/x-www-form-urlencoded"}

    def get_api_url(self, path):
        return "%s%s" % (self.proxy_admin_url, path)

    def get(self, path, params=None):
        url = self.get_api_url(path)
        logging.debug("params: %s" % (pretty_json(params)))
        r = requests.get(url, params)
        if r.ok:
            return r
        else:
            error("GET %s with params: %s, Error %s: %s" % (url, pretty_json(params), r.status_code, r.text))

    def put(self, path, json=None, data=""):
        url = self.get_api_url(path)
        logging.debug("put data: %s" % (pretty_json(data)))
        if json:
            r = requests.put(url, json=json)
        else:
            r = requests.put(url, data=data)
        if r.ok:
            return r
        else:
            error("PUT %s with data: %s, Error %s: %s" % (url, pretty_json(data), r.status_code, r.text))

    def post(self, path, json=None, data=""):
        url = self.get_api_url(path)
        logging.debug("post data: %s" % (pretty_json(data)))
        if json:
            r = requests.post(url, json=json)
        else:
            r = requests.post(url, data=data, headers=self.form_header)
        if r.ok:
            return r
        else:
            error("POST %s with data: %s, Error %s: %s" % (url, pretty_json(data), r.status_code, r.text))

    def patch(self, path, json=None, data=""):
        url = self.get_api_url(path)
        logging.debug("patch data: %s" % (pretty_json(data)))
        if json:
            r = requests.patch(url, json=json)
        else:
            r = requests.patch(url, data=data, headers=self.form_header)
        if r.ok:
            return r
        else:
            error("PATCH %s with data: %s, Error %s: %s" % (url, pretty_json(data), r.status_code, r.text))

    def delete(self, path):
        url = self.get_api_url(path)
        r = requests.delete(url)
        if r.ok:
            return r
        else:
            error("DELETE %s Error %s: %s" % (url, r.status_code, r.text))

    def get_proxy_url(self, path):
        return os.path.join(self.reverse_proxy_url, path.strip("/"))


def context(config):
    def decorator(func):
        def wrapper(*args, **kw):
            kong = KongApi(config.proxy_admin_url, config.reverse_proxy_url)
            return func(kong, *args, **kw)
        return wrapper
    return decorator


@context(config)
def status(kong):
    r = kong.get("/status")
    print(pretty_json(r.json()))


@context(config)
def registry_service_route(kong, upstream_url, uuid_as_path):
    """Create Route Associated to a Specific Service.

    uuid_as_path: command md5 as a service name or route path.
    """
    # Clean old route and service.
    delete_service_route(uuid_as_path)

    json = {
        "url": upstream_url,
        "name": uuid_as_path
    }
    r = kong.post("/services", json=json)
    response = handle_json_response(r)
    service_id = response.get("id")
    if service_id:
        path = "/" + uuid_as_path
        json = {
            "paths": [path, ]
        }
        r = kong.post("/services/%s/routes" % service_id, json=json)
        route_id = handle_json_response(r).get("id")
        return kong.get_proxy_url(path) if route_id else False
    else:
        logging.debug("Error Message: %s" % response.get("message"))
        return False


@context(config)
def query_routes(kong, service_name):
    """Query Route Associated to a Specific Service by Path.
    """
    r = kong.get("/services/%s/routes" % service_name)
    return handle_json_response(r).get("data")


@context(config)
def query_service(kong, service_name):
    """Query a Specific Service by Path.
    """
    r = kong.get("/services/%s" % service_name)
    return handle_json_response(r)


@context(config)
def delete_route(kong, route_id):
    """Delete a route.
    """
    return kong.delete("/routes/%s" % route_id)


@context(config)
def delete_service(kong, service_name):
    """Delete a service.
    """
    return kong.delete("/services/%s" % service_name)


@context(config)
def delete_service_route(kong, uuid_as_path):
    """Delete Route and a Specific Service.
    """
    try:
        routes = query_routes(uuid_as_path)
        for route in routes:
            route_id = route.get("id")
            delete_route(route_id)
        delete_service(uuid_as_path)
        message = "success"
    except RuntimeError as err:
        message = str(err)
    return message

# Handle all routes
@context(config)
def list_routes(kong):
    """List all routes.
    """
    r = kong.get("/routes")
    return handle_json_response(r).get("data")


@context(config)
def delete_routes(kong):
    """Delete all routes.
    """
    routes = list_routes()
    for route in routes:
        route_id = route.get("id")
        delete_route(route_id)


# Handle all services
@context(config)
def list_services(kong):
    """List all services
    """
    r = kong.get("/services")
    return handle_json_response(r).get("data")


@context(config)
def delete_services(kong):
    """Delete all services
    """
    services = list_services()
    for service in services:
        service_id = service.get("id")
        delete_service(service_id)


@context(config)
def update_service(kong, upstream_url, uuid_as_path):
    json = {
        "url": upstream_url
    }
    kong.put("/services/%s" % uuid_as_path, json=json)
