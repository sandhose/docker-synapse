#!/usr/local/bin/python

import jinja2
import os
import glob
import yaml


def merge(source, destination):
    for key, value in source.items():
        if isinstance(value, dict):
            # get node or create one
            node = destination.setdefault(key, {})
            merge(value, node)
        else:
            destination[key] = value

    return destination


def compile(name):
    output_file = "/tmp/%s" % name
    config = {}
    config_files = glob.glob("/conf/%s.d/*" % name)

    for file in sorted(config_files):
        with open(file, "r") as stream:
            rendered = jinja2.Template(stream.read()).render(**environ)
            part = yaml.load(rendered)
            config = merge(part, config)

    with open(output_file, "w") as output:
        yaml.dump(config, output)

    return output_file


# Prepare the configuration
environ = os.environ.copy()
environ['compile'] = compile

homeserver_yaml = compile('homeserver.yaml')

args = ["python", "-m", "synapse.app.homeserver"]
os.execv("/usr/local/bin/python", args + ["--config-path", homeserver_yaml])
