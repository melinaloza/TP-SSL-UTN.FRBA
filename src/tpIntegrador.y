
%{
    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
    #include "tablaDeSimbolos.c"

    int yylex();
    int yywrap(){ return(1); }
    void yyerror (char const *s) {}

    FILE* yyin;

    extern int yylineno;

    char* tipoAux  = "";
    char* tipoAux1 = "";
    char* tipoAux2 = "";

    char* idAux = ""; 

    int validacionBinaria = 0;

%}


/*UNION*/
%union {
    char* cadena;
    int entero;
    float real;
}


/*--------------TOKENS--------------------*/

/*Token de identificador*/
%token <cadena> IDENTIFICADOR

/*Token de tipos de datos*/
%token <cadena> TIPO_DATO 

/*Token de palabra reservada*/
%token <cadena> SIZEOF  

/*Token de constantes*/
%token <entero> CTE_DECIMAL                   
%token <entero> CTE_OCTAL                         
%token <entero> CTE_HEXADECIMAL               
%token <real>   CTE_REAL  

/*Token de operadores logicos*/
%token <cadena> OP_O_LOGICO                   
%token <cadena> OP_Y_LOGICO                  
%token <cadena> OP_O_INCLUSIVO  

/*Token de asignacion*/
%token <cadena> OP_ASIGNACION                

/*Token de de igualdad y relacionales*/
%token <cadena> OP_IGUALDAD
%token <cadena> OP_DESIGUALDAD                  
%token <cadena> OP_RELACIONAL  

/*Token de operaciones matematicas*/
%token <cadena> OP_DIVISION 
%token <cadena> OP_PORCENTAJE 

/*Token de Incremento*/
%token <cadena> OP_INCREMENTO                
%token <cadena> OP_DECREMENTO 

/*Token de do/while*/
%token <cadena> DO               
%token <cadena> WHILE

/*Token de if/else*/
%token <cadena> IF
%token <cadena> ELSE

/*Token de switch*/
%token <cadena> SWITCH
%token <cadena> CASE
%token <cadena> DEFAULT
%token <cadena> BREAK
%token <cadena> CONTINUE

/*Token de For*/
%token <cadena> FOR

/*Token de return*/
%token <cadena> RETURN

/*Token de cadena y caracter*/
%token <cadena> CTE_CADENA                                      
%token <entero> CTE_CARACTER

/*--------------TYPES--------------------*/
/*Expresiones*/
%type <cadena> expSufijo
%type <cadena> expPrimaria

/*Para declaraciones*/
%type <cadena> declaracionVariable
%type <cadena> declarador
%type <cadena> unaDeclaracion

/*Para las cadenas (octal, hexa, real, decimal y caracter) */
%type <cadena> constante

%% 

/* A continuacion las reglas gramaticales y las acciones */

input:    /* vacio */
        | input line
;

line: declaracion '\n'            
    | sentencia '\n'        
    | error '\n' { printf("\nSe detecto un ERROR SINTACTICO en la linea %i: %s", yylineno, $<cadena>1);}
    | error ';'  { printf("\nSe detecto un ERROR SINTACTICO en la linea %i: %s", yylineno, $<cadena>1);}
;

/* -------------------------------------------------- DECLARACIONES -------------------------------------------------- */ 

declaracion: declaracionVariable
    |  declaracionFuncion
;

/*DECLARACION DE VARIABLES*/

declaracionVariable: TIPO_DATO  declarador  ';' { tipoAux = strdup($<cadena>1); tipoAux = insertarDeclaradores(tipoAux); agregarSimbolosSinRepetir(tipoAux,idAux, 0);} 
    ;

declarador: unaDeclaracion                  
    | unaDeclaracion '=' inicializador
    | unaDeclaracion ',' declarador
    ;

inicializador: expAsingnacion
    | '{' listaDeInicializadores '}'
    | '{'listaDeInicializadores ',' listaDeInicializadores '}'
    ;

listaDeInicializadores: inicializador
    | listaDeInicializadores ',' inicializador  
    ;


/*DECLARACION DE FUNCIONES*/

declaracionFuncion: TIPO_DATO  IDENTIFICADOR '(' listaParametros_ ')' ';'  { agregarSimbolosSinRepetir($<cadena>1,$<cadena>2, 1);  agregarParametros($<cadena>2); }
    | TIPO_DATO  IDENTIFICADOR '(' listaParametros_ ')' sentenciaCompuesta { agregarSimbolosSinRepetir($<cadena>1,$<cadena>2, 1);  agregarParametros($<cadena>2);}
;

