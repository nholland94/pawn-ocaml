open Ocamlbuild_plugin

let find_headers dir =
  dir
    |> Pathname.readdir
    |> Array.to_list
    |> List.filter (fun name -> Pathname.get_extension name = "h")
    |> List.map (Pathname.concat dir)

let () =
  dispatch (function
    | Before_rules ->
        (* pawncc rule *)
        rule "%.p -> %.amx"
          ~prod:"%.amx"
          ~dep:"%.p"
          (fun env _build ->
            let source = env "%.p" in
            let target = env "%.amx" in
            Cmd (S [A "pawncc"; P source; A ("-o" ^ target)]))
    | After_rules ->
        (* include_pawn, use_pawn *)
        ocaml_lib "pawn";

        (* use_amxwrap *)
        dep ["link"; "ocaml"; "use_amxwrap"] ["libamxwrap.a"];
        flag ["link"; "library"; "ocaml"; "byte"; "use_amxwrap"]
          (S [A "-dllib"; A "-lamxwrap"; A "-cclib"; A "-lamxwrap"]);
        flag ["link"; "library"; "ocaml"; "native"; "use_amxwrap"]
          (S [A "-cclib"; A "-lamxwrap"]);

        (* include_pawn_amx *)
        dep ["c"; "compile"; "include_pawn_amx"] (find_headers "pawn/amx" @ find_headers "pawn/linux");
        flag ["c"; "compile"; "include_pawn_amx"]
          (S [A "-ccopt"; A "-Ipawn/amx"; A "-ccopt"; A "-Ipawn/linux"])
    | _ -> ())
