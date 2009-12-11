#include <Python.h>
#include <stdlib.h>
#include <iostream>
#include <fstream>
#include <src/test.pb.h>
#include <sys/types.h>
#include <google/protobuf/descriptor.pb.h>
#include <google/protobuf/descriptor.h>

using namespace::google;

PyObject* _pypb_DECODE(const protobuf::Message *msg);

class AutoDecref 
{
    public:
        AutoDecref(PyObject *p);
        ~AutoDecref();
        PyObject *ok();
        PyObject *ptr;
};

AutoDecref::AutoDecref(PyObject *p)
{
    this->ptr = p;
}

AutoDecref::~AutoDecref()
{
    Py_XDECREF(ptr);
}

PyObject* AutoDecref::ok()
{
    PyObject *p = this->ptr;
    this->ptr = NULL;
    return p;
}


PyObject *pypb_decode_simple_type(const protobuf::Message *msg, const protobuf::FieldDescriptor *field_descriptor)
{
    
    const protobuf::Reflection *reflection = msg->GetReflection();
    if(field_descriptor->label() == protobuf::FieldDescriptor::LABEL_OPTIONAL)
    {
        if(!reflection->HasField(*msg, field_descriptor))
        {
            Py_RETURN_NONE;
        }
    }
    switch(field_descriptor->cpp_type())
    {
        case protobuf::FieldDescriptor::CPPTYPE_INT32:
        {
            protobuf::int32 i = reflection->GetInt32(*msg, field_descriptor);
            return PyLong_FromLong(i);
        }
        case protobuf::FieldDescriptor::CPPTYPE_INT64:
        {
            protobuf::int64 i = reflection->GetInt64(*msg, field_descriptor);
            return PyLong_FromLongLong(i);
        }
        case protobuf::FieldDescriptor::CPPTYPE_UINT32:
        {
            
            protobuf::uint32 i = reflection->GetUInt32(*msg, field_descriptor);
            return PyLong_FromLongLong(i);
        }
        case protobuf::FieldDescriptor::CPPTYPE_UINT64:
        {
            protobuf::uint64 i = reflection->GetUInt64(*msg, field_descriptor);
            return PyLong_FromUnsignedLongLong(i);
        }
        case protobuf::FieldDescriptor::CPPTYPE_DOUBLE:
        {
            double d = reflection->GetDouble(*msg, field_descriptor);
            return PyFloat_FromDouble(d);
        }
        case protobuf::FieldDescriptor::CPPTYPE_FLOAT:
        {
            float f = reflection->GetFloat(*msg, field_descriptor);
            return PyFloat_FromDouble(f);
        }
        case protobuf::FieldDescriptor::CPPTYPE_BOOL:
        {
            bool b = reflection->GetBool(*msg, field_descriptor);
            if(b)
            {
                return PyBool_FromLong(1);
            }
            else
            {
                return PyBool_FromLong(0);
            }
        }
        case protobuf::FieldDescriptor::CPPTYPE_ENUM:
        {
            return PyString_FromString("ENUM - FIXME");   
        }
        case protobuf::FieldDescriptor::CPPTYPE_STRING:
        {
            const std::string &s = reflection->GetStringReference(*msg, field_descriptor, NULL);
            return PyString_FromString(s.c_str());
        }
        case protobuf::FieldDescriptor::CPPTYPE_MESSAGE:
        {
            return PyString_FromString("Message Here - FIXME!");   
        }
        default:
            PyErr_SetString(PyExc_RuntimeError, "unhandled type in decode");
            return NULL;
    }
    return NULL;
}

