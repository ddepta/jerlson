%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 
%% Copyright 2015-2017 Dariusz Depta Engos Software
%%
%% Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
%% documentation files (the "Software"), to deal in the Software without restriction, including without limitation
%% the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
%% and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
%%
%% The above copyright notice and this permission notice shall be included in all copies
%% or substantial portions of the Software.
%%
%% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
%% TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
%% THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
%% OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
%% DEALINGS IN THE SOFTWARE.
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-module(tests).

%% API
-export([run/0]).

%%%==================================================================================================================== 
%%% API                                  
%%%====================================================================================================================

%%---------------------------------------------------------------------------------------------------------------------
%% @doc
%% @end
%%
run() ->
  try
  	run_lexer_tests(),
  	run_parser_positive_tests(),
  	run_parser_negative_tests(),
  	run_dump_positive_test(),
  	run_dump_negative_test(),
  	io:format("SUCCESS: All tests passed.~n~n")
  catch
  	Error:Reason ->
  		io:format("ERROR: ~p:~p~n~n", [Error, Reason])
  end,
  halt(0).
%%---------------------------------------------------------------------------------------------------------------------

%%%====================================================================================================================
%%% Internal functions 
%%%====================================================================================================================

-define(DUMP(Input, Output), eq(Output, jerlson:dump(Input))).

