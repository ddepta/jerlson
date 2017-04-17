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

-module(jerlson_parser).

%% API
-export([parse/1]).

%%%==================================================================================================================== 
%%% API                                  
%%%====================================================================================================================

%%---------------------------------------------------------------------------------------------------------------------
%% @doc
%% @end
%%
parse(Tokens) when is_list(Tokens) ->
  try parse_value(Tokens) of
    {ok, Value, []} ->
      {ok, Value};
    {ok, _Value, [Token | _]} ->
      {error, {illegal_token, Token}}
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
parse_value([{lbrace, _} | Tokens]) ->
  parse_object(Tokens);
parse_value([{lsquare, _} | Tokens]) ->
  parse_array(Tokens);
parse_value([{string, Value} | Tokens]) ->
  {ok, Value, Tokens};
parse_value([{integer, Value} | Tokens]) ->
  {ok, Value, Tokens};
parse_value([{float, Value} | Tokens]) ->
  {ok, Value, Tokens};
parse_value([{true, _} | Tokens]) ->
  {ok, true, Tokens};
parse_value([{false, _} | Tokens]) ->
  {ok, false, Tokens};
parse_value([{null, _} | Tokens]) ->
  {ok, null, Tokens};
parse_value([Token | _]) ->
  throw({illegal_token, Token}).
%%---------------------------------------------------------------------------------------------------------------------
%% @doc
%% @end
%%
parse_object(Tokens) ->
  Object = #{},
  parse_member(Object, Tokens).
%%---------------------------------------------------------------------------------------------------------------------
%% @doc
%% @end
%%
parse_member(_Object, []) ->
  throw(unexpected_eof);
parse_member(Object, [{rbrace, _} | Tokens]) ->
  {ok, Object, Tokens};
parse_member(Object, [{string, Key} | Tokens]) ->
  {ok, Value, T} = parse_property_value(Tokens),
  parse_opt_member(Object#{Key => Value}, T);
parse_member(_Object, [Token | _]) ->
  throw({illegal_token, Token}).
%%---------------------------------------------------------------------------------------------------------------------
%% @doc
%% @end
%%
parse_opt_member(_Object, []) ->
  throw(unexpected_eof);
parse_opt_member(Object, [{rbrace, _} | Tokens]) ->
  {ok, Object, Tokens};
parse_opt_member(Object, [{comma, _}, {string, Key} | Tokens]) ->
  {ok, Value, T} = parse_property_value(Tokens),
  parse_opt_member(Object#{Key => Value}, T);
parse_opt_member(_Object, [Token | _]) ->
  throw({illegal_token, Token}).
%%---------------------------------------------------------------------------------------------------------------------
%% @doc
%% @end
%%
parse_property_value([]) ->
  throw(unexpected_eof);
parse_property_value([{colon, _} | Tokens]) ->
  parse_value(Tokens);
parse_property_value([Token | _]) ->
  throw({illegal_token, Token}).  
%%---------------------------------------------------------------------------------------------------------------------
%% @doc
%% @end
%%
parse_array(Tokens) ->
  Array = [],
  parse_item(Array, Tokens).
%%---------------------------------------------------------------------------------------------------------------------
%% @doc
%% @end
%%
parse_item(_Array, []) ->
  throw(unexpected_eof);
parse_item(Array, [{rsquare, _} | Tokens]) ->
  {ok, lists:reverse(Array), Tokens};
parse_item(Array, Tokens) ->
  {ok, Value, T} = parse_value(Tokens),
  parse_opt_item([Value | Array], T).
%%---------------------------------------------------------------------------------------------------------------------
%% @doc
%% @end
%%
parse_opt_item(_Array, []) ->
  throw(unexpected_eof);
parse_opt_item(Array, [{rsquare, _} | Tokens]) ->
  {ok, lists:reverse(Array), Tokens};
parse_opt_item(Array, [{comma, _} | Tokens]) ->
  {ok, Value, T} = parse_value(Tokens),
  parse_opt_item([Value | Array], T);
parse_opt_item(_Array, [Token | _]) ->
  throw({illegal_token, Token}).
%%---------------------------------------------------------------------------------------------------------------------