#!/usr/bin/python

env = Environment(
    CPPPATH = [
        "/usr/include/python2.6", 
        "srcgen"
    ],
    CFLAGS = "-g",
)

PROTO = "src/test.proto"

env.Command(
    [
        'srcgen/src/test.bin', 
    ], 
    PROTO,
    'protoc %s -o srcgen/src/test.bin' % PROTO,
)


desc = env.Command(
    [
        'srcgen/src/test.pb.cc', 
    ],
    PROTO,
    'protoc $SOURCE --cpp_out srcgen',
)

pythongen = env.Command(
    [
        "test.py", 
    ],
    [ 
        PROTO,
        'src/python_gen.mako'
    ],
    'PYTHONPATH=$PYTHONPATH:src bin/compiler $SOURCES $TARGET',
)

cgen = env.Command(
    [
        'srcgen/src/python_test_gen.cc'
    ],
    [ 
        PROTO,
        'src/c_gen.mako'
    ],
    'PYTHONPATH=$PYTHONPATH:src bin/compiler $SOURCES $TARGET',
)

env.SharedLibrary(
    '_test',
    [
        desc,
        cgen,
    ],
    LIBS = ['protobuf'],
    SHLIBPREFIX=''
)

