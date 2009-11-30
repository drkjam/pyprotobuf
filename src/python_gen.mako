<%
#!/usr/bin/env python

class CompileError(Exception):
    pass

DECIMAL_TYPES = [
    "double", 
    "float", 
]

INTEGER_TYPES = [
    "int32", 
    "int64",
    "uint32",  
    "uint64", 
    "sint32", 
    "sint64", 
    "fixed32", 
    "fixed64",
    "sfixed32",
    "sfixed64",
]

BOOL_TYPES = [
    "bool",
]

STRING_TYPES = [
    "string",
    "bytes",
]

def get_default(field):
    if field.fieldType in INTEGER_TYPES:
        if field.defaultValue:
            return int(field.defaultValue)
        else:
            return '0'
    elif field.fieldType in STRING_TYPES:
        if field.defaultValue:
            return "'%s'" % field.defaultValue
        else:
            return "''"
    elif field.fieldType in BOOL_TYPES:
        if field.defaultValue:
            if field.defaultValue == "true":
                return "True"
            elif field.defaultValue == "false":
                return False
            else:
                raise CompileError, "invalid value for bool %s" % field.defaultValue
        else:
            return 'False'
    elif field in FLOAT_TYPES:
        return '0.0'
    else:
        raise CompileError, "unknown field type: '%s'" % field.fieldType

def get_impl_type(field):
    if field.fieldType in INTEGER_TYPES:
        return 'int'
    elif field.fieldType in STRING_TYPES:
        return "str"
    elif field.fieldType in BOOL_TYPES:
        return 'bool'
    elif field in FLOAT_TYPES:
        return 'float'
    else:
        raise RuntimeError, "unknown field type: '%s'" % field.fieldType

%>

from cStringIO import StringIO
import struct

class _Msg(object):
    def _str(self, indent = 0):
        stream = StringIO()
        stream.write(self.PKG_NAME + "." + self.MSG_NAME + "(\n")
        for field, info in self.META:
            stream.write(4 * (indent + 1) * " ")
            stream.write(
                "%s = %r,\n" % (field, getattr(self, field))
            )

        stream.write(4 * indent * " ")
        stream.write(")\n")
        return stream.getvalue()

    def _gen_doc(self):
        def indent(s, depth = 1):
            stream.write("    " * depth)
            stream.write(s)
            
        stream = StringIO()
        stream.write(self.MSG_NAME + "\n")
        for attr, info in self.META:
            indent("%s: [%s/%s]" % (attr, info["DeclType"], info["ImplType"]))
        
    __doc__     = property(_gen_doc, None, None, "documentation")
    __str__ = _str
            
        
%for msg in messages:
class ${msg.messageName}(_Msg):
    PKG_NAME    = "${pkgName}"
    MSG_NAME    = "${msg.messageName}"
    def __init__(
        self,
    %for field in msg.fields:
        ${field.fieldName} = ${get_default(field)},
    %endfor
        ):
        """
        Message: ${msg.messageName}
        """
    %for field in msg.fields:
        self.${field.fieldName} = ${field.fieldName} 
    %endfor
        
    def _META_(self):
        return [
    %for field in msg.fields:
            (
                "${field.fieldName}" ,  {
                    "DeclType"  :   "${field.fieldType}",
                    "ImplType"  :   ${get_impl_type(field)},
                    "Default"   :   ${get_default(field)},
                    "Repeating" :   False,
                }
            ),
    %endfor
        ]
    
    META = property(_META_, None, None, "meta information")

        
            
%endfor
