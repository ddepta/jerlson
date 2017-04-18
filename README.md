Jerlson
=======

Jerlson is a JSON parser and builder developed in Erlang.


API
---

Jerlson API contains simply two functions, one for parsing and one for building JSON.
These functions have their file counterparts, to parse JSON from file and to stream JSON to file:

 * **jerlson:load** parses JSON given as Erlang binary or string,
 * **jerlson:load_file** parses JSON stored in file,
 * **jerlson:dump** converts Erlang term into JSON, the result is an Erlang binary,
 * **jerlson:dump_file** convets Erlang term into JSON and saves he result in specified file.

#### jerlson:load/1

Usage:

```Erlang
jerlson:load(<<"{\"name\": \"John\", \"age\": 26}">>)
```
where the JSON string is given as Erlang binary, or

```Erlang
jerlson:load("{\"name\": \"John\", \"age\": 26}")
```
where JSON string is given as Erlang string.

The result is the following Erlang term (map in this case):

```Erlang
#{<<"name">> => <<"John">>, <<"age">> => 26}
```

#### jerlson:dump/1

To be explained...

#### jerlson:load_file/2

To be explained...

#### jerlson:dump_file/2

To be explained...

Data mappings
-------------

The following tables contain detailed mappings between Erlang terms and JSON values and structures.

#### Data mappings while converting JSON structures and values to Erlang terms:

| JSON | Erlang term | Description |
|------|-------------|-------------|
| object | map | JSON objects are converted to Erlang maps |
| array | list | JSON arrays are converted to Erlang lists |
| string | binary | JSON strings are converted to Erlang binaries. |
| number | integer or float | JSON numbers are converted either to Erlang integers or to Erlang floats. |
| true | true (atom) | JSON value **true** is converted to Erlang atom **true**. |
| false | false (atom) | JSON value **false** is converted to Erlang atom **false** |
| null | null (atom) | JSON value **null** is converted to Erlang atom **null**. |

#### Data mappings while converting Erlang terms into JSON structures and values:

| Erlang term | JSON | Description |
|-------------|------|-------------|
| map | object | Erlang maps are converted to JSON objects. |
| list | array | Erlang lists are converted to JSON arrays. |
| binary or atom | string | Erlang binaries or atoms are converted to JSON strings. |
| integer | number | Erlang integers are converted to JSON numbers representing integers. |
| {value,precision} | number | Erlang tuple {value,precision} is converted to JSON number representing float value. |
| true (atom) | true | Erlang atom **true** is converted to JSON value **true**. |
| false (atom) | false | Erlang atom **false** is converted to JSON value **false**. |
| null (atom) | null | Erlang atom **null** is converted to JSON value **null**. |


Unicode
-------

Jerlson fully supports Unicode strings, but does not check if these strings contain correct Unicode
characters. If the file or binary given as input contains invalid Unicode characters, these will be propagated to output.

License
-------

Copyright (c) 2015-2017 Dariusz Depta Engos Software

This software is distributed under [MIT license](http://www.opensource.org/licenses/mit-license.php).
You can freely include this software in your comercial products.


Resources
---------

[www.json.org](http://www.json.org)

[www.erlang.org](https://www.erlang.org)
