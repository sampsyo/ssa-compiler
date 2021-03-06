%{
open Ast

let parse_sequence c1 c2 =
  match c1, c2 with
  | CSeq cmds1, CSeq cmds2 -> CSeq (cmds1 @ cmds2)
  | c, CSeq cmds           -> CSeq (c :: cmds)
  | CSeq cmds, c           -> CSeq (cmds @ [c])
  | c1, c2                 -> CSeq ([c1; c2])
%}

%token <float> FLOAT
%token <string> VAR
%token  
ADD SUBTRACT MULTIPLY DIVIDE NEGATE SQRT ABS
EQUALS NOTEQUALS LESS LESSEQ GREATER GREATEREQ AND OR
IF PHI LPAREN RPAREN ASSIGN SEMI COMMA LBRACE RBRACE PRINT EOF

%type <Ast.value> value
%type <Ast.expr> expr
%type <Ast.com> com
%type <Ast.com> prog

%start prog
 
%%

/* Values */
value :
  | FLOAT                 { VFloat($1) }
  | VAR                   { VVar($1) }
  | LPAREN value RPAREN   { $2 }

/* Unary operations */
unop: 
  | NEGATE                { UNeg }
  | SQRT                  { USqrt }
  | ABS                   { UAbs }

/* Binary operations */
binop :
  | ADD                   { BAdd }
  | SUBTRACT              { BSub }
  | MULTIPLY              { BMul }
  | DIVIDE                { BDiv }
  | EQUALS                { BEquals }
  | NOTEQUALS             { BNotEquals }
  | LESS                  { BLess }
  | LESSEQ                { BLessEq }
  | GREATER               { BGreater }
  | GREATEREQ             { BGreaterEq }
  | AND                   { BAnd }
  | OR                    { BOr }


/* Expressions */
expr :
  | value                             { EValue($1) }
  | binop value value                 { EOp(OInternal($1), [$2; $3]) }
  | unop value                        { EOp(OInternal($1), [$2]) }
  | PHI LPAREN VAR COMMA VAR RPAREN   { EPhi($3, $5) }

/* Commands */
com :
  | acom                  { $1 }
  | acom com              { parse_sequence $1 $2 } 

acom : 
  | VAR ASSIGN expr SEMI                    { CAssgn($1, $3) }
  | PRINT expr SEMI                         { CPrint $2 }
  | LBRACE com RBRACE                       { $2 }
  | IF LPAREN VAR RPAREN LBRACE com RBRACE { CIf ($3, $6) }

/* Programs */
prog :
  | com EOF               { $1 }
