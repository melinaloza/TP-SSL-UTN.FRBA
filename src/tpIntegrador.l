%{
    #include "tpIntegrador.tab.h"
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
%}

%option yylineno
%option noyywrap

/* Tipos de datos  */
TIPO_DATO ("void"|"char"|"short"|"int"|"long"|"float"|"double"|"signed"|"unsigned")

/*Palabras reservadas*/
SIZEOF "sizeof"

/*Valores numericos*/
DECIMAL_CON_CERO [0-9]
DECIMAL_SIN_CERO [1-9]
OCTAL [0-7] 
HEXADECIMAL [a-fA-F0-9] 
CTE_REAL (({DECIMAL_CON_CERO}+)"."{DECIMAL_CON_CERO}*)
/*CTE_REAL (({DECIMAL_CON_CERO}+)"."{DECIMAL_CON_CERO}*)*/

/*Operadores logicos*/
OP_O_LOGICO "||"
OP_Y_LOGICO "&&"
OP_O_INCLUSIVO "|"

/*Operadores de asignacion*/
OP_ASIGNACION ("="|"+="|"-="|"*="|"/=") 

/*Operadores de comparacion*/
OP_IGUALDAD ("==")
OP_DESIGUALDAD ("!=")
OP_RELACIONAL ("<"|">"|"<="|">=")

/*Operadores matematicos*/
OP_DIVISION ("/")
OP_PORCENTAJE ("%")

/*Operadores de aumento o disminucion directa en 1*/
OP_INCREMENTO ("++")
OP_DECREMENTO ("--")

/*Sufijos*/
SUFIJO_ENTERO (u|U)
SUFIJO_REAL (f|F)

/*Secuencias de escape de C*/
SECUENCIA_ESCAPE_SIMPLE (a|b|f|n|r|t|v|\'|\"|\?|\\) 


%%

[a-zA-Z_][a-zA-Z0-9_]*                                      { yylval.cadena =   strdup(yytext);             return IDENTIFICADOR;}

"\n" { return '\n'; }
" "|"\t"

","|"?"|":"|"("|")"|"["|"]"|"="|"{"|"}"|";"|"*"|"&"|"+"|"-"|"!" { return yytext[0]; }

"do"          { return DO;        }
"while"       { return WHILE;     }

"if"          { return IF;        }
"else"        { return ELSE;      }

"switch"      { return SWITCH;    }
"case"        { return CASE;      }
"default"     { return DEFAULT;   }
"break"       { return BREAK;     }
"continue"    { return CONTINUE;  }

"for"         { return FOR;       }

"return"      { return RETURN;    }
                                                                                            
{DECIMAL_SIN_CERO}{DECIMAL_CON_CERO}*{SUFIJO_ENTERO}?                                           { yylval.entero =   atoi(yytext);               return CTE_DECIMAL;       }
0{OCTAL}*{SUFIJO_ENTERO}?                                                                       { yylval.entero =   atoi(yytext);               return CTE_OCTAL;         }
0[xX]{HEXADECIMAL}+{SUFIJO_ENTERO}?                                                             { yylval.entero =   atoi(yytext);               return CTE_HEXADECIMAL;   }
{CTE_REAL}{SUFIJO_REAL}?                                                                        { yylval.real =     strtol(yytext, NULL, 0);    return CTE_REAL;          }
                                                                                           
{TIPO_DATO}                                                                                     { yylval.cadena = strdup(yytext); return TIPO_DATO; }
                       

{SIZEOF}                  { return SIZEOF;          }           

{OP_O_LOGICO}             { return OP_O_LOGICO;     }         
{OP_Y_LOGICO}             { return OP_Y_LOGICO;     }         
{OP_O_INCLUSIVO}          { return OP_O_INCLUSIVO;  }      

{OP_ASIGNACION}           { return OP_ASIGNACION;   }       

{OP_IGUALDAD}             { return OP_IGUALDAD;     }         
{OP_DESIGUALDAD}          { return OP_DESIGUALDAD;  }         
{OP_RELACIONAL}           { return OP_RELACIONAL;   }       

{OP_DIVISION}             { return OP_DIVISION;     }       
{OP_PORCENTAJE}           { return OP_PORCENTAJE;   }       

{OP_INCREMENTO}           { return OP_INCREMENTO;   }                  
{OP_DECREMENTO}           { return OP_DECREMENTO;   }                  


\"(([^\"]|\\\")*[^\\])?\"                                   { yylval.cadena =   strdup(yytext);             return CTE_CADENA;}
\'([^\\\']|\\{SECUENCIA_ESCAPE_SIMPLE})                     { yylval.entero =   atoi(yytext);               return CTE_CARACTER;}

.                                                           {printf("\nError Lexico: El caracter %c no fue reconocido.", yytext[0]);}

%%