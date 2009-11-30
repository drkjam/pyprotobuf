#include <Python.h>

static PyMethodDef module_methods[] = {
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
