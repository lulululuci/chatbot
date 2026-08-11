import { useState } from "react";
import Markdown from 'react-markdown'
import "./App.css";

function App() {
  const [message, setMessage] = useState("");
  const [answer, setAnswer] = useState("");
  const [isLoading, setIsLoading] = useState(false);

  const sendMessage = async () => {
    if (!message.trim()) return;

    setIsLoading(true);
    setAnswer("");

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
    } finally {
      setIsLoading(false);
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
          disabled={isLoading}
        />

        <button onClick={sendMessage} disabled={isLoading}>
          {isLoading ? "Thinking..." : "Enviar"}
        </button>
      </div>

      {isLoading && (
        <div className="loading-row">
          <div className="spinner" aria-hidden="true"></div>
          <span>Thinking...</span>
        </div>
      )}

      {answer && (
        <div className="answer">
          <strong>Tutor:</strong>
          <Markdown>{answer}</Markdown>
        </div>
      )}
    </div>
  );
}

export default App;