listaDeParametros:   parametro                          
                    | listaDeParametros ',' parametro
;

parametro: TIPO_DATO unaDeclaracion { tipoAux = strdup($<cadena>1); tipoAux = insertarDeclaradores(tipoAux); agregarParametro(&tablaDeParametros, tipoAux); }
;

unaDeclaracion: declaradorDirecto
    ;

declaradorDirecto: IDENTIFICADOR                        { idAux = strdup($<cadena>1); }
    | declaradorDirecto '[' expresionConstante_ ']'     { contador.dimensiones++; }
    ;


/* -------------------------------------------------- EXPRESIONES -------------------------------------------------- */

expresion: expAsingnacion 
    | expresion ',' expAsingnacion
;

expAsingnacion: expCondicional                       
    | expUnaria '=' expAsingnacion 
    | expUnaria OP_ASIGNACION expAsingnacion 
;

expCondicional: expOLogico 
    | expOLogico '?' expresion ':' expCondicional 
;

expOLogico: expYLogico 
    | expOLogico OP_O_LOGICO expYLogico 
;

expYLogico: expOInclusivo 
    | expYLogico OP_Y_LOGICO expOInclusivo 
;

expOInclusivo: expY
    | expOInclusivo OP_O_INCLUSIVO expY  
;

expY: expIgualdad 
    | expY '&' expIgualdad 
;

expIgualdad: expRelacional 
    | expIgualdad OP_IGUALDAD expRelacional 
    | expIgualdad OP_DESIGUALDAD expRelacional
;

expRelacional: expAditiva 
    | expRelacional OP_RELACIONAL expAditiva 
;

expAditiva: expMultiplicativa 
    | expAditiva '+' expMultiplicativa  { numeroDeLinea = yylineno; validacionTipos(tipoAux1, tipoAux2); validacionBinaria = 0;}
    | expAditiva '-' expMultiplicativa  { numeroDeLinea = yylineno; validacionTipos(tipoAux1, tipoAux2); validacionBinaria = 0;}
;

expMultiplicativa: expConversion 
    | expMultiplicativa '*' expConversion                       { numeroDeLinea = yylineno; validacionTipos(tipoAux1, tipoAux2); validacionBinaria = 0;}
    | expMultiplicativa OP_DIVISION expConversion               { numeroDeLinea = yylineno; validacionTipos(tipoAux1, tipoAux2); validacionBinaria = 0;}
    | expMultiplicativa OP_PORCENTAJE expConversion             { numeroDeLinea = yylineno; validacionTipos(tipoAux1, tipoAux2); validacionBinaria = 0;}
    ;

expConversion: expUnaria 
    | '(' TIPO_DATO ')' expConversion 
    ;

expUnaria: expSufijo            
    | OP_INCREMENTO expUnaria
    | OP_DECREMENTO expUnaria
    | opUnario expConversion 
    | SIZEOF expUnaria    
    | SIZEOF '(' TIPO_DATO ')'    
    ;

opUnario:'&'
    |'*'
    |'+'
    |'-'
    |'!'
    ;

expSufijo: expPrimaria 
    | expSufijo '[' expresion ']'           
    | expSufijo '(' listaArgumentos_ ')'       { numeroDeLinea = yylineno; agregarSimbolo(&tablaAuxiliar, $<cadena>1, "-", 1);  tablaAuxiliar->tipoDeParametros = tablaDeParametros; controlDeInvocacion(tablaAuxiliar);  tablaDeParametros = NULL; tablaAuxiliar = NULL; }
    | expSufijo OP_INCREMENTO                       
    ;

listaArgumentos: expAsingnacion            { agregarParametro(&tablaDeParametros, $<cadena>1); } 
    | listaArgumentos ',' expAsingnacion   { agregarParametro(&tablaDeParametros, $<cadena>3); } 
    ;

expPrimaria: IDENTIFICADOR    { tablaAuxiliar = devolverIdentificador($<cadena>1); if(tablaAuxiliar != NULL) (validacionBinaria == 0) ? (tipoAux1 = tablaAuxiliar->tipo) : (tipoAux2 = tablaAuxiliar->tipo) ; validacionBinaria = 1; }  
    | constante                     
    | CTE_CADENA              {(validacionBinaria == 0) ? (tipoAux1 = "char*") : (tipoAux2 = "char*"); validacionBinaria = 1; }
    | '(' expresion ')'
    ;

expresionConstante: expCondicional
    ; 

