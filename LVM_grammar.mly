
%token Newline EQ EOF
%token <string> Quoted
%token <string> ID

%start lines
%type <(string * string) list list> lines

%%

lines:
	| { [] }
	| line; Newline; lines { $1 :: $3 }
;

line:
	| { [] }
	| ID; EQ Quoted; line { ($1, $3) :: $4 }
;
