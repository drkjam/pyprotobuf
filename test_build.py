#!/usr/bin/python

import test
import _test
import pprint
import time

#import test_pb2

"""
buf     = _test.ENCODE()
print `buf`

pprint.pprint(_test.DECODE(buf))

t0 = time.time()
for i in range(100000):
    _test.DECODE(buf)
print i / (time.time() - t0)

msg = test_pb2.TestMessage()
t0 = time.time()
for i in range(1000):
    msg.ParseFromString(buf)
print i / (time.time() - t0)
"""

buf = file("srcgen/src/test.bin").read()
import pprint
print pprint.pprint(_test.DECODE(buf))
