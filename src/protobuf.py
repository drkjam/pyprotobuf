

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
    
    __str__ = _str
            
        
class TestMessage(_Msg):
    PKG_NAME    = "Messages"
    MSG_NAME    = "TestMessage"
    def __init__(
        self,
        name = '',
        id = 0,
        email = 'chaitan@nullcube.com',
        chaitan = False,
        ):
        """
        Message: TestMessage
        """
        self.name = name 
        self.id = id 
        self.email = email 
        self.chaitan = chaitan 
        
    def _META_(self):
        return [
            (
                "name" ,  {
                    "DeclType"  :   "string",
                    "ImplType"  :   str,
                    "Default"   :   '',
                    "Repeating" :   False,
                }
            ),
            (
                "id" ,  {
                    "DeclType"  :   "int32",
                    "ImplType"  :   int,
                    "Default"   :   0,
                    "Repeating" :   False,
                }
            ),
            (
                "email" ,  {
                    "DeclType"  :   "string",
                    "ImplType"  :   str,
                    "Default"   :   'chaitan@nullcube.com',
                    "Repeating" :   False,
                }
            ),
            (
                "chaitan" ,  {
                    "DeclType"  :   "bool",
                    "ImplType"  :   bool,
                    "Default"   :   False,
                    "Repeating" :   False,
                }
            ),
        ]
    
    META = property(_META_, None, None, "meta information")
            
class Empty(_Msg):
    PKG_NAME    = "Messages"
    MSG_NAME    = "Empty"
    def __init__(
        self,
        ):
        """
        Message: Empty
        """
        
    def _META_(self):
        return [
        ]
    
    META = property(_META_, None, None, "meta information")
            
