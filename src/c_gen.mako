#include <Python.h>
#include <stdlib.h>
#include <src/test.pb-c.h>
#include <sys/types.h>

static PyObject *py_module = NULL;

PyObject *pypb_get_msg_descriptors()
{
    return NULL;
}

PyObject *pypb_decode_field(ProtobufCMessage *msg, ProtobufCFieldDescriptor descr)
{
    PyObject *field = NULL;
    
    char *c = &(((char*)msg)[descr.offset]);  
    switch(descr.label)
    {
        case PROTOBUF_C_LABEL_REQUIRED:
        case PROTOBUF_C_LABEL_OPTIONAL:
        {
            switch(descr.type)
            {
                case PROTOBUF_C_TYPE_UINT32:
                {
                    u_int32_t i = *((u_int32_t*)c);
                    return PyLong_FromLongLong(i);
                }
                case PROTOBUF_C_TYPE_UINT64:
                { 
                    u_int64_t i = *((u_int64_t*)c);
                    return PyLong_FromUnsignedLongLong(i);
                }
                case PROTOBUF_C_TYPE_SINT64:
                case PROTOBUF_C_TYPE_INT64:
                case PROTOBUF_C_TYPE_SFIXED64:
                case PROTOBUF_C_TYPE_FIXED64:
                {
                    u_int64_t i = *((u_int64_t*)c);
                    return PyLong_FromLongLong(i);
                }
                
                case PROTOBUF_C_TYPE_INT32:
                case PROTOBUF_C_TYPE_SINT32:
                case PROTOBUF_C_TYPE_SFIXED32:
                case PROTOBUF_C_TYPE_FIXED32:
                { 
                    u_int32_t i = *((u_int32_t*)c);
                    return PyInt_FromLong(i);
                }
                case PROTOBUF_C_TYPE_BOOL:
                {
                    int i = *((int*)c);
                    return PyBool_FromLong(i);
                }
                case PROTOBUF_C_TYPE_STRING:
                {
                    return PyString_FromString(c);
                }
                default:
                {
                    PyErr_SetString(PyExc_RuntimeError, "unknown type!");
                }
            }
        }
        case PROTOBUF_C_LABEL_REPEATED:
        {
            return PyString_FromString("Not supported yet!!");
        }
        default:
        {
            PyErr_SetString(PyExc_RuntimeError, "unknown descriptor label");
            goto err;
        }
    }
    err:
        Py_XDECREF(field);
        return NULL;
}

PyObject *pypb_ENCODE(PyObject *self, PyObject *args)
{
    size_t size;
    char *buf;
    PyObject *ret = NULL;
    TestMessage msg;

    test_message__init(&msg);

    size = test_message__get_packed_size(&msg);

    buf = malloc(size);
    if(!buf)
    {
        PyErr_SetString(PyExc_MemoryError, "malloc failed");
        return NULL;
    }
    test_message__pack(&msg, buf);
    ret = PyString_FromStringAndSize(buf, size);
    free(buf);
    return ret;
}


PyObject *pypb_DECODE(PyObject *self, PyObject *args)
{
    char *buf;
    size_t size;

    PyObject *ret = NULL;
    PyObject *msg = NULL;
    PyObject *fields = NULL;

    ProtobufCMessage *cmsg = NULL;

    if(!PyArg_ParseTuple(args, "z#", &buf, &size))
    {
        return NULL;
    }

    cmsg = protobuf_c_message_unpack(
        &test_message__descriptor, 
        NULL, 
        size, 
        buf
    );

    if(!cmsg)
    {
        PyErr_SetString(PyExc_RuntimeError, "decode failed - invalid buffer?");
        goto err;
    }

    msg = PyDict_New();
    if(!msg)
    {
        return NULL;
    }
    else
    {
        %for field in ["name", "short_name", "c_name", "package_name"]:
        {
            PyObject *o = PyString_FromString(test_message__descriptor.${field});
            if(!o)
            {
                goto err;
            }

            int error = PyDict_SetItemString(msg, "${field}", o);
            Py_DECREF(o);

            if(error)
            {
                goto err;
            }
        }
        %endfor
        
        fields = PyDict_New();

        if(!fields)
        {
            goto err;
        }
        
        if(PyDict_SetItemString(msg, "fields", fields))
        {
            Py_DECREF(fields);
            goto err;
        }

        unsigned i = 0;
        for(i = 0; i < test_message__descriptor.n_fields; i++)
        {
            PyObject *field = pypb_decode_field(cmsg, test_message__descriptor.fields[i]);
            if(!field)
            {
                goto err;
            }
            int error = PyDict_SetItemString(fields, test_message__descriptor.fields[i].name, field);
            Py_DECREF(field);
            if(error)
            {
                goto err;
            }
        }
    }

    return msg;

    err:
        if(cmsg)
        {
            protobuf_c_message_free_unpacked(cmsg, NULL);
        }
        Py_XDECREF(msg);
        return NULL;
        
}

static PyMethodDef module_methods[] = {
    {"ENCODE",  pypb_ENCODE, METH_VARARGS, "Encode a message"},
    {"DECODE",  pypb_DECODE, METH_VARARGS, "Decode a message"},
    {NULL, NULL, 0, NULL}        /* Sentinel */
};

%for message in messages:
/* DECODE ${message.messageName} */
%endfor

PyMODINIT_FUNC
init_${module}()
{
    PyObject *m = Py_InitModule("_${module}", module_methods); 
}
