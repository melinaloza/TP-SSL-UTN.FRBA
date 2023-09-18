#include <stdio.h>
#include <stdlib.h>
#include <string.h>
//control z
/*Estructuras de la tabla de simbolos*/
struct parametroDeUnaFuncion{
    char* tipoDelParametro;
    struct parametroDeUnaFuncion* siguiente;
}*tablaDeParametros = NULL;

struct tablaDeSimbolos{
    char* identificador;
    char* tipo;
    int boolDeclaracion; // 0 si es variable o 1 si es funcion
    struct parametroDeUnaFuncion* tipoDeParametros;
    struct tablaDeSimbolos* siguiente;  
}*tablaDeSimbolos = NULL,*tablaDeDobleDeclaracion = NULL,* tablaAuxiliar = NULL;

struct contadorDeclaradores {
    int dimensiones;
} contador = {0}; //para inicializar en 0 al contador


int numeroDeLinea = 0;

//------------Ingresar paramatros y simbolos sus respectivas listas----------
void agregarParametro(struct parametroDeUnaFuncion** cabeza,char* nuevoTipoDeParametro){
    
    struct parametroDeUnaFuncion* nodo = (struct parametroDeUnaFuncion*) malloc(sizeof(struct parametroDeUnaFuncion));

    nodo->tipoDelParametro = calloc(strlen(nuevoTipoDeParametro) + 1,sizeof(char));
    strncpy(nodo->tipoDelParametro,nuevoTipoDeParametro,strlen(nuevoTipoDeParametro) + 1);// almacena el segundo string en el primero y ademas pide el tamaño del mismo en el 3ero

    nodo->siguiente = (*cabeza);
    (*cabeza) = nodo;
}

int dobleDeclaracion(char*); //para poder agregar parametros

void agregarParametros(char* identificador){

    if(!dobleDeclaracion(identificador))
        tablaDeSimbolos->tipoDeParametros = tablaDeParametros;
    else
        tablaDeDobleDeclaracion->tipoDeParametros = tablaDeParametros;
    
    tablaDeParametros = NULL;
}

void agregarSimbolo(struct tablaDeSimbolos** cabeza,char* nuevoIdentificador,char* nuevoTipo,int nuevoBoolDeclaracion){
    
    struct tablaDeSimbolos* nodo = (struct tablaDeSimbolos*) malloc(sizeof(struct tablaDeSimbolos));

    nodo->identificador = calloc(strlen(nuevoIdentificador) + 1, sizeof(char));
    nodo->tipo = calloc(strlen(nuevoTipo) + 1, sizeof(char));

    strncpy(nodo->identificador, nuevoIdentificador, strlen(nuevoIdentificador) + 1);
    strncpy(nodo->tipo,nuevoTipo,strlen(nuevoTipo) + 1);

    nodo->boolDeclaracion = nuevoBoolDeclaracion;
    nodo->tipoDeParametros = NULL;

    nodo->siguiente = (*cabeza);
    (*cabeza) = nodo;
}

char* insertarDeclarador(char *declarador,char *tipoDeDato, int cantidad){
    char *temp = (char *) malloc(1 + strlen(tipoDeDato) + strlen(declarador) * cantidad);

    strcpy(temp,tipoDeDato);

    for(int i =0;i < cantidad; i++){
        strcat(temp,declarador); //concatena a la cadena y declarador
    }

    return temp;
}

char* insertarDeclaradores(char *tipoDeDato){
    tipoDeDato = insertarDeclarador("[]",tipoDeDato,contador.dimensiones);
    contador.dimensiones = 0;

    return tipoDeDato;
}
//No se si se va a usar:(no la entiendo muy bien)
void sacarDeclarador(char declarador, char *tipoDeDato){
    int n = strlen(tipoDeDato);
    int j = strlen(tipoDeDato); // alamacena la longitud del tipoDeDato

    for(int i = j = 0; i < n; i++){
        if(tipoDeDato[i] != declarador){
            tipoDeDato[j++] = tipoDeDato[i];
        }
    }   
    tipoDeDato[j] = '\0'; //'\0' indica fin de cadena
}


//-----------Doble declaracion de variables-----------------------

int declarado(char* unIdentificador){// Funvcion que permite saber si una variable  o funcion esta declarada
    struct tablaDeSimbolos * temp = (struct tablaDeSimbolos*) malloc(sizeof(struct tablaDeSimbolos));

    temp = tablaDeSimbolos;

    while(temp != NULL){
        if(!strcmp(unIdentificador, temp->identificador)){
            return 1;
        }else{
            temp = temp->siguiente;
        }
    }

    return 0; // devuelve 1 si ya esta declarado sino 0
}

int dobleDeclaracion(char* unIdentificador){
    struct tablaDeSimbolos *temp = (struct tablaDeSimbolos*) malloc(sizeof(struct tablaDeSimbolos));
    temp = tablaDeDobleDeclaracion;

    while(temp != NULL){
        if(!strcmp(unIdentificador, temp->identificador)){
            return 1;
        }else{
            temp = temp->siguiente;
        }
    }

    return 0; // devuelve 1 si ya esta declarado sino 0
}

//-----------------Devolver identificadores y parametros-----------------
struct tablaDeSimbolos* devolverIdentificador(char* identificador){
    struct tablaDeSimbolos* temp = tablaDeSimbolos;

