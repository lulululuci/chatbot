
import express from "express";
import cors from "cors";
import { searchKnowledge } from "./rag.js";
import { probarConexionDB, db } from "./db.js";
import { generateWithOllama } from "./ollama.js";
import { getHardcodedAnswer } from "./hardcodedAnswers.js";

const app = express();
const PORT = 3000;

app.use(cors());
app.use(express.json());

app.get("/", (_req, res) => {
  res.send("Tutor de Wollok funcionando");
});

app.post("/chat", async (req, res) => {
  const { message, chatId } = req.body;

  try {
    if (typeof message !== "string" || !message.trim()) {
      res.status(400).json({
        error: "El mensaje es obligatorio",
      });
      return;
    }

    const results = searchKnowledge(message);
    const hardcoded = getHardcodedAnswer(message);

    const answer =
      hardcoded?.answer ??
      await generateWithOllama(message, results);

    const response = {
      answer,
      topic: hardcoded?.topic ?? results[0]?.title ?? "general",
      level: 1,
    };

    await db.query(
      `INSERT INTO conversations
        (question, answer, topic, level, chat_id)
       VALUES ($1, $2, $3, $4, $5)`,
      [
        message,
        response.answer,
        response.topic,
        response.level,
        chatId ?? null,
      ]
    );

    res.json({
      question: message,
      answer: response.answer,
      topic: response.topic,
      level: response.level,
      context: results,
    });
  } catch (error) {
    console.error("Error al procesar el mensaje:", error);

    res.status(500).json({
      error: "No se pudo procesar el mensaje",
    });
  }
});

app.get("/history", async (_req, res) => {
  try {
    const result = await db.query(
      `SELECT
        id,
        question,
        answer,
        topic,
        level,
        created_at,
        chat_id
       FROM conversations
       ORDER BY created_at ASC`
    );

    res.json(result.rows);
  } catch (error) {
    console.error("Error al obtener el historial:", error);

    res.status(500).json({
      error: "No se pudo obtener el historial",
    });
  }
});

app.listen(PORT, async () => {
  try {
    await probarConexionDB();

    console.log(
      `Servidor corriendo en http://localhost:${PORT}`
    );
  } catch (error) {
    console.error(
      "Error al conectar con PostgreSQL:",
      error
    );
  }
});
