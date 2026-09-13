import express from "express";
import cors from "cors";
import { searchKnowledge } from "./rag.js";
import { tutor } from "./tutor.js";
import { probarConexionDB, db } from "./db.js";

const app = express();
const PORT = 3000;

app.use(cors());
app.use(express.json());

app.get("/", (_req, res) => {
  res.send("Tutor de Wollok funcionando");
});

app.post("/chat", async (req, res) => {
  const { message, chatId } = req.body;

  const results = searchKnowledge(message);
  const response = tutor(message, results);

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
       ORDER BY created_at DESC`
    );

    res.json(result.rows);
  } catch (error) {
    console.error(
      "Error al obtener el historial:",
      error
    );

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