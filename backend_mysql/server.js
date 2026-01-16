require("dotenv").config();
const express = require("express");
const cors = require("cors");
const morgan = require("morgan");

const { createPoolFromEnv, initDb } = require("./db");

const { authRoutes } = require("./routes/auth");
const { packagesRoutes } = require("./routes/packages");
const { ordersRoutes } = require("./routes/orders");
const { adminRoutes } = require("./routes/admin");

const PORT = process.env.PORT || 3000;

const app = express();
app.use(cors());
app.use(express.json());
app.use(morgan("dev"));

app.get("/", (req, res) => res.send("OK - katering-preorder-backend"));

// Bootstrapping (MySQL)
(async () => {
  try {
    const db = createPoolFromEnv();
    await initDb(db);

    app.use("/api/auth", authRoutes(db));
    app.use("/api/packages", packagesRoutes(db));
    app.use("/api/orders", ordersRoutes(db));
    app.use("/api/admin", adminRoutes(db));

    app.listen(PORT, () => {
      console.log(`API running on http://localhost:${PORT}`);
    });
  } catch (err) {
    console.error("Failed to start API:", err);
    console.error(
      "Tips: pastikan database MySQL sudah dibuat dan .env sudah benar (DB_HOST/DB_USER/DB_PASSWORD/DB_NAME)."
    );
    process.exit(1);
  }
})();
