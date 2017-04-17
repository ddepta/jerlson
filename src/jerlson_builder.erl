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

-module(jerlson_builder).

%% API
-export([json/1]).

%%%==================================================================================================================== 
%%% API                                  
%%%====================================================================================================================

%%---------------------------------------------------------------------------------------------------------------------
%% @doc
%% @end
json(Value) ->
  json_value(Value).
%%---------------------------------------------------------------------------------------------------------------------

%%%====================================================================================================================
%%% Internal functions 
%%%====================================================================================================================

%%---------------------------------------------------------------------------------------------------------------------
%% @doc
%% @end
json_array([], Array) ->
  <<$[, Array/binary, $]>>;
json_array([H|T], <<>>) ->
  Value = json_value(H),
  json_array(T, <<Value/binary>>);
json_array([H|T], Array) ->
  Value = json_value(H),
  json_array(T, <<Array/binary, $,, Value/binary>>);
json_array(_, _) ->
  throw(invalid_list_item).
%%---------------------------------------------------------------------------------------------------------------------
%% @doc
%% @end
json_object(Map) when is_map(Map) ->
  Fun = fun(Key, Binary) -> 
    NameBin = json_name(Key),
    ValueBin = json_value(maps:get(Key, Map)),
    json_join(Binary, <<$", NameBin/binary, $", $:, ValueBin/binary>>)
  end,
  Object = lists:foldl(Fun, <<>>, maps:keys(Map)),
  <<${, Object/binary, $}>>.
%%---------------------------------------------------------------------------------------------------------------------
%% @doc
%% @end
json_name(Name) when is_binary(Name) ->
  escape_control_characters(Name);
json_name(Name) when is_atom(Name) ->
  escape_control_characters(atom_to_binary(Name, utf8));
json_name(_) ->
  throw(invalid_name).
%%---------------------------------------------------------------------------------------------------------------------
%% @doc
%% @end
json_value(true) ->
  <<"true">>;
json_value(false) ->
  <<"false">>;
json_value(null) ->
  <<"null">>;
json_value({Value, Precision}) when is_float(Value), is_integer(Precision) ->
  ValueBin = float_to_binary(Value, [{decimals, Precision}, compact]),
  <<ValueBin/binary>>;
json_value(Value) when is_binary(Value) ->
  ValueBin = escape_control_characters(Value),
  <<"\"", ValueBin/binary, "\"">>;
json_value(Value) when is_list(Value) ->
  json_array(Value, <<>>);
json_value(Value) when is_map(Value) ->
  json_object(Value);
json_value(Value) when is_atom(Value) ->
  ValueBin = escape_control_characters(atom_to_binary(Value, utf8)),
  <<"\"", ValueBin/binary, "\"">>;
json_value(Value) when is_integer(Value) ->
  list_to_binary(integer_to_list(Value));
json_value(Value) when is_float(Value) ->
  float_to_binary(Value);
json_value(_) ->
  throw(invalid_value).
%%---------------------------------------------------------------------------------------------------------------------
%% @doc
%% @end
escape_control_characters(Characters) when is_binary(Characters) ->
  escape_control_chars_bin(Characters, <<>>).
%%---------------------------------------------------------------------------------------------------------------------
%% @doc Escapes JSON control characters given as binary.
%% @end
escape_control_chars_bin(<<>>, Chars) ->
  Chars;
escape_control_chars_bin(<<Char/utf16, Rest/binary>>, Chars) when Char > 16#FFFF, Char =< 16#10FFFF ->
  D1 = json_hex((Char bsr 28) band 16#F),
  D2 = json_hex((Char bsr 24) band 16#F),
  D3 = json_hex((Char bsr 20) band 16#F),
  D4 = json_hex((Char bsr 16) band 16#F),
  D5 = json_hex((Char bsr 12) band 16#F),
  D6 = json_hex((Char bsr 8) band 16#F),
  D7 = json_hex((Char bsr 4) band 16#F),
  D8 = json_hex(Char band 16#F),
  escape_control_chars_bin(Rest, <<Chars/binary, "\\u", D1/binary, D2/binary, D3/binary, D4/binary, "\\u", D5/binary, D6/binary, D7/binary, D8/binary>>);
escape_control_chars_bin(<<Char/utf8, Rest/binary>>, Chars) when Char > 16#FF, Char =< 16#FFFF ->
  D1 = json_hex((Char bsr 12) band 16#F),
  D2 = json_hex((Char bsr 8) band 16#F),
  D3 = json_hex((Char bsr 4) band 16#F),
  D4 = json_hex(Char band 16#F),
  escape_control_chars_bin(Rest, <<Chars/binary, "\\u", D1/binary, D2/binary, D3/binary, D4/binary>>);
escape_control_chars_bin(<<16#22, Rest/binary>>, Chars) ->
  escape_control_chars_bin(Rest, <<Chars/binary, 16#5C, 16#22>>);
escape_control_chars_bin(<<16#5C, Rest/binary>>, Chars) ->
  escape_control_chars_bin(Rest, <<Chars/binary, 16#5C, 16#5C>>);
escape_control_chars_bin(<<16#2F, Rest/binary>>, Chars) ->
  escape_control_chars_bin(Rest, <<Chars/binary, 16#5C, 16#2F>>);
escape_control_chars_bin(<<16#08, Rest/binary>>, Chars) ->
  escape_control_chars_bin(Rest, <<Chars/binary, 16#5C, 16#62>>);
escape_control_chars_bin(<<16#0C, Rest/binary>>, Chars) ->
  escape_control_chars_bin(Rest, <<Chars/binary, 16#5C, 16#66>>);
escape_control_chars_bin(<<16#0A, Rest/binary>>, Chars) ->
  escape_control_chars_bin(Rest, <<Chars/binary, 16#5C, 16#6E>>);
escape_control_chars_bin(<<16#0D, Rest/binary>>, Chars) ->
  escape_control_chars_bin(Rest, <<Chars/binary, 16#5C, 16#72>>);
escape_control_chars_bin(<<16#09, Rest/binary>>, Chars) ->
  escape_control_chars_bin(Rest, <<Chars/binary, 16#5C, 16#74>>);
escape_control_chars_bin(<<Char:8/integer, Rest/binary>>, Chars) when Char >= 16#20, Char =< 16#FF ->
  escape_control_chars_bin(Rest, <<Chars/binary, Char>>);
escape_control_chars_bin(_, _) ->
  throw(invalid_character).
%%---------------------------------------------------------------------------------------------------------------------
%% @doc
%% @end
json_join(<<>>, Suffix) when is_binary(Suffix) ->
  Suffix;
json_join(Prefix, Suffix) when is_binary(Prefix), is_binary(Suffix) ->
  <<Prefix/binary, $,, Suffix/binary>>.
%%---------------------------------------------------------------------------------------------------------------------
%% @doc
%% @end
json_hex(Value) when Value >= 0, Value =< 9 ->
  Hex = Value + 48,
  <<Hex:8/integer>>;
json_hex(Value) when Value >= 10, Value =< 15 ->
  Hex = Value + 55,
  <<Hex:8/integer>>.
%%---------------------------------------------------------------------------------------------------------------------