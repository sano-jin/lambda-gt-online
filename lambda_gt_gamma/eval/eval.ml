open Parse
include Syntax
include Preprocess
include Match_atoms
include Match_ctxs
include Match
include Pushout

let ctx_of (x, args) = (x, List.map (fun x -> FreeLink x) args)

let rec eval theta = function
  | Graph graph -> fuse_fusions @@ synthesis theta graph
  | App (e1, e2) -> (
      let v1 : graph = eval theta e1 in
      let v2 : graph = eval theta e2 in
      match v1 with
      | [ ((_, Lam (ctx, e, theta)), _) ] ->
          let ctx = ctx_of ctx in
          let theta = (ctx, v2) :: theta in
          eval theta e
      | [ (((_, RecLam (ctx1, ctx2, e, theta)), _) as rec_lam) ] ->
          let ctx1 = ctx_of ctx1 in
          let ctx2 = ctx_of ctx2 in
          let theta = (ctx1, [ rec_lam ]) :: (ctx2, v2) :: theta in
          eval theta e
      | _ -> failwith @@ "function expected but got " ^ string_of_graph v1)
  | Case (e1, template, e2, e3) -> (
      let v1 = eval theta e1 in
      let _, template = Preprocess.alpha100 template in
      match match_atoms template v1 with
      | None -> eval theta e3
      | Some theta2 ->
          let theta = theta2 @ theta in
          eval theta e2)
  | Let (ctx, e1, e2) ->
      let v1 = eval theta e1 in
      let ctx = ctx_of ctx in
      let theta = (ctx, v1) :: theta in
      eval theta e2
  | LetRec (ctx1, ctx2, e1, e2) ->
      let rec_lam = (Util.unique (), RecLam (ctx1, ctx2, e1, theta)) in
      let ctx = ctx_of ctx1 in
      let theta = (ctx, [ (rec_lam, snd ctx) ]) :: theta in
      eval theta e2

let eval = eval []
