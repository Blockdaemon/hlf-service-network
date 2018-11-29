#!/usr/bin/env python3
import os
import sys
from jinja2 import Environment, FileSystemLoader

l = FileSystemLoader('templates/')
e = Environment(loader=l, trim_blocks=True, lstrip_blocks=True)

sys.stdout.write(e.from_string(sys.stdin.read()).render(env=os.environ) + "\n")
