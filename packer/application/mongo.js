const http = require('http');
const MongoClient = require('mongodb').MongoClient;

const port = 3000;
const url = 'mongodb://54.237.119.78:27017';

const client = new MongoClient(url, { useUnifiedTopology: true });

// Conectar a MongoDB fuera del controlador de solicitudes.
client.connect(err => {
  if (err) {
    console.error(`Error connecting to MongoDB: ${err.message}`);
    // Si no se puede conectar a MongoDB, no tiene sentido iniciar el servidor HTTP.
    process.exit(1);
  }
});

const server = http.createServer((req, res) => {
  // La conexión a MongoDB ya está abierta, solo respondemos.
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain');
  res.end(`Connected to MongoDB at ${url}`);
  // No cerramos el cliente aquí.
});

server.listen(port, '0.0.0.0', () => {
  console.log(`Server running on port ${port}`);
});
