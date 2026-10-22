import { Pool } from "pg";
import "dotenv/config";

export const db = new Pool({
  host: process.env.DB_HOST,
  port: Number(process.env.DB_PORT),
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
});

export async function probarConexionDB() {
  const resultado = await db.query("SELECT NOW() AS fecha");

  console.log(
    "PostgreSQL conectado correctamente:",
    resultado.rows[0].fecha
  );
}