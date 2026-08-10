export type TutorResponse = {
  answer: string;
  topic: string;
  level: number;
};

export function tutor(message: string): TutorResponse {
  const text = message.toLowerCase();

  if (text.includes("clase") || text.includes("class")) {
    return {
      topic: "clases",
      level: 1,
      answer:
        "Pensá en una clase como un molde para crear objetos. ¿Qué características tendría que definir ese molde para poder crear distintos objetos a partir de él?",
    };
  }

  if (text.includes("objeto")) {
    return {
      topic: "objetos",
      level: 1,
      answer:
        "Un objeto representa una entidad concreta dentro del programa. Pensá en un ejemplo del mundo real: ¿qué información y qué acciones podría tener ese objeto?",
    };
  }

  if (text.includes("método") || text.includes("metodo")) {
    return {
      topic: "métodos",
      level: 1,
      answer:
        "Un método representa una acción que un objeto puede realizar. ¿Qué acción concreta querés que realice tu objeto?",
    };
  }

  if (text.includes("herencia")) {
    return {
      topic: "herencia",
      level: 1,
      answer:
        "La herencia permite que una clase tome características de otra. Pensá primero: ¿qué tienen en común las dos clases que querés relacionar?",
    };
  }

  return {
    topic: "general",
    level: 1,
    answer:
      "Antes de darte una respuesta, intentemos razonarlo. ¿Qué parte del problema entendés y en cuál estás teniendo dificultades?",
  };
}