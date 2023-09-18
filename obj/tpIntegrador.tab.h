
/* A Bison parser, made by GNU Bison 2.4.1.  */

/* Skeleton interface for Bison's Yacc-like parsers in C
   
      Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.
   
   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.
   
   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */


/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     IDENTIFICADOR = 258,
     TIPO_DATO = 259,
     SIZEOF = 260,
     CTE_DECIMAL = 261,
     CTE_OCTAL = 262,
     CTE_HEXADECIMAL = 263,
     CTE_REAL = 264,
     OP_O_LOGICO = 265,
     OP_Y_LOGICO = 266,
     OP_O_INCLUSIVO = 267,
     OP_ASIGNACION = 268,
     OP_IGUALDAD = 269,
     OP_DESIGUALDAD = 270,
     OP_RELACIONAL = 271,
     OP_DIVISION = 272,
     OP_PORCENTAJE = 273,
     OP_INCREMENTO = 274,
     OP_DECREMENTO = 275,
     DO = 276,
     WHILE = 277,
     IF = 278,
     ELSE = 279,
     SWITCH = 280,
     CASE = 281,
     DEFAULT = 282,
     BREAK = 283,
     CONTINUE = 284,
     FOR = 285,
     RETURN = 286,
     CTE_CADENA = 287,
     CTE_CARACTER = 288
   };
#endif



#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
{

/* Line 1676 of yacc.c  */
#line 24 "../src/tpIntegrador.y"

    char* cadena;
    int entero;
    float real;



/* Line 1676 of yacc.c  */
#line 93 "tpIntegrador.tab.h"
} YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
#endif

extern YYSTYPE yylval;


