type protocol = AwsJson_1_0 | AwsJson_1_1 | RestXml | Ec2Query | RestJson | AwsQuery

type descriptor = {
  namespace : string;
  endpointPrefix : string;
  version : string;
  protocol : protocol;
}

let makeUri ~(config : Config.t) ~(service : descriptor) =
  let default_uri =
    Uri.make ~scheme:"https"
      ~host:(Printf.sprintf "%s.%s.amazonaws.com" service.endpointPrefix (config.resolveRegion ()))
      ~path:"/" ()
  in
  service.endpointPrefix |>
    config.endpoint |>
    Option.map (fun ep -> Uri.resolve "https" default_uri ep.Config.uri) |>
    Option.value ~default:default_uri
