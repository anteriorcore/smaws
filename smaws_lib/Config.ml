type custom_endpoint = { uri : Uri.t; headers : (string * string) list option }

type t = {
  resolveAuth : unit -> Auth.t;
  resolveRegion : unit -> string;
  endpoint : string -> custom_endpoint option;
}

let default_endpoint (service : string) : custom_endpoint option =
  service |>
    String.uppercase_ascii |>
    (^) "AWS_ENDPOINT_URL_" |>
    Sys.getenv_opt |>
    Option.fold ~none:(Sys.getenv_opt "AWS_ENDPOINT_URL") ~some:Option.some |>
    Option.map (fun s -> { uri = Uri.of_string s; headers = None; })

(** Create a default configuration which derives the region and authorization from the environment
*)
let defaultConfig () : t =
  let resolveRegion () =
    let region = Sys.getenv_opt "AWS_REGION" |> Option.value ~default:"us-east-1" in
    region
  in
  let resolveAuth () =
    let auth = Auth.Environment.resolve () in
    auth
  in
  { resolveRegion; resolveAuth; endpoint = default_endpoint; }

let make ?endpoint ~resolveRegion ~resolveAuth () = {
    resolveAuth;
    resolveRegion;
    endpoint = Option.value ~default:default_endpoint endpoint;
  }
