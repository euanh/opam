(**************************************************************************)
(*                                                                        *)
(*    Copyright 2012-2013 OCamlPro                                        *)
(*    Copyright 2012 INRIA                                                *)
(*                                                                        *)
(*  All rights reserved.This file is distributed under the terms of the   *)
(*  GNU Lesser General Public License version 3.0 with linking            *)
(*  exception.                                                            *)
(*                                                                        *)
(*  OPAM is distributed in the hope that it will be useful, but WITHOUT   *)
(*  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY    *)
(*  or FITNESS FOR A PARTICULAR PURPOSE.See the GNU General Public        *)
(*  License for more details.                                             *)
(*                                                                        *)
(**************************************************************************)

include OpamMisc.Base

type variable = t

type variable_contents =
  | B of bool
  | S of string

let string_of_variable_contents = function
  | B b -> string_of_bool b
  | S s -> s

module Full = struct

  type t = {
    package : OpamPackage.Name.t;
    variable: variable;
  }

  let variable t = t.variable
  let package t = t.package

  let create package variable =
    { package; variable }

  let of_string s =
    match OpamMisc.rcut_at s ':' with
    | None -> create OpamPackage.Name.global_config (of_string s)
    | Some (p,v) ->
      let v = of_string v in
      create (OpamPackage.Name.of_string p) v

  let to_string t =
    let prefix =
      let n = OpamPackage.Name.to_string (package t) in
      if n = OpamGlobals.global_config then
        ""
      else
        n in
    let prefix =
      if prefix = "" then
        ""
      else
        prefix ^ ":" in
    prefix ^ to_string t.variable

  let to_json x =
    `String (to_string x)

  module O = struct
    type tmp = t
    type t = tmp
    let compare = compare
    let to_string = to_string
    let to_json = to_json
  end

  module Set = OpamMisc.Set.Make(O)

  module Map = OpamMisc.Map.Make(O)

end
