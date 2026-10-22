
type HardcodedAnswer = {
  answer: string;
  topic: string;
};

function normalize(text: string): string {
  return text
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .trim();
}

export function getHardcodedAnswer(
  message: string
): HardcodedAnswer | null {
  const question = normalize(message);

  if (/\bforeach\b/.test(question)) {
    return {
      topic: "Colecciones - forEach()",
      answer: `**¿Para qué sirve \`forEach()\` en Wollok?**

Sirve para recorrer una colección y ejecutar una acción por cada elemento. Recibe un bloque de código (closure) que indica qué hacer con cada elemento.

**Ejemplo:**

\`\`\`wollok
const numeros = [23, 2, 1]
var suma = 0

numeros.forEach({ n => suma = suma + n })

suma == 26
\`\`\`

**¿Qué ocurre acá?**
- \`numeros\` contiene tres números.
- \`forEach()\` toma cada elemento y lo representa como \`n\`.
- En cada recorrido, suma ese número a \`suma\`.
- Al terminar, \`suma\` vale 26.

**Importante:** \`forEach()\` ejecuta una acción por elemento; no crea una nueva colección con los resultados.`
    };
  }

  return null;
}
