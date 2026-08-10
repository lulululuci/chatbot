import express from "express";
import cors from "cors";

const app = express();
const PORT = 3000;

app.use(cors());
app.use(express.json());

app.get("/", (_req, res) => {
  res.send("Tutor de Wollok funcionando 🚀");
});

app.post("/chat", (req, res) => {
  const { message } = req.body;

  res.json({
    answer: `Recibí tu pregunta: "${message}". Soy tu tutor de Wollok y voy a ayudarte con pistas.`,
  });
});

app.listen(PORT, () => {
  console.log(`Servidor corriendo en http://localhost:${PORT}`);
});