#!/usr/bin/python

from pyparsing import   \
    Literal,            \
    Word,               \
    alphas,             \
    nums,               \
    alphanums,          \
    ZeroOrMore,         \
    Group,              \
    Optional,           \
    Forward,            \
    quotedString,       \
    removeQuotes,       \
    Combine

fieldType = (
        Literal("double")   | 
        Literal("float")    | 
        Literal("int32")    | 
        Literal("int64")    | 
        Literal("uint32")   | 
        Literal("uint64")   | 
        Literal("sint32")   | 
        Literal("sint64")   | 
        Literal("fixed32")  | 
        Literal("fixed64")  | 
        Literal("sfixed32") | 
        Literal("sfixed64") | 
        Literal("bool")     | 
        Literal("string")   | 
        Literal("bytes")  
).setResultsName("fieldType")

messageRecursive = Forward() 

msgName = Word(alphas).setResultsName("messageName")

fieldName = Word(alphas).setResultsName("fieldName")

default =   Literal("[")        + \
            Literal("default")  + \
            quotedString.setParseAction(
                removeQuotes
            ).setResultsName("defaultValue") +  \
            Literal("]")

fieldUsage = (
    Literal("required")     | \
    Literal("optional")
).setResultsName("fieldUsage")

tag = Word(nums).setResultsName("tag")

field = Group(
    fieldUsage              + \
    fieldType               + \
    fieldName               + \
    Literal("=")            + \
    tag                     + \
    Optional(default)       + \
    Literal(";")
)

message = Group(
    Literal("message")      + \
    msgName                 + \
    Literal("{")            + \
    ZeroOrMore((field) | messageRecursive).setResultsName("fields") + \
    Literal("}")
)

messageRecursive << message

messageList = ZeroOrMore(message).setResultsName("messages")

def parse(data):    
    return messageList.parseString(data).messages
