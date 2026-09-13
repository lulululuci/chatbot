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

    // Cada ## representa una seccion principal.
    const sections = content.split(/^## /m);

    for (const section of sections) {
      if (!section.trim()) continue;

      const lines = section.split("\n");
      const mainTitle = lines[0]!.trim();
      const mainContent = lines.slice(1).join("\n").trim();

      // Cada ### representa un fragmento mas especifico.
      const subsections = mainContent.split(/^### /m);

      // Si no hay subsecciones, guardamos la seccion completa.
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
     // Guardamos cada ### como un fragmento independiente.
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
  return text
    .toLowerCase()
    .replace(/[^\w\s]/g, " ")
    .split(/\s+/)
    .filter(Boolean);
}

export function searchKnowledge(
  question: string,
  limit: number = 3
): KnowledgeChunk[] {
  const chunks = loadKnowledge();
  const questionWords = tokenize(question);

  const results = chunks.map((chunk) => {
    const chunkWords = tokenize(
      `${chunk.title} ${chunk.content}`
    );

    let score = 0;

    for (const word of questionWords) {
      if (chunkWords.includes(word)) {
        score++;
      }
    }

    return {
      chunk,
      score,
    };
  });

  return results
    .filter((result) => result.score > 0)
    .sort((a, b) => b.score - a.score)
    .slice(0, limit)
    .map((result) => result.chunk);
}