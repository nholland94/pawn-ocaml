open Ocamlbuild_plugin

let find_headers dir =
  dir
    |> Pathname.readdir
    |> Array.to_list
    |> List.filter (fun name -> Pathname.get_extension name = "h")
    |> List.map (Pathname.concat dir)

let () =
  dispatch (function
    | After_rules ->
        ocaml_lib "pawn";

        dep ["link"; "ocaml"; "use_amxwrap"] ["libamxwrap.a"];
        flag ["link"; "library"; "ocaml"; "byte"; "use_amxwrap"]
          (S [A "-dllib"; A "-lamxwrap"; A "-cclib"; A "-lamxwrap"]);
        flag ["link"; "library"; "ocaml"; "native"; "use_amxwrap"]
          (S [A "-cclib"; A "-lamxwrap"]);

        dep ["c"; "compile"; "include_pawn_amx"] (find_headers "pawn/amx" @ find_headers "pawn/linux");
        flag ["c"; "compile"; "include_pawn_amx"]
          (S [A "-ccopt"; A "-Ipawn/amx"; A "-ccopt"; A "-Ipawn/linux"]);

        flag ["link"; "library"; "ocaml"; "byte"; "use_libdl"]
          (S [A "-dllib"; A "-ldl"; A "-cclib"; A "-ldl"]);
        flag ["link"; "library"; "ocaml"; "native"; "use_libdl"]
          (S [A "-cclib"; A "-ldl"])
    | _ -> ())