constante: CTE_DECIMAL   { (validacionBinaria == 0) ? (tipoAux1 = "int"  ) : (tipoAux2 = "int"  ); validacionBinaria = 1; }      
    | CTE_OCTAL          { (validacionBinaria == 0) ? (tipoAux1 = "int"  ) : (tipoAux2 = "int"  ); validacionBinaria = 1; }
    | CTE_HEXADECIMAL    { (validacionBinaria == 0) ? (tipoAux1 = "int"  ) : (tipoAux2 = "int"  ); validacionBinaria = 1; }
    | CTE_REAL           { (validacionBinaria == 0) ? (tipoAux1 = "float") : (tipoAux2 = "float"); validacionBinaria = 1; }  
    | CTE_CARACTER       { (validacionBinaria == 0) ? (tipoAux1 = "char" ) : (tipoAux2 = "char" ); validacionBinaria = 1; }
    ;

/* -------------------------------------------------- SENTENCIAS --------------------------------------------------*/ 

sentencia:  sentenciaDeExpresion      
          | sentenciaCompuesta      
          | sentenciaDeSeleccion    
          | sentenciaDeIteracion    
          | sentenciaEtiquetada     
          | sentenciaDeSalto         
;

sentenciaDeExpresion: expresion_sentencia ';'
    ;

expresion_sentencia: /* */  { printf("\nLinea %i - SENTENCIA - EXPRESION:  VACIA", yylineno);} 
    | expresion
    ;

sentenciaCompuesta:       '{' listaDeDeclaracionesAux listaDeSentenciasAux'}'            { printf("\nLinea %i Se detecto una SENTENCIA-EXPRESION: COMPUESTA", yylineno); }
;

listaDeDeclaraciones:   declaracion
                      | listaDeDeclaraciones declaracion 
;

listaDeSentencias:    sentencia
                    | listaDeSentencias sentencia
;

sentenciaDeSeleccion: IF '(' expresion ')' sentencia                  { printf("\nLinea %i Se detecto una SENTENCIA-SELECCION:  IF", yylineno);    }    
                    | IF '(' expresion ')' sentencia ELSE sentencia   { printf("\nLinea %i Se detecto una SENTENCIA-SELECCION:  IF/ELSE", yylineno);    } 
                    | SWITCH '(' expresion ')' sentencia              { printf("\nLinea %i Se detecto una SENTENCIA-SELECCION:  SWITCH ", yylineno);    }
;

sentenciaDeIteracion: WHILE '(' expresion ')' sentencia                               { printf("\nLinea %i - SENTENCIA - ITERACION:  WHILE   ", yylineno);   } 
                    | DO sentencia WHILE '(' expresion ')' ';'                        { printf("\nLinea %i Se detecto una SENTENCIA-ITERACION:  DO/WHILE", yylineno);   } 
                    | FOR '(' expresion_';' expresion_ ';' expresion_ ')' sentencia   { printf("\nLinea %i Se detecto una SENTENCIA-ITERACION:  FOR     ", yylineno);   }
;

sentenciaEtiquetada: CASE expresionConstante ':' sentencia 
                    | DEFAULT ':' sentencia 
;

sentenciaDeSalto: CONTINUE ';'    { printf("\nSe detecto en la linea %i la SENTENCIA-SALTO:  CONTINUE", yylineno);   }
    | BREAK ';'                   { printf("\nSe detecto en la linea %i la SENTENCIA-SALTO:  BREAK   ", yylineno);   } 
    | RETURN expresion_ ';'       { printf("\nSe detecto en la linea %i la SENTENCIA-SALTO:  RETURN  ", yylineno);   } 
;


/* Casos opcionales agregando la opcion de espacio vacio */

// En Expresiones
listaArgumentos_: /* */
    | listaArgumentos
    ;

// En Declaraciones

expresionConstante_: /* */
    | expresionConstante
    ;

listaParametros_: /* */ 
    | listaDeParametros
    ;

// En Sentencias
expresion_: /* */    
    | expresion       
    ;

listaDeDeclaracionesAux: /* */
    | listaDeDeclaraciones 
    ;

listaDeSentenciasAux: /* */ 
    | listaDeSentencias 
    ;
%%


int main(){

     #ifdef BISON_DEBUG
        yydebug = 1;
    #endif 
    
    yyin = fopen("./codigoEnC.c", "r");
    
    printf("\nTipos de errores y advertencias de casteo:");
    yyparse();
    printf("\n------------------------------------");

    printf("\nValidaciones semanticas:");
    
    printf("\nDobles declaraciones: ");
    imprimirSimbolos(tablaDeDobleDeclaracion);
    printf("\n-----------------------------------");
    
    printf("\nTabla de simbolos:");
    imprimirSimbolos(tablaDeSimbolos);
}