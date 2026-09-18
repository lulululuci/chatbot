import { useEffect, useRef, useState } from "react";
import "./App.css";

type ChatMessage = {
  id: string;
  role: "Alumno" | "Wollok";
  content: string;
  linkedChatId?: string;
  linkedChatTitle?: string;
};

type ChatThread = {
  id: string;
  title: string;
  messages: ChatMessage[];
  updatedAt: number;
};

type DatabaseConversation = {
  id: number;
  question: string;
  answer: string;
  topic: string | null;
  level: string | null;
  created_at: string;
};

const STORAGE_KEY = "wollok-chat-history";

const createWelcomeMessage = (): ChatMessage => ({
  id: crypto.randomUUID(),
  role: "Wollok",
  content:
    "¡Hola! Soy Wollok, un tutor especializado exclusivamente en el lenguaje Wollok.\n\n" +
    "Puedo ayudarte a razonar conceptos, entender errores y trabajar con la documentación. " +
    "Mi objetivo es ayudarte a pensar, no resolver los ejercicios directamente por vos.\n\n" +
    "Las consultas deben estar relacionadas con Wollok.\n\n" +
    "¿En qué estás trabajando?",
});

const createChat = (): ChatThread => ({
  id: crypto.randomUUID(),
  title: "Nuevo chat",
  messages: [createWelcomeMessage()],
  updatedAt: Date.now(),
});

function normalizeText(text: string) {
  return text
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/[^\w\s]/g, " ")
    .split(/\s+/)
    .filter(
      (word) =>
        word.length > 2 &&
        ![
          "que",
          "como",
          "para",
          "una",
          "uno",
          "con",
          "del",
          "las",
          "los",
          "por",
          "qué",
          "quiero",
          "puedo",
          "hacer",
        ].includes(word)
    );
}

function similarity(a: string, b: string) {
  const wordsA = normalizeText(a);
  const wordsB = normalizeText(b);

  if (wordsA.length === 0 || wordsB.length === 0) {
    return 0;
  }

  const setA = new Set(wordsA);
  const setB = new Set(wordsB);

  let matches = 0;

  for (const word of setA) {
    if (setB.has(word)) {
      matches++;
    }
  }

  return matches / Math.min(setA.size, setB.size);
}

