import { useState } from "react";
import "./App.css";

function App() {
  const [message, setMessage] = useState("");
  const [answer, setAnswer] = useState("");
  const [menuOpen, setMenuOpen] = useState(false);
  const [darkMode, setDarkMode] = useState(false);

  const sendMessage = async () => {
    if (!message.trim()) return;

    try {
      const response = await fetch("http://localhost:3000/chat", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          message,
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
    <div className={`app ${darkMode ? "dark-mode" : ""}`}>
      <button
        className="menu-button"
        onClick={() => setMenuOpen(!menuOpen)}
        aria-label="Abrir menú"
      >
        {menuOpen ? "×" : "☰"}
      </button>

      <aside className={`sidebar ${menuOpen ? "open" : ""}`}>
        <div className="sidebar-content">
          <button className="new-chat">
            + Nuevo chat
          </button>

          <div className="history">
            <p className="history-title">Recientes</p>
          </div>
        </div>

        <button
          className="settings"
          onClick={() => setDarkMode(!darkMode)}
        >
          <span>{darkMode ? "☀" : "☾"}</span>
          {darkMode ? "Modo claro" : "Modo oscuro"}
        </button>
      </aside>

      <main className="main">
        <section className="welcome">
          <div className="welcome-content">
            <h1>WOLLOK</h1>

            <p className="subtitle">
              ¿En qué te puedo ayudar a pensar?
            </p>

            <div className="input-container">
              <input
                type="text"
                value={message}
                onChange={(event) => setMessage(event.target.value)}
                onKeyDown={(event) => {
                  if (event.key === "Enter") {
                    sendMessage();
                  }
                }}
                placeholder="Escribí tu pregunta..."
              />

              <button onClick={sendMessage}>→</button>
            </div>

            {answer && (
              <div className="answer">
                <strong>Tutor</strong>
                <p>{answer}</p>
              </div>
            )}
          </div>
        </section>
      </main>
    </div>
  );
}

export default App;