import { readdirSync, readFileSync } from "fs";
import path from "path";

export type KnowledgeChunk = {
  source: string;
  title: string;
  content: string;
};

const knowledgePath = path.join(
  process.cwd(),
  "knowledge",
  "wollok"
);

function loadKnowledge(): KnowledgeChunk[] {
  const files = readdirSync(knowledgePath);

  const chunks: KnowledgeChunk[] = [];

  for (const file of files) {
    if (!file.endsWith(".md")) continue;

    const filePath = path.join(knowledgePath, file);
const content = readFileSync(filePath, "utf-8");

// Eliminar los metadatos iniciales de Markdown, si existen.
const normalizedContent = content.replace(
  /^---\r?\n[\s\S]*?\r?\n---\r?\n?/,
  ""
).trim();

const sections = normalizedContent.split(/^## /m);

// Si el documento no tiene título principal, descartar
// el texto introductorio anterior a la primera sección.
if (
  sections.length > 1 &&
  !sections[0]!.trimStart().startsWith("# ")
) {
  sections.shift();
}

    for (const section of sections) {
      if (!section.trim()) continue;

      const lines = section.split("\n");
      const mainTitle = lines[0]!.trim();

      const mainContent = lines
        .slice(1)
        .join("\n")
        .trim();

      const subsections = mainContent.split(/^### /m);

      if (subsections.length === 1) {
        chunks.push({
          source: file,
          title: mainTitle,
          content: mainContent,
        });

        continue;
      }

      const introduction = subsections[0]!.trim();

      if (introduction) {
        chunks.push({
          source: file,
          title: mainTitle,
          content: introduction,
        });
      }

      for (let i = 1; i < subsections.length; i++) {
        const subsection = subsections[i]!.trim();

        if (!subsection) continue;

        const subsectionLines = subsection.split("\n");

        const title = subsectionLines[0]!.trim();

        const content = subsectionLines
          .slice(1)
          .join("\n")
          .trim();

        chunks.push({
          source: file,
          title: `${mainTitle} - ${title}`,
          content,
        });
      }
    }
  }

  return chunks;
}

function tokenize(text: string): string[] {
  const stopWords = new Set([
    "a",
    "al",
    "como",
    "con",
    "de",
    "del",
    "el",
    "en",
    "es",
    "la",
    "las",
    "lo",
    "los",
    "para",
    "por",
    "que",
    "se",
    "un",
    "una",
    "y",
  ]);

  return text
    .toLowerCase()
    .normalize("NFD")
    .replace(/[^\p{L}\p{N}\s]/gu, " ")
    .replace(/[^\p{L}\p{N}\s]/gu, " ")
    .split(/\s+/)
    .filter(
      (word) => word && !stopWords.has(word)
    );
}

function expandWords(words: string[]): string[] {
  const synonyms: Record<string, string[]> = {
    cuantos: ["cantidad", "size"],
    cantidad: ["cuantos", "size"],
    size: ["cantidad", "cuantos"],

    primero: ["primer", "first"],
    primer: ["primero", "first"],
    first: ["primero", "primer"],

    ultimo: ["last"],
    last: ["ultimo"],

    obtener: ["get"],
    get: ["obtener"],

    lista: ["list"],
    list: ["lista"],
  };

  const expanded = new Set<string>(words);

  for (const word of words) {
    const relatedWords = synonyms[word];

    if (!relatedWords) continue;

    for (const relatedWord of relatedWords) {
      expanded.add(relatedWord);
    }
  }

  return [...expanded];
}

/*
  Calcula en cuantos chunks aparece una palabra.

  Si aparece en muchos chunks, es poco especifica.
  Si aparece en pocos chunks, es mas informativa.
*/
function documentFrequency(
  word: string,
  chunks: KnowledgeChunk[]
): number {
  let frequency = 0;

  for (const chunk of chunks) {
    const words = new Set(
      tokenize(`${chunk.title} ${chunk.content}`)
    );

    if (words.has(word)) {
      frequency++;
    }
  }

  return frequency;
}

/*
  IDF = Inverse Document Frequency.

  Una palabra rara recibe mayor peso.
  Una palabra muy comun recibe menor peso.
*/
function calculateIdf(
  word: string,
  chunks: KnowledgeChunk[]
): number {
  const frequency = documentFrequency(
    word,
    chunks
  );

  const totalDocuments = chunks.length;

  return Math.log(
    (totalDocuments + 1) / (frequency + 1)
  ) + 1;
}

export function searchKnowledge(
  question: string,
  limit: number = 3
): KnowledgeChunk[] {
  const chunks = loadKnowledge();

  const questionWords = expandWords(
    tokenize(question)
  );

 //calculo previo del IDF
  const idfByWord = new Map<string, number>();

for (const word of questionWords) {
  idfByWord.set(
    word,
    calculateIdf(word, chunks)
  );
}  

  const results = chunks.map((chunk) => {
    const titleWords = tokenize(chunk.title);
    const contentWords = tokenize(chunk.content);

    let score = 0;

    //calculo dentro del bucle
    for (const word of questionWords) {
      const idf = idfByWord.get(word) ?? 0;

      /*
        El titulo sigue teniendo mas importancia,
        pero ahora tambien tenemos en cuenta
        lo especifica que es cada palabra.
      */
      if (titleWords.includes(word)) {
        score += idf * 2;
      }

      if (contentWords.includes(word)) {
        score += idf;
      }
    }

    console.log({
      title: chunk.title,
      score: Number(score.toFixed(2)),
    });

    return {
      chunk,
      score,
    };
  });

    const selectedChunks = results
  .filter((result) => result.score > 0)
  .sort((a, b) => b.score - a.score)
  .slice(0, limit);

console.log(
  "FRAGMENTOS SELECCIONADOS:",
  selectedChunks.map(({ chunk, score }) => ({
    source: chunk.source,
    title: chunk.title,
    score: Number(score.toFixed(2)),
  }))
);

return selectedChunks.map((result) => result.chunk);
}