%%---------------------------------------------------------------------------------------------------------------------
%% @doc
%% @end
%%
run_parser_positive_tests() ->
  {ok, #{}} = jerlson:load(<<"{}">>),
  {ok, #{}} = jerlson:load(<<" {  } ">>),
  {ok, <<"">>} = jerlson:load(<<$", $">>),
  {ok, <<"\t">>} = jerlson:load(<<$", $\\, $t, $">>),
  {ok, <<"name/ag e/    address">>} = jerlson:load(<<$", "name/", "ag e", $/, "    ", "address", $", 16#20>>),
  {ok, true} = jerlson:load(<<"true">>),
  {ok, false} = jerlson:load(<<"false">>),
  {ok, null} = jerlson:load(<<"null">>),
  {ok, 123} = jerlson:load(<<"123">>),
  {ok, 12.345}  = jerlson:load(<<"12.345">>),
  {ok, [true,false,null]} = jerlson:load(<<"[true  , false,  null]">>),
  {ok, <<224,161,149>>} = jerlson:load(<<"\"\\u0855\"">>),
  {ok, <<224,161,159>>} = jerlson:load(<<"\"\\u085f\"">>),
  {ok, <<"ala ma kota">>} = jerlson:load(<<$", "ala ma kota", $">>),
  {ok, #{<<"name">> := <<"John">>, <<"age">> := 46}} = jerlson:load(<<"{\"name\" : \"John\", \"age\": 46}">>),
  {ok, [true,<<"Bob">>,#{<<"arr">> := [1,2,3]}]} = jerlson:load(<<"[true, \"Bob\", {\"arr\" : [1,2,3]}]">>),
  {ok, #{<<"a">> := true}} = jerlson:load(<<"{\"a\":true}">>),
  {ok, #{<<"a">> := <<"true">>}} = jerlson:load(<<"{\"a\":\"true\"}">>),
  {ok, #{<<"b">> := false}} = jerlson:load(<<"{\"b\":false}">>),
  {ok, #{<<"b">> := <<"false">>}} = jerlson:load(<<"{\"b\":\"false\"}">>),
  {ok, #{<<"c">> := null}} = jerlson:load(<<"{\"c\":null}">>),
  {ok, #{<<"c">> := <<"null">>}} = jerlson:load(<<"{\"c\":\"null\"}">>),
  {ok, #{<<"d">> := 10}} = jerlson:load(<<"{\"d\":10}">>),
  {ok, #{<<"d">> := -18}} = jerlson:load(<<"{\"d\":-18}">>),
  {ok, #{<<"d">> := <<"10">>}} = jerlson:load(<<"{\"d\":\"10\"}">>),
  {ok, #{<<"d">> := <<"-56">>}} = jerlson:load(<<"{\"d\":\"-56\"}">>),
  {ok, #{<<"e">> := 182.345}} = jerlson:load(<<"{\"e\":182.345}">>),
  {ok, #{<<"e">> := <<"-182.345">>}} = jerlson:load(<<"{\"e\":\"-182.345\"}">>),
  {ok, #{<<"f">> := 1235.0}} = jerlson:load(<<"{\"f\":12.35e2}">>),
  {ok, #{<<"f">> := -1235.0}} = jerlson:load(<<"{\"f\":-12.35e2}">>),
  {ok, #{<<"f">> := <<"12.35e2">>}} = jerlson:load(<<"{\"f\":\"12.35e2\"}">>),
  {ok, #{<<"g">> := 0.2135}} = jerlson:load(<<"{\"g\":21.35e-2}">>),
  {ok, #{<<"g">> := -0.2135}} = jerlson:load(<<"{\"g\":-21.35e-2}">>),
  {ok, #{<<"g">> := <<"21.35e-2">>}} = jerlson:load(<<"{\"g\":\"21.35e-2\"}">>),
  {ok, #{<<"h">> := 58.0e3}} = jerlson:load(<<"{\"h\":58e3}">>),
  {ok, #{<<"h">> := -58.0e3}} = jerlson:load(<<"{\"h\":-58e3}">>),
  {ok, #{<<"h">> := <<"58e3">>}} = jerlson:load(<<"{\"h\":\"58e3\"}">>),
  {ok, #{<<"i">> := <<"b">>}} = jerlson:load(<<"{\"i\":\"b\"}">>),
  {ok, #{<<"abcdefghijklm">> := <<"ABCDEFGHIJKLM">>}} = jerlson:load(<<"{\"abcdefghijklm\":\"ABCDEFGHIJKLM\"}">>),
  {ok, #{<<"x">> := #{<<"a">> := 10}}} = jerlson:load(<<"{\"x\": {\"a\":10}}">>),
  {ok, #{<<"s">> := <<"\t">>}} = jerlson:load(<<"{\"s\": ", $", $\\, $t, $", "}">>),
  {ok, #{<<"1">> := false, <<"2">> := true, <<"3">> := null}} = jerlson:load(<<"{\"1\":false,\"2\":true,\"3\":null}">>),
  {ok, #{<<"a">> := 10, <<"b">> := 123.456}} = jerlson:load(<<"{\"a\":10,\"b\":123.456}">>),
  {ok, #{<<"a">> := 10, <<"b">> := 123.456}} = jerlson:load("{\"a\":10,\"b\":123.456}"),
  {ok, [true]} = jerlson:load("[true]"),
  {ok, [true]} = jerlson:load(<<"[true]">>),
  {ok, [false]} = jerlson:load(<<"[false]">>),
  {ok, [null]} = jerlson:load(<<"[null]">>),
  {ok, [10]} = jerlson:load(<<"[10]">>),
  {ok, [-18]} = jerlson:load(<<"[-18]">>),
  {ok, [182.345]} = jerlson:load(<<"[182.345]">>),
  {ok, [1235.0]} = jerlson:load(<<"[12.35e2]">>),
  {ok, [0.2135]} = jerlson:load(<<"[21.35e-2]">>),
  {ok, [5.8e4]} = jerlson:load(<<"[58e3]">>),
  {ok, [<<"b">>]} = jerlson:load(<<"[\"b\"]">>),
  {ok, [[[[[[[[[[[[[[[[[[[[<<"DEEP">>]]]]]]]]]]]]]]]]]]]]} = jerlson:load(<<"[[[[[[[[[[[[[[[[[[[[\"DEEP\"]]]]]]]]]]]]]]]]]]]]">>),
  {ok, [#{<<"b">> := 20}]} = jerlson:load(<<"[{\"b\":20}]">>),
  {ok, [<<"\"">>]} = jerlson:load(<<"[", $", $\\, $", $", "]">>),
  {ok, []} = jerlson:load(<<"[]">>),
  {ok, []} = jerlson:load(<<" [ ] ">>),
  {ok, [<<"1">>, false, <<"2">>, true, <<"3">>, null]} = jerlson:load(<<"[\"1\",false,\"2\",true,\"3\",null]">>),
  {ok, [<<"a">>, 10, <<"b">>, 123.456]} = jerlson:load(<<"[\"a\",10,\"b\",123.456]">>),
  {ok, [<<"\"">>]} = jerlson:load("[\"\\\"\"]"),
  {ok, #{<<225,136,180>> := <<234,175,141>>}} = jerlson:load(<<"{\"\\u1234\":\"\\uABCD\"}">>),
  {ok, #{<<"before",225,136,180>> := <<234,175,141,"after">>}} = jerlson:load(<<"{\"before\\u1234\":\"\\uABCDafter\"}">>),
  {ok, #{<<"before",225,136,180,8,12,10,13,9>> := <<234,175,141,"after">>}} = jerlson:load(<<"{\"before\\u1234\\b\\f\\n\\r\\t\":\"\\uABCDafter\"}">>),
  {ok, #{<<"123.456",1>> := <<"ok">>}} = jerlson:load(<<"{\"123.456\\u0001\":\"ok\"}">>),
  {ok, [1, 1.2, <<"a">>, #{}, null]} = jerlson:load(<<"[1,1.2,\"a\",{},null]">>),
  {ok, [1, [], <<"a">>, #{}, null]} = jerlson:load(<<"[1,[],\"a\",{},null]">>),
  {ok, #{<<"x">> := [1, [], <<"a">>, #{}, null]}} = jerlson:load(<<"{\"x\":[1,[],\"a\",{},null]}">>),
  {ok, #{<<"my object ">> := #{<<"a">> := true, <<"b">> := false}}} = jerlson:load(<<"{\"my object \" : {\"a\" : true, \"b\" : false}}">>).
%%---------------------------------------------------------------------------------------------------------------------
%% @doc
%% @end
%%
run_parser_negative_tests() ->
  % empty string is not a valid JSON payload
  {error, invalid_payload} = jerlson:load(""),
  % empty binary is not a valid JSON payload
  {error, invalid_payload} = jerlson:load(<<"">>),
  % 'text' is not a valid JSON value
  {error, {illegal_character, 116}} = jerlson:load("text"),
  {error, {illegal_character, 116}} = jerlson:load(<<"text">>),
  % integer is not a valid JSON value
  {error, invalid_payload} = jerlson:load(1),
  % float is not a valid JSON value
  {error, invalid_payload} = jerlson:load(8.24),
  % boolean is not a valid JSON value
  {error, invalid_payload} = jerlson:load(true),
  % boolean is not a valid JSON value
  {error, invalid_payload} = jerlson:load(false),
  % null is not a valid JSON value
  {error, invalid_payload} = jerlson:load(null),
  % float value is out of range
  {error, float_out_of_range} = jerlson:load(<<"1.22e+523">>),
  % float value is out of range
  {error, float_out_of_range} = jerlson:load(<<"-1.22e+523">>),
  % arrays must be closed
  {error, unexpected_eof} = jerlson:load("[\"item1\",\"item2\""),
  {error, unexpected_eof} = jerlson:load(<<"[\"item1\",\"item2\"">>),
  % comma without item
  {error, {illegal_token, {rsquare, <<"]">>}}} = jerlson:load("[\"item\",]"),
  {error, {illegal_token, {rsquare, <<"]">>}}} = jerlson:load(<<"[\"item\",]">>),
  % two commas without item
  {error, {illegal_token, {comma, <<",">>}}} = jerlson:load("[\"item\",,]"),
  {error, {illegal_token, {comma, <<",">>}}} = jerlson:load(<<"[\"item\",,]">>),
  % missing item before comma
  {error, {illegal_token, {comma, <<",">>}}} = jerlson:load("[ , \"item\"]"),
  {error, {illegal_token, {comma, <<",">>}}} = jerlson:load(<<"[ , \"item\"]">>),
  % comma after closed array
  {error, {illegal_token, {comma, <<",">>}}} = jerlson:load("[\"item\"],"),
  {error, {illegal_token, {comma, <<",">>}}} = jerlson:load(<<"[\"item\"],">>),
  % array closed twice
  {error, {illegal_token, {rsquare, <<"]">>}}} = jerlson:load("[\"item\"]]"),
  {error, {illegal_token, {rsquare, <<"]">>}}} = jerlson:load(<<"[\"item\"]]">>),
  %% array as object name
  {error, {illegal_token, {lsquare, <<"[">>}}} = jerlson:load("{[true]:[false]}"),
  {error, {illegal_token, {lsquare, <<"[">>}}} = jerlson:load(<<"{[true]:[false]}">>),
  % colon where comma expected
  {error, {illegal_token, {colon, <<":">>}}} = jerlson:load("[\"item1\":\"item2\"]"),
  {error, {illegal_token, {colon, <<":">>}}} = jerlson:load(<<"[\"item1\":\"item2\"]">>),
  % brace where bracket expected
  {error, {illegal_token, {rbrace, <<"}">>}}} = jerlson:load("[\"item1\",\"item2\"}"),
  {error, {illegal_token, {rbrace, <<"}">>}}} = jerlson:load(<<"[\"item1\",\"item2\"}">>),
  % unterminated string value
  {error, unexpected_eof} = jerlson:load(<<$", $\\, $t>>),
	% keys must be quoted
  {error, {illegal_character, 107}} = jerlson:load("{key: \"value\"}"),
  {error, {illegal_character, 107}} = jerlson:load(<<"{key: \"value\"}">>),
  % comma after value
  {error, {illegal_token, {comma, <<",">>}}} = jerlson:load("{\"key\": \"value\",}"),
  {error, {illegal_token, {comma, <<",">>}}} = jerlson:load(<<"{\"key\": \"value\",}">>),
  % additional value after close
  {error, {illegal_token, {string, <<"text">>}}} = jerlson:load("{\"key\": \"value\"} \"text\""),
  {error, {illegal_token, {string, <<"text">>}}} = jerlson:load(<<"{\"key\": \"value\"} \"text\"">>),
  % illegal expression as property value
  {error, {illegal_character, $+}} = jerlson:load("{\"key\": 1 + 2}"),
  {error, {illegal_character, $+}} = jerlson:load(<<"{\"key\": 1 + 2}">>),
  % illegal invocation as property value
  {error, {illegal_character, $f}} = jerlson:load("{\"key\": function()}"),
  {error, {illegal_character, $f}} = jerlson:load(<<"{\"key\": function()}">>),
  %% object as object name
  {error, {illegal_token, {lbrace, <<"{">>}}} = jerlson:load("{{\"name\":\"value\"}:false}"),
  {error, {illegal_token, {lbrace, <<"{">>}}} = jerlson:load(<<"{{\"name\":\"value\"}:false}">>),
  %% no colon between key and value
  {error, {illegal_token, {string, <<"value">>}}} = jerlson:load("{\"key\" \"value\"}"),
  {error, {illegal_token, {string, <<"value">>}}} = jerlson:load(<<"{\"key\" \"value\"}">>),
  %% two or three colons between key and value
  {error, {illegal_token, {colon, <<":">>}}} = jerlson:load("{\"key\"::\"value\"}"),
  {error, {illegal_token, {colon, <<":">>}}} = jerlson:load(<<"{\"key\"::\"value\"}">>),
  {error, {illegal_token, {colon, <<":">>}}} = jerlson:load("{\"key\": :\"value\"}"),
  {error, {illegal_token, {colon, <<":">>}}} = jerlson:load(<<"{\"key\": :\"value\"}">>),
  {error, {illegal_token, {colon, <<":">>}}} = jerlson:load("{\"key\" : : : \"value\"}"),
  {error, {illegal_token, {colon, <<":">>}}} = jerlson:load(<<"{\"key\" : : : \"value\"}">>),
  %% comma where colon expected
  {error, {illegal_token, {comma, <<",">>}}} = jerlson:load("{\"key\",\"value\"}"),
  {error, {illegal_token, {comma, <<",">>}}} = jerlson:load(<<"{\"key\",\"value\"}">>),
  %% comma where brace expected
  {error, {illegal_token, {comma, <<",">>}}} = jerlson:load("{\"key\",\"value\","),
  {error, {illegal_token, {comma, <<",">>}}} = jerlson:load(<<"{\"key\",\"value\",">>),
  {error, {illegal_character, $t}} = jerlson:load("[truth]"),
  {error, {illegal_character, $T}} = jerlson:load("[True]"),
  {error, {illegal_character, $t}} = jerlson:load("[trUe]"),
  {error, {illegal_character, $T}} = jerlson:load("[TRUE]"),
  {error, {illegal_character, $F}} = jerlson:load("[False]"),
  {error, {illegal_character, $F}} = jerlson:load("[False]"),
  {error, {illegal_character, $F}} = jerlson:load("[FALSE]"),
  {error, {illegal_character, $N}} = jerlson:load("[Null]"),
  {error, {illegal_character, $n}} = jerlson:load("[nulL]"),
  {error, {illegal_character, $N}} = jerlson:load("[NULL]"),
  {error, {illegal_character, $a}} = jerlson:load("[10a]"),
  {error, {illegal_character, $+}} = jerlson:load("[+12]"),
  {error, {illegal_character, $a}} = jerlson:load("[23a345]"),
  {error, {illegal_character, $b}} = jerlson:load("[8374b]"),
  {error, {illegal_character, $8}} = jerlson:load("[0837]"),
  {error, {illegal_character, $.}} = jerlson:load("[12.34.35]"),
  {error, {illegal_character, $.}} = jerlson:load("[1..3]"),
  {error, {illegal_character, $a}} = jerlson:load("[12a34.35]"),
  {error, float_out_of_range} = jerlson:load("[1234.3e7364]"),
  {error, {illegal_character, $x}} = jerlson:load("[0x15]"),
  {error, {illegal_character, $\\}} = jerlson:load("[\\x11]"),
  {error, {illegal_character, $\\}} = jerlson:load("[\\alfa]"),
  {error, {illegal_character, $\\}} = jerlson:load("[\\025]"),
  {error, {illegal_character, $'}} = jerlson:load("['single']"),
  {error, {illegal_character, 9}} = jerlson:load("[\"alfa\tbeta\"]"),
  {error, {illegal_character, 10}} = jerlson:load("[\"alfa\nbeta\"]"),
  {error, {illegal_character, $]}} = jerlson:load("[0e]"),
  {error, {illegal_character, $]}} = jerlson:load("[0e+]"),
  {error, {illegal_character, $-}} = jerlson:load("[0e+-1]"),
	{error, {illegal_character, $t}} = jerlson:load("{\"key\": truth}"),
  {error, {illegal_character, $T}} = jerlson:load("{\"key\": True}"),
  {error, {illegal_character, $t}} = jerlson:load("{\"key\": trUe]"),
  {error, {illegal_character, $T}} = jerlson:load("{\"key\": TRUE}"),
  {error, {illegal_character, $F}} = jerlson:load("{\"key\": False}"),
  {error, {illegal_character, $F}} = jerlson:load("{\"key\": False}"),
  {error, {illegal_character, $F}} = jerlson:load("{\"key\": FALSE}"),
  {error, {illegal_character, $N}} = jerlson:load("{\"key\": Null}"),
  {error, {illegal_character, $n}} = jerlson:load("{\"key\": nulL}"),
  {error, {illegal_character, $N}} = jerlson:load("{\"key\": NULL}"),
  {error, {illegal_character, $a}} = jerlson:load("{\"key\": 10a}"),
  {error, {illegal_character, $+}} = jerlson:load("{\"key\": +12}"),
  {error, {illegal_character, $a}} = jerlson:load("{\"key\": 23a345}"),
  {error, {illegal_character, $b}} = jerlson:load("{\"key\": 8374b}"),
  {error, {illegal_character, $8}} = jerlson:load("{\"key\": 0837}"),
  {error, {illegal_character, $.}} = jerlson:load("{\"key\": 12.34.35}"),
  {error, {illegal_character, $.}} = jerlson:load("{\"key\": 1..3}"),
  {error, {illegal_character, $a}} = jerlson:load("{\"key\": 12a34.35}"),
  {error, float_out_of_range} = jerlson:load("{\"key\": 1234.3e7364}"),
  {error, {illegal_character, $x}} = jerlson:load("{\"key\": x15}"),
  {error, {illegal_character, $\\}} = jerlson:load("{\"key\": \\x11}"),
  {error, {illegal_character, $\\}} = jerlson:load("{\"key\": \\alfa}"),
  {error, {illegal_character, $\\}} = jerlson:load("{\"key\": \\025}"),
  {error, {illegal_character, $'}} = jerlson:load("{\"key\": 'single'}"),
  {error, {illegal_character, $}}} = jerlson:load("{\"key\": 0e}"),
  {error, {illegal_character, $}}} = jerlson:load("{\"key\": 0e+}"),
  {error, {illegal_character, $-}} = jerlson:load("{\"key\": 0e+-1}"),
  %% after \u must be 4 hex digits
  {error, _} = jerlson:load("{\"123.456\\u001\":\"error\"}"),
  %% after \u 'G' is not a hex digit	
  {error, _} = jerlson:load("[\"\\uABCD\\uEF89\\uABCG\"]").
%%---------------------------------------------------------------------------------------------------------------------
%% @doc
%% @end
%%
run_lexer_tests() ->
  {error, unexpected_eof} = jerlson_lexer:parse(<<"">>),
  {error, unexpected_eof} = jerlson_lexer:parse(<<"-">>),
  {ok, [{integer, 0}]} = jerlson_lexer:parse(<<"0">>),
  {ok, [{integer, 0}]} = jerlson_lexer:parse(<<"-0">>),
  {ok, [{integer, 1}]} = jerlson_lexer:parse(<<"1">>),
  {ok, [{integer, -1}]} = jerlson_lexer:parse(<<"-1">>),
  {ok, [{integer, 9}]} = jerlson_lexer:parse(<<"9">>),
  {ok, [{integer, -9}]} = jerlson_lexer:parse(<<"-9">>),
  {ok, [{integer, 10}]} = jerlson_lexer:parse(<<"10">>),
  {ok, [{integer, -10}]} = jerlson_lexer:parse(<<"-10">>),
  {ok, [{integer, 1027364557564293847293482734}]} = jerlson_lexer:parse(<<"1027364557564293847293482734">>),
  {ok, [{integer, -1027364557564293847293482734}]} = jerlson_lexer:parse(<<"-1027364557564293847293482734">>),
  {ok, [{float, 1.0}]} = jerlson_lexer:parse(<<"1.0">>),
  {ok, [{float, -1.0}]} = jerlson_lexer:parse(<<"-1.0">>),
  {ok, [{float, 1.273645473}]} = jerlson_lexer:parse(<<"1.273645473">>),
  {ok, [{float, -1.273645473}]} = jerlson_lexer:parse(<<"-1.273645473">>),
  {ok, [{float, 102736455756429.3847293482734}]} = jerlson_lexer:parse(<<"102736455756429.3847293482734">>),
  {ok, [{float, -10273645.57564293847293482734}]} = jerlson_lexer:parse(<<"-10273645.57564293847293482734">>),
  {ok, [{float, 123.0}]} = jerlson_lexer:parse(<<"1.23e2">>),
  {ok, [{float, 123.0}]} = jerlson_lexer:parse(<<"1.23e+2">>),
  {ok, [{float, 5.3423}]} = jerlson_lexer:parse(<<"534.23e-2">>),
  {ok, [{float, 123293.847239}]} = jerlson_lexer:parse(<<"1.23293847239e+5">>),
  {ok, [{float, 53493.2874924723}]} = jerlson_lexer:parse(<<"5349328749247.23e-8">>),
  {error, float_out_of_range} = jerlson_lexer:parse(<<"1.22e+523">>),
  {error, float_out_of_range} = jerlson_lexer:parse(<<"-1.22e+523">>),
  {ok, [{string, <<244,128,133,146>>}]} = jerlson_lexer:parse(<<"\"\\uD834\\uDD1E\"">>).
%%---------------------------------------------------------------------------------------------------------------------
%% @doc
%% @end
%%
run_dump_positive_test() ->
  ?DUMP(#{},                              {ok, <<"{}">>}),
  ?DUMP(#{<<"a">> => true},               {ok, <<"{\"a\":true}">>}),
  ?DUMP(#{<<"a">> => true},               {ok, <<"{\"a\":true}">>}),
  ?DUMP(#{   a    => true},               {ok, <<"{\"a\":true}">>}),
  ?DUMP(#{<<"a">> => <<"true">>},         {ok, <<"{\"a\":\"true\"}">>}),
  ?DUMP(#{   a    => <<"true">>},         {ok, <<"{\"a\":\"true\"}">>}),
  ?DUMP(#{<<"b">> => false},              {ok, <<"{\"b\":false}">>}),
  ?DUMP(#{<<"b">> => <<"false">>},        {ok, <<"{\"b\":\"false\"}">>}),
  ?DUMP(#{<<"c">> => null},               {ok, <<"{\"c\":null}">>}),
  ?DUMP(#{   c    => null},               {ok, <<"{\"c\":null}">>}),
  ?DUMP(#{<<"c">> => <<"null">>},         {ok, <<"{\"c\":\"null\"}">>}),
  ?DUMP(#{<<"d">> => 10},                 {ok, <<"{\"d\":10}">>}),
  ?DUMP(#{   d    => -18},                {ok, <<"{\"d\":-18}">>}),
  ?DUMP(#{<<"d">> => <<"10">>},           {ok, <<"{\"d\":\"10\"}">>}),
  ?DUMP(#{   d    => <<"10">>},           {ok, <<"{\"d\":\"10\"}">>}),
  ?DUMP(#{<<"e">> => {182.345,  3}},      {ok, <<"{\"e\":182.345}">>}),
  ?DUMP(#{   e    => {182.345,  3}},      {ok, <<"{\"e\":182.345}">>}),
  ?DUMP(#{<<"f">> => {1235.0,   1}},      {ok, <<"{\"f\":1235.0}">>}),
  ?DUMP(#{   f    => {12.35e2,  1}},      {ok, <<"{\"f\":1235.0}">>}),
  ?DUMP(#{   g    => {21.35e-2, 4}},      {ok, <<"{\"g\":0.2135}">>}),
  ?DUMP(#{<<"a">> => <<"b">>},            {ok, <<"{\"a\":\"b\"}">>}),
  ?DUMP(#{   alfa => beta },              {ok, <<"{\"alfa\":\"beta\"}">>}),
  ?DUMP(#{<<"x">> => #{<<"a">> => 10}},   {ok, <<"{\"x\":{\"a\":10}}">>}),
  ?DUMP(#{<<"1">> => false, <<"2">> => true, <<"3">> => null},    {ok, <<"{\"1\":false,\"2\":true,\"3\":null}">>}),
  ?DUMP(#{<<"a">> => 10, <<"b">> => {123.456, 3}},                {ok, <<"{\"a\":10,\"b\":123.456}">>}),
  ?DUMP(#{alfa => -23, beta => {21.35e-2, 4}},                    {ok, <<"{\"alfa\":-23,\"beta\":0.2135}">>}),
  ?DUMP([true],                           {ok, <<"[true]">>}),		
  ?DUMP([false],                          {ok, <<"[false]">>}),
  ?DUMP([null],                           {ok, <<"[null]">>}),
  ?DUMP([10],                             {ok, <<"[10]">>}),
  ?DUMP([-18],                            {ok, <<"[-18]">>}),
  ?DUMP([{182.345,  3}],                  {ok, <<"[182.345]">>}),
  ?DUMP([{12.35e2,  1}],                  {ok, <<"[1235.0]">>}),
  ?DUMP([{21.35e-2, 4}],                  {ok, <<"[0.2135]">>}),
  ?DUMP([{58.0e3,   0}],                  {ok, <<"[58000]">>}),
  ?DUMP([<<"beta">>],                     {ok, <<"[\"beta\"]">>}),
  ?DUMP([alfa],                           {ok, <<"[\"alfa\"]">>}),
  ?DUMP([<<"a", 16#22, "b">>],            {ok, <<"[\"a", 16#5C, 16#22, "b\"]">>}),
  ?DUMP([<<"a", 16#5C, "b">>],            {ok, <<"[\"a", 16#5C, 16#5C, "b\"]">>}),
  ?DUMP([<<"a", 16#2F, "b">>],            {ok, <<"[\"a", 16#5C, 16#2F, "b\"]">>}),
  ?DUMP([<<"a", 16#08, "b">>],            {ok, <<"[\"a", 16#5C, 16#62, "b\"]">>}),
  ?DUMP([<<"a", 16#0C, "b">>],            {ok, <<"[\"a", 16#5C, 16#66, "b\"]">>}),
  ?DUMP([<<"a", 16#0A, "b">>],            {ok, <<"[\"a", 16#5C, 16#6E, "b\"]">>}),
  ?DUMP([<<"a", 16#0D, "b">>],            {ok, <<"[\"a", 16#5C, 16#72, "b\"]">>}),
  ?DUMP([<<"a", 16#09, "b">>],            {ok, <<"[\"a", 16#5C, 16#74, "b\"]">>}),
  ?DUMP([[[[[[[[[[[[[[[[[[[[<<"DEEP">>]]]]]]]]]]]]]]]]]]]], {ok, <<"[[[[[[[[[[[[[[[[[[[[\"DEEP\"]]]]]]]]]]]]]]]]]]]]">>}).
%%---------------------------------------------------------------------------------------------------------------------
%% @doc
%% @end
%%
run_dump_negative_test() ->
  ?DUMP(#{"a"=> true}, {error,invalid_name}).
%%---------------------------------------------------------------------------------------------------------------------
%% @doc
%% @end
%%
eq(Expected, Current) when Expected =:= Current ->
	ok;
eq(Expected, Current) ->
	throw({equal_expected, {expected, Expected}, {current, Current}}).
%%---------------------------------------------------------------------------------------------------------------------