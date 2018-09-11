#!/usr/bin/env python3
import os
import sys
from jinja2 import Environment, FileSystemLoader

sys.stdout.write(Environment(loader=FileSystemLoader('templates/')).from_string(sys.stdin.read()).render(env=os.environ) + "\n")
