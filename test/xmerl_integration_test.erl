-module(xmerl_integration_test).

-include_lib("eunit/include/eunit.hrl").

-include_lib("xmerl/include/xmerl.hrl").


raw_xmerl_test() ->
  ?assertExit({bad_character_code, _, _}, xmerl_scan:file("../priv/rus.xml")).

prepared_xmerl_test_() ->
  {
    setup,
    fun() ->
      application:start(iconv)
    end,
    fun(_) ->
      application:stop(iconv)
    end,
    [
      ?_test(
        begin
          {ok, Data} = file:read_file("../priv/rus.xml"),
          {Parsed, []} = xmerl_scan:string(exemel:prepare(binary_to_list(Data))),
          ?assertMatch(
            #xmlElement{
                  name = 'Name',
                  content = [#xmlText{}]
            },
            Parsed
          ),
          [Content] = Parsed#xmlElement.content,
          ?debugVal(Content#xmlText.value),
          Text = "Австралийский доллар",
          ?assertEqual(
            Text,
            unicode:characters_to_list(Content#xmlText.value, unicode)
          )
        end
      )
    ]
  }.