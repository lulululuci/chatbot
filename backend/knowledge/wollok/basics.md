# Fundamentos de Wollok

## Que es Wollok

Wollok es un lenguaje de programacion orientado a objetos.
Esta pensado principalmente para aprender programacion orientada a objetos.

El lenguaje permite trabajar con objetos, clases, metodos, propiedades, herencia y colecciones.

## Variables

Una variable permite guardar un valor para utilizarlo posteriormente.

Ejemplo:

var nombre = "Luciana"

El valor de una variable puede cambiar.

Ejemplo:

var edad = 23
edad = 24

## Constantes

Una constante representa un valor que no deberia cambiar durante la ejecucion.

En Wollok se puede utilizar const.

Ejemplo:

const nombre = "Ana"

## Valores

Wollok permite trabajar con distintos tipos de valores.

Algunos ejemplos son:

- numeros
- strings
- booleanos
- objetos
- colecciones

Ejemplos:

42

"Hola"

true

false

## Strings

Un string representa una cadena de texto.

Ejemplo:

var nombre = "Juan"

Los strings pueden concatenarse.

Ejemplo:

"Hola " + nombre

## Numeros

Los numeros pueden utilizarse para realizar operaciones matematicas.

Ejemplo:

var resultado = 10 + 5

Tambien pueden utilizarse operadores como:

+

-

*

/

## Booleanos

Los valores booleanos representan verdadero o falso.

Los valores booleanos son:

true

false

Ejemplo:

var esMayor = edad >= 18

## Condicionales

Los condicionales permiten ejecutar diferentes instrucciones dependiendo de una condicion.

Se puede utilizar if.

Ejemplo:

if (edad >= 18) {
    console.println("Es mayor de edad")
} else {
    console.println("Es menor de edad")
}

La condicion debe producir un valor booleano.

## Comparaciones

Las comparaciones permiten obtener valores booleanos.

Ejemplos:

5 > 3

5 < 10

5 == 5

5 != 3

## Operadores logicos

Los operadores logicos permiten combinar condiciones.

Ejemplos:

condicion1 && condicion2

condicion1 || condicion2

!condicion

&& representa AND.

|| representa OR.

! representa NOT.

## Repeticion

Los programas pueden necesitar repetir una accion sobre varios elementos.

En Wollok es comun utilizar metodos de las colecciones y closures para recorrer elementos.

Ejemplo conceptual:

[1, 2, 3].forEach({ numero =>
    console.println(numero)
})

## Objetos

Un objeto representa una entidad con comportamiento y estado.

Ejemplo:

object persona {
    var nombre = "Ana"

    method saludar() {
        console.println("Hola")
    }
}

Los objetos pueden tener propiedades y metodos.

## Metodos

Un metodo representa un comportamiento de un objeto.

Ejemplo:

object persona {
    method saludar() {
        console.println("Hola")
    }
}

El metodo puede invocarse sobre el objeto:

persona.saludar()

## Propiedades

Una propiedad representa un dato asociado a un objeto.

Ejemplo:

object persona {
    var nombre = "Ana"
}

La propiedad puede consultarse:

persona.nombre

Una propiedad tambien puede modificarse si fue declarada con var.

Ejemplo:

persona.nombre = "Juan"