function App() {
  const [message, setMessage] = useState("");
  const [darkMode, setDarkMode] = useState(false);
  const [loading, setLoading] = useState(false);

  const [chats, setChats] = useState<ChatThread[]>(() => {
    const saved = localStorage.getItem(STORAGE_KEY);

    if (saved) {
      try {
        const parsed = JSON.parse(saved);

        if (Array.isArray(parsed) && parsed.length > 0) {
          return parsed;
        }
      } catch {
        console.error("No se pudo cargar el historial.");
      }
    }

    return [createChat()];
  });

  const [activeChatId, setActiveChatId] = useState(
    () => chats[0]?.id ?? ""
  );

  const bottomRef = useRef<HTMLDivElement | null>(null);

  const loadHistory = async () => {
    try {
      const response = await fetch("http://localhost:3000/history");
      const data: DatabaseConversation[] = await response.json();

      console.log("Historial desde PostgreSQL:", data);
    } catch (error) {
      console.error("No se pudo cargar el historial:", error);
    }
  };

  const activeChat =
    chats.find((chat) => chat.id === activeChatId) ?? chats[0];

  useEffect(() => {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(chats));
  }, [chats]);

  useEffect(() => {
    loadHistory();
  }, []);

  useEffect(() => {
    bottomRef.current?.scrollIntoView({
      behavior: "smooth",
    });
  }, [activeChat?.messages, loading]);

  const updateChat = (
    chatId: string,
    updater: (chat: ChatThread) => ChatThread
  ) => {
    setChats((previousChats) =>
      previousChats.map((chat) =>
        chat.id === chatId ? updater(chat) : chat
      )
    );
  };

  const findRelatedChat = (question: string) => {
    let bestChat: ChatThread | null = null;
    let bestScore = 0;

    for (const chat of chats) {
      if (chat.id === activeChatId) continue;

      const studentMessages = chat.messages.filter(
        (item) => item.role === "Alumno"
      );

      for (const oldMessage of studentMessages) {
        const score = similarity(question, oldMessage.content);

        if (score > bestScore) {
          bestScore = score;
          bestChat = chat;
        }
      }
    }

    if (bestScore >= 0.55) {
      return bestChat;
    }

    return null;
  };

  const sendMessage = async () => {
    const trimmedMessage = message.trim();

    if (!trimmedMessage || loading || !activeChat) return;

    const chatId = activeChat.id;

    const studentMessage: ChatMessage = {
      id: crypto.randomUUID(),
      role: "Alumno",
      content: trimmedMessage,
    };

    updateChat(chatId, (chat) => {
      const previousStudentMessages = chat.messages.filter(
        (item) => item.role === "Alumno"
      );

      const title =
        previousStudentMessages.length === 0
          ? trimmedMessage.length > 34
            ? `${trimmedMessage.slice(0, 34)}...`
            : trimmedMessage
          : chat.title;

      return {
        ...chat,
        title,
        messages: [...chat.messages, studentMessage],
        updatedAt: Date.now(),
      };
    });

    setMessage("");

    const relatedChat = findRelatedChat(trimmedMessage);

    if (relatedChat) {
      const suggestion: ChatMessage = {
        id: crypto.randomUUID(),
        role: "Wollok",
        content:
          `Veo que ya trabajamos sobre un tema parecido en una conversación anterior llamada "${relatedChat.title}".\n\n` +
          "Podés volver a esa conversación y revisar lo que razonamos juntos. Si preferís una explicación nueva, también podemos seguir trabajando acá.",
        linkedChatId: relatedChat.id,
        linkedChatTitle: relatedChat.title,
      };

      updateChat(chatId, (chat) => ({
        ...chat,
        messages: [...chat.messages, suggestion],
        updatedAt: Date.now(),
      }));

      return;
    }

    setLoading(true);

    try {
      const response = await fetch("http://localhost:3000/chat", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          message: trimmedMessage,
        }),
      });

      const data = await response.json();

      const wollokMessage: ChatMessage = {
        id: crypto.randomUUID(),
        role: "Wollok",
        content: data.answer,
      };

      updateChat(chatId, (chat) => ({
        ...chat,
        messages: [...chat.messages, wollokMessage],
        updatedAt: Date.now(),
      }));
    } catch (error) {
      console.error(error);

      updateChat(chatId, (chat) => ({
        ...chat,
        messages: [
          ...chat.messages,
          {
            id: crypto.randomUUID(),
            role: "Wollok",
            content: "No pude conectarme con el servidor.",
          },
        ],
      }));
    } finally {
      setLoading(false);
    }
  };

  const newChat = () => {
    const chat = createChat();

    setChats((previousChats) => [chat, ...previousChats]);
    setActiveChatId(chat.id);
    setMessage("");
  };

  const openChat = (chatId: string) => {
    setActiveChatId(chatId);
    setMessage("");
  };

  const sortedChats = [...chats].sort(
    (a, b) => b.updatedAt - a.updatedAt
  );

  return (
    <div className={`app ${darkMode ? "dark-mode" : ""}`}>
      <aside className="sidebar">
        <div className="logo">WOLLOK</div>

        <button className="new-chat" onClick={newChat}>
          <span>＋</span>
          Nuevo chat
        </button>

        <div className="history">
          <p className="history-title">Recientes</p>

          <div className="history-list">
            {sortedChats.map((chat) => (
              <button
                key={chat.id}
                className={`history-item ${
                  chat.id === activeChatId ? "active" : ""
                }`}
                onClick={() => openChat(chat.id)}
              >
                <span className="history-icon">▢</span>

                <span className="history-text">
                  {chat.title}
                </span>
              </button>
            ))}
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
        <header className="chat-header">
          <strong>Wollok</strong>
          <span>Tutor de programación</span>
        </header>

        <section className="chat">
          <div className="messages">
            {activeChat?.messages.map((chatMessage) => (
              <div
                key={chatMessage.id}
                className={`message-row ${
                  chatMessage.role === "Alumno"
                    ? "student-row"
                    : "wollok-row"
                }`}
              >
                {chatMessage.role === "Wollok" && (
                  <div className="avatar">W</div>
                )}

                <div
                  className={`message-bubble ${
                    chatMessage.role === "Alumno"
                      ? "student-message"
                      : "wollok-message"
                  }`}
                >
                  {chatMessage.role === "Wollok" && (
                    <span className="message-role">
                      Wollok
                    </span>
                  )}

                  <p>{chatMessage.content}</p>

                  {chatMessage.linkedChatId && (
                    <div className="linked-chat">
                      <div className="linked-chat-info">
                        <span className="linked-icon">▢</span>

                        <div>
                          <strong>
                            {chatMessage.linkedChatTitle}
                          </strong>

                          <small>
                            Conversación anterior
                          </small>
                        </div>
                      </div>

                      <button
                        onClick={() =>
                          openChat(chatMessage.linkedChatId!)
                        }
                      >
                        Abrir chat
                      </button>
                    </div>
                  )}
                </div>
              </div>
            ))}

            {loading && (
              <div className="message-row wollok-row">
                <div className="avatar">W</div>

                <div className="message-bubble wollok-message">
                  <span className="message-role">
                    Wollok
                  </span>

                  <p>Pensando...</p>
                </div>
              </div>
            )}

            <div ref={bottomRef} />
          </div>

          <div className="chat-input-area">
            <div className="input-container">
              <input
                value={message}
                onChange={(event) =>
                  setMessage(event.target.value)
                }
                onKeyDown={(event) => {
                  if (event.key === "Enter") {
                    sendMessage();
                  }
                }}
                placeholder="Preguntale algo sobre Wollok..."
              />

              <button
                onClick={sendMessage}
                disabled={loading}
              >
                →
              </button>
            </div>
          </div>
        </section>
      </main>
    </div>
  );
}

export default App;