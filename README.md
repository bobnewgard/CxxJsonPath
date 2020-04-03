## Introduction

The JsonPath namespace contains the classes JsonStr and JsonFind.
JsonStr is for building JSON strings programmatically.  JsonFind is for
isolating portions of a JSON string using a search path string.

### JsonPath Use Cases

#### Supported Use Cases

* Isolating the portion of a JSON string specified by a search path
* Building a JSON string programmatically

#### Unsupported Use Cases

* Parsing a JSON string into C++ datatypes

### JSON

JsonPath and the nomenclature used within are based on the information found
at [json.org](http://json.org/)

### JsonPath::JsonFind Class

This class stores two JSON values, a search context that contains JSON to
be searched and a search path that contains JSON specifying a particular
point in the JSON structure.

The result of applying a search path to a search context returns a JSON
value that represents the search target, also known as the context value.

The context value may be a JSON string, number, array, object, key,
true, false or null.

#### Search Path

A search path is valid JSON that specifies a particular JSON <b>value</b>
or <b>string</b>:<b>value</b> pair within a search context.

##### Searching within a JSON object

Paths for searching within an <b>object</b> take the form
{<b>string</b>:<b>value</b>}.  The <b>string</b> specifies the target
key.  The <b>value</b> specifies the target type and may be an empty
<b>object</b>, an empty <b>array</b>, <b>true</b> or <b>null</b>.
Other <b>value</b>s are unsupported.

With this restriction on <b>value</b>, the supported forms of search
within <b>object</b>s are:

+ {<b>string</b>:true} - find the non-<b>array</b>, non-<b>object</b>
  <b>value</b> at <b>string</b>
+ {<b>string</b>:{}} - find the <b>object</b> at <b>string</b>
+ {<b>string</b>:[]} - find the <b>array</b> at <b>string</b>
+ {<b>string</b>:null} - find the key <b>string</b>

##### Searching within a JSON array

Paths for searching within an <b>array</b> take the form
[<b>number</b>,<b>value</b>].  The <b>number</b> specifies an array index,
with the first index zero.  The <b>value</b> specifies the target type
and may be an empty <b>object</b>, an empty <b>array</b>, or <b>true</b>.
Other <b>value</b>s are unsupported.

With this restriction on <b>value</b>, the supported forms of search
within <b>array</b>s are:

+ [<b>number</b>, true] - find the non-<b>array</b>, non-<b>object</b>
  <b>value</b> at <b>array</b> position <b>number</b>.
+ [<b>number</b>, {}] - find the <b>object</b> at <b>array</b> position
  <b>number</b>.
+ [<b>number</b>, []] - find the <b>array</b> at <b>array</b> position
  <b>number</b>.

##### Example Searches

The example searches below operate on this JSON <b>object</b>:

    {
        "key01" : "str01",
        "key02" :
        [
            "str021",
            "str022"
        ],
        "key03" :
        {
            "key0301" : "str0301",
            "key0302" : {},
            "key0303" : []
        },
        "key04"  : 67,
        "key05"  : -67,
        "key06"  : -0.1,
        "key07"  : 0.5e7,
        "key08"  : 3.5e7,
        "key09"  : 33.5e-7,
        "key10"  : 0.5e77,
        "key11"  : 0.57,
        "key12" :
        [
            true,
            false,
            null,
            5,
            "str1205",
            {
                "key120601" : "str120601",
                "key120602" : "str120602" 
            },
            [
                "str120701",
                "str120702",
                "str120703",
                [
                    "str12070401",
                    "str12070402",
                    "str12070403" 
                ]
            ]
        ]
    };

| Search Path                         | Search Target                      |
|-------------------------------------|------------------------------------|
| {"key01":true}                      | "str01"                            |
| {"key03":{"key0301":true}}          | "str0301"                          |
| {"key02":[1,true]}                  | "str022"                           |
| {"key12":[2,true]}                  | null                               |
| {"key05":true}                      | -67                                |
| {"key12":[5,{"key120602":true}]}    | "str120602"                        |
| {"key12":[6,[2,true]]}              | "str120703"                        |
| {"key12":[5,{}]}                    | {"key120601":...:"str120602"}      |
| {"key12":[6,[]]}                    | ["str120701",...,"str12070403"]]   |
| {"key12":[]}                        | [true,...,"str12070403"]]]         |
| {"key12":[6,[3,[1,true]]]}          | "str12070402"                      |
| {"key01":null}                      | "key01":"str01"                    |

### JsonPath::JsonStr Class

This class may be used to build JSON from strings containing JSON
snippets. All JsonStr methods operate on a string attribute declared
within the JsonStr class.

The string attribute is initialized to an empty string by
the constructor. Characters are appended to the string by the add\_\*()
methods. The string is accessed using the get\_str() method.

### Using JsonFind and JsonStr Together

Starting with a string containing a search context,

1. Use JsonStr::add\_\* to build a search path
1. Use JsonStr::get\_str() to get a string containing the search path
1. Use JsonFind::set\_search\_context() to specify the search context
1. Use JsonFind::set\_search\_path() to specify the search path
1. Use JsonFind::find() to isolate a context value using the search path
1. Use JsonFind::get\_context\_string() to get the context value

At this point, the context value may be used as new search context, or
may be used as-is, or may be used with JsonStr methods to create a new
JSON string.


          +-----------------+                          +----------------------+
          | JsonStr         |                          | JsonFind             |
          |                 |                          |                      |
    +---->| add_obj_bgn()   +--> JsonStr::get_str() -->| set_search_context() |
    |  i  | add_obj_end()   |                          |                      |
    |  t  | add_arr_bgn()   |                          |                      |
    |  e  | add_arr_end()   |                          |                      |
    |  r  | add_key(string) |                          |                      |
    |  a  | add_val(string) |                          |                      |
    |  t  | add_str(string) +--> JsonStr::get_str() -->| set_search_path()    |
    |  e  | add_num(string) |                          |                      |
    +-----+ add_nul()       |                          |                      |
          | add_tru()       |                          |                      |
          | add_fal()       |                          |       find()         |
          +-----------------+                          +---------+------------+
                                                                 |
                                                                 v
                                                     JsonFind::get_context_string()

### Unit Tests

The unit tests check various paths on a single JSON string.

## Validated Environments

The unit tests have been run successfully in the following environment(s)

| Linux                | libc  | gcc   |  make  | bash   | flex   | bison |
|----------------------|-------|-------|--------|--------|--------|-------|
| Debian 4.19.67-amd64 | 2.28  | 8.3.0 |  4.2.1 | 5.0    | 2.6.4  | 3.3.2 |

## Other Dependencies

Dependencies beyond those listed above under the Validated Environments heading are the project

* CxxMsg (https://github.com/bobnewgard/CxxMsg)

## Installation

1. Check that the components shown in the "Validated Environments"
   section are present
1. Execute "make" for hints about available targets
1. Execute "make lib" to build the CxxJsonPath library
    * Note that CxxMsg will be cloned and built in the temporary
      directory "tmp"
1. Execute "make run-test2" to run the test

## Issues

Issues are tracked at TBD

## Pull Requests

Pull requests are found at TBD

## License

### License For Code

The code in this project is licensed under the Lesser GPLv3

### License for This Project Summary

This work is licensed under the Creative Commons Attribution-ShareAlike 3.0
Unported License. To view a copy of this license, visit
http://creativecommons.org/licenses/by-sa/3.0/.
