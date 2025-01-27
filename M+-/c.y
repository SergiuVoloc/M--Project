%{

#include <stdio.h>
#include "ast.h"


Node* astRoot = NULL;
int yyerror(char * s);
extern int yylex(void);

%}
%union{
	
	Node	*node;
	char* strings;
	int intVal;
	float realVal;
	bool boolVal;
}

%token END 
%token INT 
%token WHILE 
%token FLOAT 
%token <strings> IF 
%token <strings> ELSE 
%token RETURN 
%token STRING_LITERAL 
%token ASSIGN 
%token <strings> ADD 
%token <boolVal> BOOL 
%token <strings> IDENTIFIER
%token AND 
%token <strings> BVAL 
%token CEIL 
%token CLPAR 
%token COLON 
%token COMMA 
%token CRPAR 
%token <strings> DIV 
%token DO 
%token <strings> EQUAL 
%token FLOOR 
%token FUN 
%token <strings> GE 
%token <strings> GT 
%token <strings> ID 
%token <intVal> IVAL 
%token <strings> LE 
%token <strings> MUL 
%token NOT 
%token OR 
%token READ 
%token RPAR 
%token <realVal> RVAL   
%token REAL 
%token PRINT
%token SEMICOLON 
%token SIZE 
%token SLPAR 
%token SRPAR 
%token <strings> SUB 
%token <strings> THEN 
%token VAR 
%token LPAR 
%token <strings> LT 
%token BEGINN

%type <node> prog
%type <node> block
%type <node> declarations
%type <node> declaration
%type <node> var_declaration
%type <node> type
%type <node> array_dimensions
%type <node> fun_declaration
%type <node> fun_block 
%type <node> param_list
%type <node> parameters
%type <node> more_parameters
%type <node> basic_declaration
%type <node> basic_array_dimensions
%type <node> program_body
%type <node> fun_body
%type <node> prog_stmts
%type <node> prog_stmt
%type <node> identifier
%type <node> expr
%type <node> bint_term
%type <node> bint_factor
%type <node> compare_op
%type <node> int_expr
%type <node> addop
%type <node> int_term
%type <node> mulop 
%type <node> int_factor
%type <node> modifier_list
%type <node> arguments
%type <node> more_arguments



%start prog
%%


prog 
 : block													{ $$ = createProgNode($1); astRoot = $$;}
 ;


block
 : declarations program_body								{ $$ = createBlockNode($1,$2);}
 ;			


declarations
 : declaration SEMICOLON declarations						{ $$ = $3; addLinkToList($$, $1);}	
 |															{ $$ = createEmptyListNode("Declarations");}			
 ;


declaration
 : var_declaration											{ $$ = createDeclarationNode($1);}
 | fun_declaration											{ $$ = createDeclarationNode($1);}
 ;	


var_declaration
 : VAR ID array_dimensions COLON type						{ $$ = createVarDeclarationNode($2 ,$3, $5);}
 ;


type 
 : INT														{ $$ = createType("INT");}
 | REAL														{ $$ = createType("REAL");}
 | BOOL														{ $$ = createType("BOOL");}
 ;

array_dimensions
 : SLPAR expr SRPAR array_dimensions						{ $$ = $4; addLinkToList($$, $2);}															 	
 |															{ $$ = createEmptyListNode("ArrayDimensions");}
 ;


fun_declaration
 : FUN ID param_list COLON type CLPAR fun_block CRPAR		{ $$ = createFunDeclarationNode($2, $3, $5, $7);}  
 ;


fun_block
 : declarations fun_body									{ $$ = createFunBlockNode($1, $2);} 
 ;


param_list
 : LPAR parameters RPAR										{ $$ = createListNode("ParametersList", $2);} 			
 ;


parameters
 : basic_declaration more_parameters						{ $$ = createParametersNode($1, $2);}
 |															{ $$ = createEmptyListNode("Parameters");}
 ;

more_parameters												
 : COMMA basic_declaration more_parameters					{ $$ = $3; addLinkToList($$, $2);}		
 |															{ $$ = createEmptyListNode("MoreParameters");}
 ;

basic_declaration
 : ID basic_array_dimensions COLON type						{ $$ = createBasicDeclarationNode($1,$2, $4);}
 ;

basic_array_dimensions 
 : SLPAR SRPAR basic_array_dimensions						{ $$ = $3; addLinkToList($$, NULL);}		
 |															{ $$ = createEmptyListNode("BasicArrayDimensions");}
 ;
									
