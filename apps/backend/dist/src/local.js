import dotenv from "dotenv";
dotenv.config({ path: ".env.local" });
import { createApp } from "./app";
const port = Number(process.env.PORT ?? 3002);
const app = createApp();
app.listen({ port, host: "0.0.0.0" }).then(() => {
    console.log(`backend listening on http://localhost:${port}`);
});
