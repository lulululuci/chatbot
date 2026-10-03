type KnowledgeChunk = {
  source: string;
  title: string;
  content: string;
};

export type TutorResponse = {
  answer: string;
  topic: string;
  level: number;
};

export function tutor(
  message: string,
  context: KnowledgeChunk[]
): TutorResponse {
  const text = message.toLowerCase();

  // Preguntas relacionadas con List
  if (
    text.includes("list") ||
    text.includes("lista") ||
    text.includes("primer elemento") ||
    text.includes("first")
  ) {
    return {
      topic: "listas",
      level: 1,
      answer:
        "Veo que estás trabajando con una List. " +
        "La documentación menciona una operación relacionada con el primer elemento. " +
        "Antes de darte la respuesta, pensá: ¿qué mensaje podrías enviarle a una lista para pedirle específicamente su primer elemento?",
    };
  }

  // Preguntas sobre clases
  if (text.includes("clase") || text.includes("class")) {
    return {
      topic: "clases",
      level: 1,
      answer:
        "Pensá en una clase como un molde para crear objetos. " +
        "¿Qué características tendría que definir ese molde para poder crear distintos objetos a partir de él?",
    };
  }

  // Preguntas sobre objetos
  if (text.includes("objeto")) {
    return {
      topic: "objetos",
      level: 1,
      answer:
        "Un objeto representa una entidad concreta dentro del programa. " +
        "Pensá en un ejemplo del mundo real: ¿qué información y qué acciones podría tener ese objeto?",
    };
  }

  // Preguntas sobre métodos
  if (text.includes("método") || text.includes("metodo")) {
    return {
      topic: "métodos",
      level: 1,
      answer:
        "Un método representa una acción que un objeto puede realizar. " +
        "¿Qué acción concreta querés que realice tu objeto?",
    };
  }

  // Preguntas sobre herencia
  if (text.includes("herencia")) {
    return {
      topic: "herencia",
      level: 1,
      answer:
        "La herencia permite que una clase tome características de otra. " +
        "Pensá primero: ¿qué tienen en común las dos clases que querés relacionar?",
    };
  }

  // Si el RAG encontró información pero no tenemos
  // todavía una regla específica para esa pregunta.
  if (context.length > 0) {
    return {
      topic: context[0]!.title,
      level: 1,
      answer:
        `Encontré información relacionada con "${context[0]!.title}". ` +
        "Antes de darte la solución, intentemos razonarlo: " +
        "¿Qué parte de esa información pensás que se relaciona directamente con tu pregunta?",
    };
  }

  // Si el RAG no encontró información.
  return {
    topic: "general",
    level: 1,
    answer:
      "No encontré información específica sobre eso en la documentación de Wollok. " +
      "Intentemos dividir el problema: ¿qué querés lograr y en qué parte estás teniendo dificultades?",
  };
}