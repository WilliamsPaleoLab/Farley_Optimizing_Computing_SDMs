__author__ = 'scottsfarley'

import json
import pprint

f = open("/Users/scottsfarley/documents/thesis-scripts/data/hierarchy.json", 'r')
hier = json.load(f)
pprint.pprint(hier)