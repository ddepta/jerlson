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

-module(jerlson).

%% API
-export([load/1]).
-export([load_file/1]).
-export([dump/1]).
-export([dump_file/2]).

%%%==================================================================================================================== 
%%% API                                  
%%%====================================================================================================================

%%---------------------------------------------------------------------------------------------------------------------
%% @doc
%% @end
%%
load(<<>>) ->
  {error, invalid_payload};
load(String) when is_list(String) ->
  try unicode:characters_to_binary(String, utf8) of
  	Input ->
  		load(Input)
  catch
  	_:_ ->
  		{error, invalid_payload}
  end;
load(Input) when is_binary(Input) ->
  case jerlson_lexer:parse(Input) of
    {ok, Tokens} ->
      % io:format("~p~n", [Tokens]),
      case jerlson_parser:parse(Tokens) of
      	{ok, Value} ->
      		{ok, Value};
      	{error, Reason} ->
      	  {error, Reason}
      end;
    {error, Reason} ->
      {error, Reason}
  end;
load(_) ->
  {error, invalid_payload}.
%%---------------------------------------------------------------------------------------------------------------------
%% @doc
%% @end
load_file(FileName) ->
  case file:read_file(FileName) of
    {ok, Data} ->
      load(Data);
    {error, Reason} ->
      {error, Reason}
  end.
%%---------------------------------------------------------------------------------------------------------------------
%% @doc
%% @end
%%
dump(Term) ->
  try jerlson_builder:json(Term) of
    Json -> 
      {ok, Json}
  catch
    _:Reason -> 
      {error, Reason}
  end.
%%---------------------------------------------------------------------------------------------------------------------
%% @doc
%% @end
%%
dump_file(Term, FileName) ->
  try jerlson_builder:json(Term) of
    Json -> 
      file:write_file(FileName, Json)
  catch
    _:Reason -> 
      {error, Reason}
  end.
%%---------------------------------------------------------------------------------------------------------------------

%%%====================================================================================================================
%%% Internal functions 
%%%====================================================================================================================