bool pypb_decode_field(PyObject *dct, const protobuf::Message *msg, int fieldIndex)
{
    const protobuf::Descriptor *descriptor = NULL; 
    const protobuf::FieldDescriptor *field_descriptor = NULL;

    descriptor = msg->GetDescriptor();
    field_descriptor = descriptor->field(fieldIndex);

    const char *field_name = field_descriptor->name().c_str();
    switch(field_descriptor->label())
    {
        case protobuf::FieldDescriptor::LABEL_OPTIONAL:
        case protobuf::FieldDescriptor::LABEL_REQUIRED:
        {
            PyObject *field_value = pypb_decode_simple_type(msg, field_descriptor);
            if(!field_value)
            {
                return false;
            }
            else
            {
                int fail = PyDict_SetItemString(dct, field_name, field_value);
                Py_DECREF(field_value);
                if(fail)
                {
                    return false;
                }
            }
            return true;
        }
        case protobuf::FieldDescriptor::LABEL_REPEATED:
        {
            PyObject *lst = PyList_New(0);
            const protobuf::Reflection *reflection = msg->GetReflection();

            if(!lst)
            {
                return false;
            }
            
            int failed = PyDict_SetItemString(dct, field_descriptor->name().c_str(), lst);
            Py_DECREF(lst);
            if(failed)
            {
                return false;
            }
            int size =  reflection->FieldSize(*msg, field_descriptor);
            PyObject *item = NULL;

            for(int i = 0; i < size; i++)
            {
                switch(field_descriptor->cpp_type())
                {
                    case protobuf::FieldDescriptor::CPPTYPE_INT32:
                    {
                        protobuf::int32 i = reflection->GetRepeatedInt32(*msg, field_descriptor, i);
                        item = PyLong_FromLong(i);
                        break;
                    }
                    case protobuf::FieldDescriptor::CPPTYPE_INT64:
                    {
                        protobuf::int64 i = reflection->GetRepeatedInt64(*msg, field_descriptor, i);
                        item = PyLong_FromLongLong(i);
                        break;
                    }
                    case protobuf::FieldDescriptor::CPPTYPE_UINT32:
                    {
                        
                        protobuf::uint32 i = reflection->GetRepeatedUInt32(*msg, field_descriptor, i);
                        item = PyLong_FromLongLong(i);
                        break;
                    }
                    case protobuf::FieldDescriptor::CPPTYPE_UINT64:
                    {
                        protobuf::uint64 i = reflection->GetRepeatedUInt64(*msg, field_descriptor, i);
                        item = PyLong_FromUnsignedLongLong(i);
                        break;
                    }
                    case protobuf::FieldDescriptor::CPPTYPE_DOUBLE:
                    {
                        double d = reflection->GetRepeatedDouble(*msg, field_descriptor, i);
                        item = PyFloat_FromDouble(d);
                        break;
                    }
                    case protobuf::FieldDescriptor::CPPTYPE_FLOAT:
                    {
                        float f = reflection->GetRepeatedDouble(*msg, field_descriptor, i);
                        item = PyFloat_FromDouble(f);
                        break;
                    }
                    case protobuf::FieldDescriptor::CPPTYPE_BOOL:
                    {
                        bool b = reflection->GetRepeatedBool(*msg, field_descriptor, i);
                        if(b)
                        {
                            item = PyBool_FromLong(1);
                        }
                        else
                        {
                            item = PyBool_FromLong(0);
                        }
                        break;
                    }
                    case protobuf::FieldDescriptor::CPPTYPE_ENUM:
                    {
                        item = PyString_FromString("ENUM - FIXME");   
                        break;
                    }
                    case protobuf::FieldDescriptor::CPPTYPE_STRING:
                    {
                        const std::string &s = reflection->GetRepeatedString(*msg, field_descriptor, i);
                        item = PyString_FromString(s.c_str());
                        break;
                    }
                    case protobuf::FieldDescriptor::CPPTYPE_MESSAGE:
                    {
                        item = PyDict_New();
                        const protobuf::Message &submsg = reflection->GetRepeatedMessage(*msg, field_descriptor, i);
                        item = _pypb_DECODE(&submsg);
                        break;
                    }
                    default:
                        PyErr_SetString(PyExc_RuntimeError, "unhandled type in decode");
                        return NULL;
                }
                if(!item)
                {
                    return false;
                }
                PyList_Append(lst, item);
            }
            return true;
        }
        default:
        {
            PyErr_SetString(PyExc_RuntimeError, "unhandled label in decode");
            return false;
        }
    }
}

PyObject* _pypb_DECODE(const protobuf::Message *msg)
{

    const protobuf::Descriptor *descriptor = msg->GetDescriptor();
    PyObject *dct = PyDict_New();
    if(!dct)
    {
        return NULL;
    }
    
    AutoDecref ret(dct);

    for(int i = 0; i < descriptor->field_count(); i++)
    {
        if(!pypb_decode_field(dct, msg, i))
        {
            return NULL;
        }
    }
    return ret.ok();
}


PyObject *pypb_ENCODE(PyObject *self, PyObject *args)
{
    Py_RETURN_NONE;
}


PyObject *pypb_DECODE(PyObject *self, PyObject *args)
{
    char *buf;
    size_t size;

    PyObject *ret = NULL;
    PyObject *pymsg = NULL;

    protobuf::FileDescriptorSet msg;

    if(!PyArg_ParseTuple(args, "z#", &buf, &size))
    {
        return NULL;
    }

    std::string istring(buf);
    if(msg.ParseFromString(istring) == false)
    {
        PyErr_SetString(PyExc_RuntimeError, "decode failed!!");
        return NULL;
    } 

    pymsg = _pypb_DECODE(&msg);
    return pymsg;
        
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
