(**  Parser *)

%{
  open Syntax
%}

(** tokens with values *)
(** Symbol atom name *)
%token <string> VAR    (** X, Y, ABC, ... *)
%token <string> CONSTR (** x, y, abc, ... *)

(** link name *)
%token <string> LINK   (** _X, _Y, _ABC, ...  *)

(** operators *)
%token DOT            (**  '.' *)
%token COMMA          (**  ',' *)
%token NU             (**  "nu" *)
%token NECKTIE        (**  "><" *)
%token CASE           (**  "case" *)
%token OF             (**  "of" *)
%token ARROW          (**  "->" *)
%token LAMBDA         (**  "\\" *)
%token OTHERWISE      (**  "otherwise" *)
%token VBAR           (**  "|" *)
%token LET            (**  "let" *)
%token REC            (**  "rec" *)
%token IN             (**  "in" *)
%token EQ             (**  "=" *)

(**  Parentheses *)
%token LPAREN         (**  '(' *)
%token RPAREN         (**  ')' *)
%token LBRACKET       (**  '[' *)
%token RBRACKET       (**  ']' *)
%token LCBRACKET      (**  '{' *)
%token RCBRACKET      (**  '}' *)
%token LT             (**  '(' *)
%token GT             (**  ')' *)

(**  End of file *)
%token EOF

(**  Operator associativity *)
%nonassoc  DOT
%left      COMMA


%start graph_eof
%type <Syntax.graph> graph_eof

%start exp_eof
%type <Syntax.exp> exp_eof

%%


(** inner arguments of an atom *)

(**  arguments of an atom separated by comma without parentheses *)
args_inner:
  | separated_list(COMMA, LINK) { $1 }


(** Syntax for an atom *)

atom_name:
 | CONSTR { PConstr ($1) }
 | LT LAMBDA ctx DOT exp GT { PLam ($3, $5) }


atom:
  | atom_name				            { Atom ($1, []) }	(** e.g. a *)
  | atom_name LPAREN args_inner RPAREN	{ Atom ($1, $3) }	(** e.g. a(X_1, ..., X_m) *)
  | LINK NECKTIE LINK                   { Atom (PConstr "><", [$1; $3]) }


ctx:
  | VAR { ($1, []) }	(** e.g. a *)
  | VAR LBRACKET args_inner RBRACKET { ($1, $3) }	(** e.g. a(X_1, ..., X_m) *)



(**  proccesses separeted by comma *)
graph:
  | atom { $1 }

  | ctx { let (v, args) = ($1) in Ctx (v, args) }	(** e.g. a *)

  | graph COMMA graph { Mol ($1, $3) }

  | NU LINK DOT graph { Nu ($2, $4) }

  | LPAREN graph RPAREN { $2 }



(** the whole program *)
graph_eof:
  | graph EOF { $1 }


exp_single:
 | LCBRACKET graph RCBRACKET { Graph ($2) }

 | CASE exp OF LCBRACKET graph RCBRACKET ARROW exp VBAR OTHERWISE ARROW exp 
     { Case ($2, $5, $8, $12) }
 
 | LET REC ctx ctx EQ exp IN exp 
     { LetRec ($3, $4, $6, $8) }
 
 | LET ctx EQ exp IN exp 
     { Let ($2, $4, $6) }
 
 | LPAREN exp RPAREN { $2 }


exp:
 | exp exp_single { App ($1, $2) }
 | exp_single { $1 }



(** the whole program *)
exp_eof:
  | exp EOF { $1 }





