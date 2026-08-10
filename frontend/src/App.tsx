import { useState } from "react";
import "./App.css";

function App() {
  const [message, setMessage] = useState("");
  const [answer, setAnswer] = useState("");

  const sendMessage = async () => {
    if (!message.trim()) return;

    try {
      const response = await fetch("http://localhost:3000/chat", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          message: message,
        }),
      });

      const data = await response.json();

      setAnswer(data.answer);
    } catch (error) {
      console.error(error);
      setAnswer("No pude conectarme con el servidor.");
    }
  };

  return (
    <div className="app">
      <h1>Tutor de Wollok</h1>

      <p>Tu asistente para aprender programación con Wollok.</p>

      <div className="input-container">
        <input
          type="text"
          value={message}
          onChange={(event) => setMessage(event.target.value)}
          placeholder="Escribí tu pregunta..."
        />

        <button onClick={sendMessage}>
          Enviar
        </button>
      </div>

      {answer && (
        <div className="answer">
          <strong>Tutor:</strong>
          <p>{answer}</p>
        </div>
      )}
    </div>
  );
}

export default App;