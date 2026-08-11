import cors from "cors";
import express from "express";
import { readFileSync } from "fs";
import ollama from 'ollama';
import path from "path";

const app = express();
const PORT = 3000;

app.use(cors());
app.use(express.json());

app.get("/", (_req, res) => {
  res.send("Tutor de Wollok funcionando 🚀");
});

app.post("/chat", async (req, res) => {
  const { message } = req.body;

  console.log("Thinking...")
  const response = await ollama.chat({
    model: 'gemma4',
    messages: [
      { role: 'system', content: `Sending code written in Wollok:` },
      { role: 'system', content: readFileSync(path.join('.', 'wollok', 'lang.wlk'), { encoding: 'utf-8' }) },
      { role: 'user', content: `Only answer based on the context code that I send. If you can include code snippets as examples from there, better.` },
      { role: 'user', content: `Question: ${message}` }
    ],
  })
  console.log("Done!")

  res.send({
    question: message,
    answer: response.message.content,
  });
});

app.listen(PORT, () => {
  console.log(`Servidor corriendo en http://localhost:${PORT}`);
});