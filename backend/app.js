const express = require('express');
const morgan = require('morgan');
const cors = require('cors');
const path = require('path');
const { json } = require('body-parser');
const MongoClient = require('mongodb').MongoClient;
const ServerApiVersion = require('mongodb'). ServerApiVersion;
require('dotenv').config();

const app = express(); // Inicializamos express.
const uri = process.env.MONGODB_URI;

if (!uri){
    console.log('No se ha especificado la URI de la base de datos');
    process.exit(1);
}

const client = new MongoClient(uri, {
    serverApi: {
      version: ServerApiVersion.v1,
      strict: true,
      deprecationErrors: true,
    }
});

// Middlewares
app.use(morgan('tiny')); // Usamos morgan con el formato tiny.
app.use(cors()); // Usamos cors para evitar el bloqueo de peticiones.
app.use(express.json()) // Nos permite trabajar con el formato json.
// app.use(express.urlencoded({ extended: true })); 
//app.use(express.static(path.join(__dirname, 'public')));



// Rutas
app.post('/', async function (req, res) {
    const nombre = req.query.name;
    try {
        // Connect the client to the server	(optional starting in v4.7)
        await client.connect();
        const database = client.db("Proyecto_Informatico"); //schema
        const collection = database.collection("Enevs"); //table
        // Check if the nombre already exists in the collection
        const result = await collection.findOne({ nombre: nombre });
        if (result) {
            // If the nombre already exists, send a message to the client
            res.send(`El nombre ${nombre} ya existe en la base de datos`);
        } else {
            // If the nombre doesn't exist, insert it into the collection
            const insertResult = await collection.insertOne({ nombre: nombre });
            // Send the result to the client
            res.send(insertResult);
        }
    } finally {
        // Ensures that the client will close when you finish/error
        await client.close();
    }
});

app.get('/get/evento', async function (req, res) {
    const nombre = req.query.nombre;
    try {
        // Connect the client to the server	(optional starting in v4.7)
        await client.connect();
        const database = client.db("Proyecto_Informatico"); //schema
        const collection = database.collection("test"); //table
        // Check if the nombre already exists in the collection
        const result = await collection.findOne({ nombre: nombre });
        if (!result) {
            // If the nombre already exists, send a message to the client
            res.send(`El nombre ${nombre} no existe en la base de datos`);
        }
        else{
            //return the whole row of the collection
            res.send(result);
        }
            
    } finally {
        // Ensures that the client will close when you finish/error
        await client.close();
    }	
});

app.post('/add/evento', async function (req, res) {
    const data = req.body;
    try{
        await client.connect();
        const database = client.db("Proyecto_Informatico");
        const collection = database.collection("test");
        //check if the nombre already exists in the collection, if exists send a message to the client and exit
        const result = await collection.findOne({ nombre: data.nombre });
        if(result){
            res.send(`El nombre ${data.nombre} ya existe en la base de datos`);
        }
        else{
            //if the nombre doesn't exist, insert it into the collection
            await collection.insertOne(data);
            //send the result to the client
            res.send("se ha insertado correctamente");
        }
    } finally {
        await client.close();
    }
});

app.put('/update/evento', async function (req, res) {
    const nombre = req.query.nombre;
    const data = req.body;
    try{
        await client.connect();
        const database = client.db("Proyecto_Informatico");
        const collection = database.collection("test");
        //check if the nombre already exists in the collection, if exists send a message to the client and exit
        const result = await collection.findOne({ nombre: nombre });
        const result2 = await collection.findOne({ nombre: data.nombre });
        if(!result || result2){
            res.send(`El nombre ${nombre} no existe en la base de datos o el nuevo nombre ya existe`);
        }
        else{
            //if the nombre doesn't exist, insert it into the collection
            await collection.updateOne({nombre: nombre}, {$set: data});
            //send the result to the client
            res.send("se ha actualizado correctamente");
        }
    } finally {
        await client.close();
    }
});