    while(temp != NULL && strcmp(identificador, temp->identificador) != 0){//Mientras sean distintos
        temp = temp->siguiente;
    }

    return temp;
}

struct parametroDeUnaFuncion* devolverParametros(char* identificador){
    struct tablaDeSimbolos* temp = tablaDeSimbolos;

    while(temp != NULL && strcmp(identificador, temp->identificador) != 0){//Mientras sean distintos
        temp = temp->siguiente;
    }

    return temp->tipoDeParametros;
}
//-----------------------------------------

void agregarParametrosSinRepetir(char* unTipoDeParametro,char* unaCadena){
    
    if(!dobleDeclaracion(unaCadena)){
        agregarParametro(&(tablaDeSimbolos->tipoDeParametros), unTipoDeParametro);
    }else{
        agregarParametro(&(tablaDeDobleDeclaracion->tipoDeParametros), unTipoDeParametro);
    }
}

void agregarSimbolosSinRepetir(char* unTipo,char* unaCadena, int boolTipoDeDeclaracion){
   if(!declarado(unaCadena)){
       agregarSimbolo(&tablaDeSimbolos, unaCadena, unTipo ,boolTipoDeDeclaracion);
   }else{
       agregarSimbolo(&tablaDeDobleDeclaracion, unaCadena,unTipo,boolTipoDeDeclaracion);
   }
}

//----------------Invocacion de funciones-----------------
int cantidadDeParametros(struct parametroDeUnaFuncion** parametros){
    int cantidad = 0;

    struct parametroDeUnaFuncion* temp = (*parametros);

    while (temp != NULL) {
        cantidad++;
        temp = temp->siguiente;
    }

    return cantidad;
}

int cantidadParametrosCorrectos(struct tablaDeSimbolos* invocacionAFuncion){
    struct tablaDeSimbolos* temp = invocacionAFuncion;
    struct tablaDeSimbolos* comparacion = devolverIdentificador(temp->identificador);

    return cantidadDeParametros(&temp->tipoDeParametros) == cantidadDeParametros(&comparacion->tipoDeParametros);
}

int tiposDeParametrosCorrectos(struct tablaDeSimbolos* invocacionAFuncion){
    struct parametroDeUnaFuncion* temp = invocacionAFuncion->tipoDeParametros;
    struct parametroDeUnaFuncion* comparacion = devolverParametros(invocacionAFuncion->identificador);

    struct tablaDeSimbolos* unIdentificador = devolverIdentificador(temp->tipoDelParametro);

    while (temp != NULL && comparacion != NULL){
        if(devolverIdentificador(temp->tipoDelParametro) != NULL)
            unIdentificador = devolverIdentificador(temp->tipoDelParametro);
        else
            return 0;
        
        
        if(strcmp(unIdentificador->tipo, comparacion->tipoDelParametro))
            return 0;

        temp = temp->siguiente;
        comparacion = comparacion->siguiente;
    }
    
    return 1;
}

int controlDeInvocacion(struct tablaDeSimbolos* invocacionAFuncion){
    struct tablaDeSimbolos* temp = invocacionAFuncion;
    
    if(!declarado(temp->identificador)){
        printf("\nLinea: %i, la Funcion: %s, ha sido invodcada sin estar declarada", numeroDeLinea, temp->identificador);
        return 0;
    }

    if(!cantidadParametrosCorrectos(temp)){
        printf("\nLinea: %i, la Funcion: %s, ha sido invocada con una cantidad erronea de parametros",numeroDeLinea,temp->identificador);
        return 0;
    }

    if(cantidadDeParametros(&temp->tipoDeParametros) !=0 && !tiposDeParametrosCorrectos(temp)){
        printf("\nLinea %i, la Funcion: %s, ha sido invocada con un tipo incorrecto",numeroDeLinea,temp->identificador);
        return 0;
    }

    return 1;
}

//-------------Imprimir-----------------
void imprimirParametros(struct parametroDeUnaFuncion* listaDeParametros){
    if (listaDeParametros == NULL)
        return;
    
    imprimirParametros(listaDeParametros->siguiente);

    printf("\nTipo de parametro: %s", listaDeParametros->tipoDelParametro);
}

void imprimirSimbolos(struct tablaDeSimbolos* listaDeSimbolos){
    if(listaDeSimbolos == NULL){
        return;
    }

    imprimirSimbolos(listaDeSimbolos->siguiente);

    switch (listaDeSimbolos->boolDeclaracion){
        case 0:
            
            printf("\nIdentificador: %s  con Tipo: %s",listaDeSimbolos->identificador, listaDeSimbolos->tipo);

            break;
        
        case 1:

            printf("\nIdentificador de la funcion: %s con Tipo: %s",listaDeSimbolos->identificador,listaDeSimbolos->tipo);
            printf("\nRetorna un valor de tipo: %s",listaDeSimbolos->tipo);
            printf("\nCantidad de parametros: %d", cantidadDeParametros(&listaDeSimbolos->tipoDeParametros));
            imprimirParametros(listaDeSimbolos->tipoDeParametros);

            break;
    }
}

// CONTROL DE OPERACION BINARIA
int validacionTipos(char* unTipo, char* otroTipo) {    
        
        if(strcmp(unTipo, otroTipo)) { 
            printf("\nEn linea %i se convierte de %s a %s\n", numeroDeLinea, unTipo,otroTipo);
            return 0;
        } 
        
    return 0;
    
}


