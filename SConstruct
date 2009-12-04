#!/usr/bin/python

env = Environment(
    CPPPATH = [
        "/usr/include/python2.6", 
        "srcgen"
    ],
    CFLAGS = "-g",
)

def Binding(name):
    protof = "src/%s.proto" % name
    env.Command(
        [
            'srcgen/src/%s.pb-c.c' % name, 
            'srcgen/src/%s.pb-c.h' % name,
        ], 
        protof,
        'protoc-c $SOURCE  --c_out srcgen',
    )
    pythongen = env.Command(
        [
            "%s.py" % name, 
        ],
        [ 
            protof,
            'src/python_gen.mako'
        ],
        'PYTHONPATH=$PYTHONPATH:src bin/compiler $SOURCES $TARGET',
    )

    cgen = env.Command(
        [
            'srcgen/src/python_%s_gen.c' % name, 
        ],
        [ 
            protof,
            'src/c_gen.mako'
        ],
        'PYTHONPATH=$PYTHONPATH:src bin/compiler $SOURCES $TARGET',
    )

    env.SharedLibrary(
        '_%s' % name, 
        [
            cgen,
            'srcgen/src/%s.pb-c.c' % name,
        ],
        LIBS = ['protobuf-c'],
        SHLIBPREFIX=''
    )

Binding("test")
