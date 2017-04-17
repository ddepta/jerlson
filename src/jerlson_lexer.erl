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

-module(jerlson_lexer).

%% API
-export([parse/1]).

%%%==================================================================================================================== 
%%% API                                  
%%%====================================================================================================================

%%---------------------------------------------------------------------------------------------------------------------
%% @doc
%% @end
%%
parse(<<>>) ->
  {error, unexpected_eof};
parse(Input) when is_binary(Input) ->
  try parse_input(Input, []) of
    Tokens ->
      {ok, Tokens}
  catch
    _:Reason -> 
      {error, Reason}
  end.
%%---------------------------------------------------------------------------------------------------------------------

%%%====================================================================================================================
%%% Internal functions 
%%%====================================================================================================================  

%%---------------------------------------------------------------------------------------------------------------------
%% @doc
%% @end
%%
parse_input(<<>>, Tokens) ->
  lists:reverse(Tokens);
parse_input(<<C:8, Input/binary>>, Tokens) when C >= $0, C =< $9 ->
  parse_number(0, <<C, Input/binary>>, <<>>, Tokens);
parse_input(<<C:8, Input/binary>>, Tokens) when C == $- ->
  parse_number(0, <<C, Input/binary>>, <<>>, Tokens);
parse_input(<<$", Input/binary>>, Tokens) ->
  parse_string(Input, <<>>, Tokens);
parse_input(<<${, Input/binary>>, Tokens) ->
  parse_input(Input, [{lbrace, <<${>>} | Tokens]);
parse_input(<<$}, Input/binary>>, Tokens) ->
  parse_input(Input, [{rbrace, <<$}>>} | Tokens]);
parse_input(<<$[, Input/binary>>, Tokens) ->
  parse_input(Input, [{lsquare, <<$[>>} | Tokens]);
parse_input(<<$], Input/binary>>, Tokens) ->
  parse_input(Input, [{rsquare, <<$]>>} | Tokens]);
parse_input(<<$:, Input/binary>>, Tokens) ->
  parse_input(Input, [{colon, <<$:>>} | Tokens]);
parse_input(<<$,, Input/binary>>, Tokens) ->
  parse_input(Input, [{comma, <<$,>>} | Tokens]);
parse_input(<<"true", Input/binary>>, Tokens) ->
  parse_input(Input, [{true, <<"true">>} | Tokens]);
parse_input(<<"false", Input/binary>>, Tokens) ->
  parse_input(Input, [{false, <<"false">>} | Tokens]);
parse_input(<<"null", Input/binary>>, Tokens) ->
  parse_input(Input, [{null, <<"null">>} | Tokens]);
parse_input(<<16#09, Input/binary>>, Tokens) ->
  parse_input(Input, Tokens);
parse_input(<<16#0A, Input/binary>>, Tokens) ->
  parse_input(Input, Tokens);
parse_input(<<16#0D, Input/binary>>, Tokens) ->
  parse_input(Input, Tokens);
parse_input(<<16#20, Input/binary>>, Tokens) ->
  parse_input(Input, Tokens);
parse_input(<<C:8, _Input/binary>>, _Tokens) ->
  throw({illegal_character, C}).
%%---------------------------------------------------------------------------------------------------------------------
%% @doc
%% @end
%%
parse_string(<<>>, _String, _Tokens) ->
  throw(unexpected_eof);
parse_string(<<$\\, $u, H1:8, H2:8, H3:8, H4:8, $\\, $u, L1:8, L2:8, L3:8, L4:8, Input/binary>>, String, Tokens) ->
  Chars = decode_unicode(codepoint(H1, H2, H3, H4), codepoint(L1, L2, L3, L4)),
  parse_string(Input, <<String/binary, Chars/binary>>, Tokens);
parse_string(<<$\\, $u, H1:8, H2:8, H3:8, H4:8, Input/binary>>, String, Tokens) ->
  Chars = decode_unicode(codepoint(H1, H2, H3, H4)),
  parse_string(Input, <<String/binary, Chars/binary>>, Tokens);
parse_string(<<$\\, $", Input/binary>>, String, Tokens) ->
  parse_string(Input, <<String/binary, 16#22>>, Tokens);
parse_string(<<$\\, $\\, Input/binary>>, String, Tokens) ->
  parse_string(Input, <<String/binary, 16#5C>>, Tokens);
parse_string(<<$\\, $/, Input/binary>>, String, Tokens) ->
  parse_string(Input, <<String/binary, 16#2F>>, Tokens);
parse_string(<<$\\, $b, Input/binary>>, String, Tokens) ->
  parse_string(Input, <<String/binary, 16#08>>, Tokens);
parse_string(<<$\\, $f, Input/binary>>, String, Tokens) ->
  parse_string(Input, <<String/binary, 16#0C>>, Tokens);
parse_string(<<$\\, $n, Input/binary>>, String, Tokens) ->
  parse_string(Input, <<String/binary, 16#0A>>, Tokens);
parse_string(<<$\\, $r, Input/binary>>, String, Tokens) ->
  parse_string(Input, <<String/binary, 16#0D>>, Tokens);
parse_string(<<$\\, $t, Input/binary>>, String, Tokens) ->
  parse_string(Input, <<String/binary, 16#09>>, Tokens);
parse_string(<<$", Input/binary>>, String, Tokens) ->
  parse_input(Input, [string_token(String) | Tokens]);
parse_string(<<16#5C, _Input/binary>>, _String, _Tokens) ->
  throw({illegal_character, 16#5C});
parse_string(<<16#08, _Input/binary>>, _String, _Tokens) ->
  throw({illegal_character, 16#08});
parse_string(<<16#0C, _Input/binary>>, _String, _Tokens) ->
  throw({illegal_character, 16#0C});
parse_string(<<16#0A, _Input/binary>>, _String, _Tokens) ->
  throw({illegal_character, 16#0A});
parse_string(<<16#0D, _Input/binary>>, _String, _Tokens) ->
  throw({illegal_character, 16#0D});  
parse_string(<<16#09, _Input/binary>>, _String, _Tokens) ->
  throw({illegal_character, 16#09});
parse_string(<<Char:8, Input/binary>>, String, Tokens) ->
  parse_string(Input, <<String/binary, Char>>, Tokens).
%%---------------------------------------------------------------------------------------------------------------------
%% @doc
%% @end
%%
parse_number(0, <<>>, _Number, _Tokens) ->
  throw(unexpected_eof);
parse_number(0, <<$-, Input/binary>>, Number, Tokens) ->
  parse_number(1, Input, <<Number/binary, $->>, Tokens);
parse_number(0, <<$0, Input/binary>>, Number, Tokens) ->
  parse_number(2, Input, <<Number/binary, $0>>, Tokens);
parse_number(0, <<C:8, Input/binary>>, Number, Tokens) when C >= $1, C =< $9 ->
  parse_number(3, Input, <<Number/binary, C>>, Tokens);
parse_number(0, <<C:8, _Input/binary>>, _Number, _Tokens) ->
  throw({illegal_character, C});
parse_number(1, <<>>, _Number, _Tokens) ->
  throw(unexpected_eof);
parse_number(1, <<$0, Input/binary>>, Number, Tokens) ->
  parse_number(2, Input, <<Number/binary, $0>>, Tokens);
parse_number(1, <<C:8, Input/binary>>, Number, Tokens) when C >= $1, C =< $9 ->
  parse_number(3, Input, <<Number/binary, C>>, Tokens);
parse_number(1, <<C:8, _Input/binary>>, _Number, _Tokens) ->
  throw({illegal_character, C});
parse_number(2, <<>>, Number, Tokens) ->
  parse_input(<<>>, [integer_token(Number) | Tokens]);
parse_number(2, <<$., Input/binary>>, Number, Tokens) ->
  parse_number(4, Input, <<Number/binary, $.>>, Tokens);
parse_number(2, <<C:8, Input/binary>>, Number, Tokens) when C == 16#09; C == 16#0A; C == 16#0D; C == 16#20 ->
  parse_input(Input, [integer_token(Number) | Tokens]);
parse_number(2, <<C:8, Input/binary>>, Number, Tokens) when C == $,; C == $]; C == $} ->
  parse_input(<<C, Input/binary>>, [integer_token(Number) | Tokens]);
parse_number(2, <<C:8, Input/binary>>, Number, Tokens) when C == $e; C == $E ->
  parse_number(6, Input, <<Number/binary, ".0", C>>, Tokens);
parse_number(2, <<C:8, _Input/binary>>, _Number, _Tokens) ->
  throw({illegal_character, C});
parse_number(3, <<>>, Number, Tokens) ->
  parse_input(<<>>, [integer_token(Number) | Tokens]);
parse_number(3, <<$., Input/binary>>, Number, Tokens) ->
  parse_number(4, Input, <<Number/binary, $.>>, Tokens);
parse_number(3, <<C:8, Input/binary>>, Number, Tokens) when C == 16#09; C == 16#0A; C == 16#0D; C == 16#20 ->
  parse_input(Input, [integer_token(Number) | Tokens]);
parse_number(3, <<C:8, Input/binary>>, Number, Tokens) when C == $,; C == $]; C == $} ->
  parse_input(<<C, Input/binary>>, [integer_token(Number) | Tokens]);
parse_number(3, <<C:8, Input/binary>>, Number, Tokens) when C == $e; C == $E ->
  parse_number(6, Input, <<Number/binary, ".0", C>>, Tokens);
parse_number(3, <<C:8, Input/binary>>, Number, Tokens) when C >= $0, C =< $9 ->
  parse_number(3, Input, <<Number/binary, C>>, Tokens);
parse_number(3, <<C:8, _Input/binary>>, _Number, _Tokens) ->
  throw({illegal_character, C});
parse_number(4, <<>>, _Number, _Tokens) ->
  throw(unexpected_eof);
parse_number(4, <<C:8, Input/binary>>, Number, Tokens) when C >= $0, C =< $9 ->
  parse_number(5, Input, <<Number/binary, C>>, Tokens);
parse_number(4, <<C:8, _Input/binary>>, _Number, _Tokens) ->
  throw({illegal_character, C});
parse_number(5, <<>>, Number, Tokens) ->
  parse_input(<<>>, [float_token(Number) | Tokens]);
parse_number(5, <<C:8, Input/binary>>, Number, Tokens) when C >= $0, C =< $9 ->
  parse_number(5, Input, <<Number/binary, C>>, Tokens);
parse_number(5, <<C:8, Input/binary>>, Number, Tokens) when C == 16#09; C == 16#0A; C == 16#0D; C == 16#20 ->
  parse_input(Input, [float_token(Number) | Tokens]);
parse_number(5, <<C:8, Input/binary>>, Number, Tokens) when C == $,; C == $]; C == $} ->
  parse_input(<<C, Input/binary>>, [float_token(Number) | Tokens]);
parse_number(5, <<C:8, Input/binary>>, Number, Tokens) when C == $e; C == $E ->
  parse_number(6, Input, <<Number/binary, C>>, Tokens);
parse_number(5, <<C:8, _Input/binary>>, _Number, _Tokens) ->
  throw({illegal_character, C});
parse_number(6, <<>>, _Number, _Tokens) ->
  throw(unexpected_eof);
parse_number(6, <<C:8, Input/binary>>, Number, Tokens) when C == $+; C == $- ->
  parse_number(7, Input, <<Number/binary, C>>, Tokens);
parse_number(6, <<C:8, Input/binary>>, Number, Tokens) when C >= $0, C =< $9 ->
  parse_number(8, Input, <<Number/binary, C>>, Tokens);
parse_number(6, <<C:8, _Input/binary>>, _Number, _Tokens) ->
  throw({illegal_character, C});
parse_number(7, <<>>, _Number, _Tokens) ->
  throw(unexpected_eof);
parse_number(7, <<C:8, Input/binary>>, Number, Tokens) when C >= $0, C =< $9 ->
  parse_number(8, Input, <<Number/binary, C>>, Tokens);
parse_number(7, <<C:8, _Input/binary>>, _Number, _Tokens) ->
  throw({illegal_character, C});
parse_number(8, <<>>, Number, Tokens) ->
  parse_input(<<>>, [float_token(Number) | Tokens]);
parse_number(8, <<C:8, Input/binary>>, Number, Tokens) when C >= $0, C =< $9 ->
  parse_number(8, Input, <<Number/binary, C>>, Tokens);
parse_number(8, <<C:8, Input/binary>>, Number, Tokens) when C == 16#09; C == 16#0A; C == 16#0D; C == 16#20 ->
  parse_input(Input, [float_token(Number) | Tokens]);
parse_number(8, <<C:8, Input/binary>>, Number, Tokens) when C == $,; C == $]; C == $} ->
  parse_input(<<C, Input/binary>>, [float_token(Number) | Tokens]);
parse_number(8, <<C:8, _Input/binary>>, _Number, _Tokens) ->
  throw({illegal_character, C}).
%%---------------------------------------------------------------------------------------------------------------------
%% @doc
%% @end
%%
codepoint(H1, H2, H3, H4) ->
  (dec(H1) * 4096) + (dec(H2) * 256) + (dec(H3) * 16) + dec(H4).
%%---------------------------------------------------------------------------------------------------------------------
%% @doc
%% @end
%%
dec(C) when C >= $0, C =< $9 -> 
  C - $0;
dec(C) when C >= $A, C =< $F ->
  C - $A + 10;
dec(C) when C >= $a, C =< $f ->
  C - $a + 10;
dec(C) ->
  throw({illegal_character, C}).
%%---------------------------------------------------------------------------------------------------------------------
%% @doc
%% @end
%%
decode_unicode(H, L) when H >= 16#D800, H =< 16#DBFF, L >= 16#DC00, L =< 16#DFFF ->
  C = 16#100000 + (H - 16#D800) + (L - 16#DC00),
  unicode:characters_to_binary([C], utf16);
decode_unicode(H, L) ->
  HBin = decode_unicode(H),
  LBin = decode_unicode(L),
  <<HBin, LBin>>.
%%---------------------------------------------------------------------------------------------------------------------
%% @doc
%% @end
%%
decode_unicode(C) when C >= 16#0000, C < 16#D800 ->
  unicode:characters_to_binary([C], utf8);
decode_unicode(C) when C > 16#DFFF, C =< 16#FFFF ->
  unicode:characters_to_binary([C], utf8);
decode_unicode(C) ->
  throw({illegal_utf8_value, C}).
%%---------------------------------------------------------------------------------------------------------------------
%% @doc
%% @end
%%
string_token(Binary) ->
  {string, Binary}.
%%---------------------------------------------------------------------------------------------------------------------
%% @doc
%% @end
%%
integer_token(Binary) ->
  try binary_to_integer(Binary) of
    Value ->
      {integer, Value}
  catch
    _:_ ->
      throw(integer_out_of_range)
  end.
%%---------------------------------------------------------------------------------------------------------------------
%% @doc
%% @end
%%
float_token(Binary) ->
  try binary_to_float(Binary) of
    Value ->
      {float, Value}
  catch
    _:_ ->
      throw(float_out_of_range)
  end.
%%---------------------------------------------------------------------------------------------------------------------