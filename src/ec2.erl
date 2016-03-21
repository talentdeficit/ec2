-module(ec2).
-export([ami_id/0, ami_id/1]).
-export([hostname/0, hostname/1]).
-export([instance_id/0, instance_id/1]).
-export([local_hostname/0, local_hostname/1]).
-export([local_ipv4/0, local_ipv4/1]).
-export([availability_zone/0, availability_zone/1]).
-export([public_hostname/0, public_hostname/1]).
-export([public_ipv4/0, public_ipv4/1]).
-export([region/0, region/1]).
-export([iam_role/0, iam_role/1]).
-export([security_credentials/0, security_credentials/1]).

-define(METADATA_HOST, "169.254.169.254").


-spec ami_id() -> Result when
  Result :: iodata().
ami_id() ->
  URI = uri("ami-id"),
  fetch(URI).

-spec ami_id(Version) -> Result when
  Version :: iodata(),
  Result :: iodata().
ami_id(Version)
when is_atom(Version); is_binary(Version) ->
  URI = uri(Version, "ami-id"),
  fetch(URI).


-spec hostname() -> Result when
  Result :: iodata().
hostname() ->
  URI = uri("hostname"),
  fetch(URI).

-spec hostname(Version) -> Result when
  Version :: iodata(),
  Result :: iodata().
hostname(Version)
when is_atom(Version); is_binary(Version) ->
  URI = uri(Version, "hostname"),
  fetch(URI).


-spec instance_id() -> Result when
  Result :: iodata().
instance_id() ->
  URI = uri("instance-id"),
  fetch(URI).

-spec instance_id(Version) -> Result when
  Version :: iodata(),
  Result :: iodata().
instance_id(Version)
when is_atom(Version); is_binary(Version) ->
  URI = uri(Version, "instance-id"),
  fetch(URI).


-spec local_hostname() -> Result when
  Result :: iodata().
local_hostname() ->
  URI = uri("local-hostname"),
  fetch(URI).

-spec local_hostname(Version) -> Result when
  Version :: iodata(),
  Result :: iodata().
local_hostname(Version)
when is_atom(Version); is_binary(Version) ->
  URI = uri(Version, "local-hostname"),
  fetch(URI).


-spec local_ipv4() -> Result when
  Result :: iodata().
local_ipv4() ->
  URI = uri("local-ipv4"),
  fetch(URI).

-spec local_ipv4(Version) -> Result when
  Version :: iodata(),
  Result :: iodata().
local_ipv4(Version)
when is_atom(Version); is_binary(Version) ->
  URI = uri(Version, "local-ipv4"),
  fetch(URI).


-spec availability_zone() -> Result when
  Result :: iodata().
availability_zone() ->
  URI = uri(["placement", "/", "availability-zone"]),
  fetch(URI).

-spec availability_zone(Version) -> Result when
  Version :: iodata(),
  Result :: iodata().
availability_zone(Version)
when is_atom(Version); is_binary(Version) ->
  URI = uri(Version, ["placement", "/", "availability_zone"]),
  fetch(URI).


-spec public_hostname() -> Result when
  Result :: iodata().
public_hostname() ->
  URI = uri("public-hostname"),
  fetch(URI).

-spec public_hostname(Version) -> Result when
  Version :: iodata(),
  Result :: iodata().
public_hostname(Version)
when is_atom(Version); is_binary(Version) ->
  URI = uri(Version, "public-hostname"),
  fetch(URI).


-spec public_ipv4() -> Result when
  Result :: iodata().
public_ipv4() ->
  URI = uri("public-ipv4"),
  fetch(URI).

-spec public_ipv4(Version) -> Result when
  Version :: iodata(),
  Result :: iodata().
public_ipv4(Version)
when is_atom(Version); is_binary(Version) ->
  URI = uri(Version, "public-ipv4"),
  fetch(URI).


-spec region() -> Result when
  Result :: iodata().
region() ->
  URI = uri(dynamic, ["instance-identity", "/", "document"]),
  fetch(URI, region).

-spec region(Version) -> Result when
  Version :: iodata(),
  Result :: iodata().
region(Version)
when is_atom(Version); is_binary(Version) ->
  URI = uri(dynamic, Version, ["instance-identity", "/", "document"]),
  fetch(URI, region).


-spec iam_role() -> Result when
  Result :: iodata().
iam_role() ->
  URI = uri(["iam", "/", "security-credentials", "/"]),
  fetch(URI).

-spec iam_role(Version) -> Result when
  Version :: iodata(),
  Result :: iodata().
iam_role(Version)
when is_atom(Version); is_binary(Version) ->
  URI = uri(Version, ["iam", "/", "security-credentials", "/"]),
  fetch(URI).


-spec security_credentials() -> Result when
  Result :: map().
security_credentials() ->
  Role = iam_role(),
  URI = uri(["iam", "/", "security-credentials", "/", Role]),
  fetch(URI, security_credentials).

-spec security_credentials(Version) -> Result when
  Version :: iodata(),
  Result :: map().
security_credentials(Version) ->
  Role = iam_role(Version),
  URI = uri(["iam", "/", "security-credentials", "/", Role]),
  fetch(URI, security_credentials).


uri(Entry) when is_list(Entry) ->
  ["http://" ?METADATA_HOST, "/latest/meta-data/", Entry].

uri(dynamic, Entry) when is_list(Entry) ->
  ["http://", ?METADATA_HOST, "/latest/dynamic/", Entry];
uri(Version, Entry) when is_list(Entry) ->
  ["http://", ?METADATA_HOST, "/", Version, "/meta-data/", Entry].

uri(dynamic, Version, Entry) when is_list(Entry) ->
  ["http://", ?METADATA_HOST, "/", Version, "/dynamic/", Entry].


fetch(URI) -> fetch(URI, iodata).

fetch(URI, ConvertTo) ->
  case httpc:request(lists:flatten(URI)) of
    {ok, {{_, 200, _}, _, Data}} -> convert(Data, ConvertTo);
    {ok, {{_, 404, _}, _, _}}    -> erlang:error(badarg);
    {error, {connect_failed, _}} -> erlang:error(connect_failed);
    {error, {send_failed, _}}    -> erlang:error(send_failed)
  end.

convert(Data, iodata)  -> Data;
convert(Data, region)  ->
  case jsx:decode(unicode:characters_to_binary(Data), [return_maps]) of
    #{<<"region">> := Region} -> Region
  end;
convert(Data, security_credentials) ->
  case jsx:decode(unicode:characters_to_binary(Data), [return_maps]) of
    Map when is_map(Map) -> Map
  end.
  