app.delete('/delete/evento', async function (req, res) {
    const nombre = req.query.nombre;
    try{
        await client.connect();
        const database = client.db("Proyecto_Informatico");
        const collection = database.collection("test");
        //check if the nombre already exists in the collection, if exists send a message to the client and exit
        const result = await collection.findOne({ nombre: nombre });
        if(!result){
            res.send(`El nombre ${nombre} no existe en la base de datos`);
        }
        else{
            //if the nombre doesn't exist, insert it into the collection
            await collection.deleteOne({nombre: nombre});
            //send the result to the client
            res.send("se ha eliminado correctamente");
        }
    } finally {
        await client.close();
    }
});

app.get('/get/all/eventos', async function (req, res) {
    try{
        await client.connect();
        const database = client.db("Proyecto_Informatico");
        const collection = database.collection("test");
        //check if the nombre already exists in the collection, if exists send a message to the client and exit
        const result = await collection.find().toArray();
        if(!result){
            res.send(`No hay eventos en la base de datos`);
        }
        else{
            //if the nombre doesn't exist, insert it into the collection
            res.send(result);
        }
    } finally {
        await client.close();
    }
});   

app.get('/get/filter/eventos', async function (req, res) {
    const categoria = req.query.categoria;
    if (categoria!="certamen" && categoria!="actividad"){
        res.send(`La categoria ${categoria} no existe en la base de datos`);
    }else{
        try{
            await client.connect();
            const database = client.db("Proyecto_Informatico");
            const collection = database.collection("test");
            //check if the nombre already exists in the collection, if exists send a message to the client and exit
            const result = await collection.find({categoria: categoria}).toArray();
            if(!result){
                res.send(`No hay eventos del tipo ${categoria} en la base de datos`);
            }
            else{
                res.send(result);
            }
        } finally {
            await client.close();
        }
    }
});

app.get('/get/alumno', async function (req, res) {
    const matricula = req.query.matricula;
    try {
      await client.connect();
      const database = client.db("Proyecto_Informatico");
      const collection = database.collection("Alumnos");
      // Check if the alumno already exists in the collection
      const result = await collection.findOne({ matricula: matricula });
      if (!result) {
        // If the alumno already exists, send a message to the client
        res.send(`El alumno con la matricula "${matricula}" no existe en la base de datos`);
      } else {
        // If the alumno doesn't exist, insert it into the collection
        res.send(result);
      }
    } finally {
      await client.close();
    }
});

app.post('/add/alumno', async function (req, res) {
    const nombre = req.query.nombre;
    const matricula = req.query.matricula;
    const data = req.body;
  
    // Unify the data into a single object
    data.nombre = nombre;
    data.matricula = matricula;
    try {
      await client.connect();
      const database = client.db("Proyecto_Informatico");
      const collection = database.collection("Alumnos");
  
      // Check if the alumno already exists in the collection
      const result = await collection.findOne({ nombre: data.nombre });
      if (result) {
        // If the alumno already exists, send a message to the client
        res.send(`El alumno ${data.nombre} ya existe en la base de datos`);
      } else {
        // If the alumno doesn't exist, insert it into the collection
        const insertResult = await collection.insertOne(data);
  
        // Send the result to the client
        res.send("se ha insertado correctamente");
      }
    } finally {
      await client.close();
    }
});

app.put('/update/alumno', async function (req, res) {
    const matricula = req.query.matricula;
    const data = req.body;

    try{
        await client.connect();
        const database = client.db("Proyecto_Informatico");
        const collection = database.collection("Alumnos");
        //check if the nombre already exists in the collection, if exists send a message to the client and exit
        const result = await collection.findOne({ matricula: matricula });
        if(!result){
            res.send(`El alumno con matricula ${matricula} no existe en la base de datos`);
        }
        else{
            //if the nombre doesn't exist, insert it into the collection
            await collection.updateOne({matricula: matricula}, {$set: data});
            //send the result to the client
            res.send("se ha actualizado correctamente");
        }
    } finally {
        await client.close();
    }
});

const puerto = process.env.PORT || 4040;

app.listen(puerto, function () {
    // console.log('Example app listening on port '+ puerto);
    console.log(`Example app listening on port ${puerto}!`);
});