program_body																						
 : BEGINN prog_stmts END									{ $$ = createProgramBodyNode($2);}
 ;

fun_body 
 : BEGINN prog_stmts RETURN expr SEMICOLON END				{ $$ = createFunBodyNode($2,$4);}
 ;

prog_stmts		
 : prog_stmt SEMICOLON prog_stmts							{ $$ = $3; addLinkToList($$, $1);}	
 |															{ $$ = createEmptyListNode("ProgramStatementEmpty");}
 ;

 prog_stmt
  : IF expr THEN prog_stmt ELSE prog_stmt					{ $$ = createIfStatement($1, $2, $3, $4, $5, $6);}
  | WHILE expr DO prog_stmt									{ $$ = createWhileStatement($2, $4);}
  | READ identifier											{ $$ = Prog_stms_read_identifier($2);}
  | identifier ASSIGN expr									{ $$ = createProgStmt_assign_expr($1,$3);}
  | PRINT expr												{ $$ = createProgStmt_print_expr($2);}
  | CLPAR block CRPAR										{ $$ = createProgStmt_block($2);}
  ;

 

identifier
 : ID array_dimensions										{ $$ = createIdentifierNode($1,$2);} 
 ;

expr
 : expr OR bint_term										{ $$ = $1; addLinkToList($$, $3); }	
 | bint_term												{ $$ = createListNode("Bind_term_expr", $1);}
 ;
				
bint_term 
 : bint_term AND bint_factor								{ $$ = $1; addLinkToList($$, $3); }	
 | bint_factor												{ $$ = createListNode("Bind_term_factor", $1);}
 ;	
						
bint_factor 
 : NOT bint_factor											{ $$ = $2; addLinkToList($$, NULL);}	
 | int_expr compare_op int_expr								{ $$ = createBintFactorNode($1,$2,$3);}
 | int_expr													{ $$ = createListNode("Bind_factor_int_expr", $1);}	
 ;
				
compare_op 
 : EQUAL													{ $$ = createEqualNode($1);}
 | LT														{ $$ = createLessThanNode($1);}
 | GT														{ $$ = createGreaterNode($1);}
 | LE														{ $$ = createLessOrEqualNode($1);}
 | GE														{ $$ = createGreaterOrEqualNode($1);}
 ;

int_expr						
 : int_expr addop int_term									{ $$ = $1; addLinkToList($$, $3); }	
 | int_term													{ $$ = createListNode("Int_expr_term", $1);}
 ;

addop 
 : ADD														{ $$ = createAdditionNode($1);}
 | SUB														{ $$ = createSubtractionNode($1);}
 ;

int_term
 : int_term mulop int_factor								{ $$ = $1; addLinkToList($$, $3); }		
 | int_factor												{ $$ = createListNode("Int_term_factor", $1);}
 ;

mulop
 : MUL														{ $$ = createMultiplyNode($1);}
 | DIV														{ $$ = createDivideNode($1);}
 ;
					
int_factor									
 : LPAR expr RPAR											{ $$ = createIntFactorExprNode($2);}
 | SIZE LPAR ID basic_array_dimensions RPAR					{ $$ = createIntFactorArrayDimNode($4);}
 | FLOAT LPAR expr RPAR										{ $$ = createIntFactorFloatExprNode($3);}
 | FLOOR LPAR expr RPAR										{ $$ = createIntFactorFloorExprNode($3);}
 | CEIL LPAR expr RPAR										{ $$ = createIntFactorCeilExprNode($3);}
 | ID modifier_list											{ $$ = createIntFactorModifierListNode($1,$2);}
 | IVAL														{ $$ = createIntFactorIvalNode($1);}	
 | RVAL														{ $$ = createIntFactorRvalNode($1);}
 | BVAL														{ $$ = createIntFactorBvalNode($1);}
 | SUB int_factor											{ $$ = createSubstractOperation($1,$2); }		
 ;					
  
modifier_list 
 : LPAR arguments RPAR										{ $$ = createModifierListArgumentsNode($2);}
 | array_dimensions											{ $$ = createModifierListArrayDimNode($1);}
 ;

arguments
 : expr more_arguments										{ $$ = createArgumentsNode($1,$2);}
 |															{ $$ = createEmptyListNode("Arguments");}
 ;

more_arguments	
 : COMMA expr more_arguments								{ $$ = $3; addLinkToList($$, $2);}	
 |															{ $$ = createEmptyListNode("MoreArguments");}
 ;
								
%%

int yyerror(char * s) 
/* yacc error handler */
{    
	printf ( "%s\n", s); 
	return 0;
}  