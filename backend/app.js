const express = require('express');
const morgan = require('morgan');
const cors = require('cors');
const path = require('path');
const { json } = require('body-parser');
const MongoClient = require('mongodb').MongoClient;
const ServerApiVersion = require('mongodb'). ServerApiVersion;
const { ObjectId } = require('mongodb');
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
app.get('/get/evento', async function (req, res) {
    const id = req.query.id;
    try {
        // Connect the client to the server	(optional starting in v4.7)
        await client.connect();
        const database = client.db("proyecto_informatico"); //schema
        const collection = database.collection("test"); //table
        // Check if the id already exists in the collection
        const result = await collection.findOne({ _id: new ObjectId(id) });
        if (!result) {
            // If the id already exists, send a message to the client
            res.send(`El id ${id} no existe en la base de datos`);
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
        const database = client.db("proyecto_informatico");
        const collection = database.collection("test");
        //if the nombre doesn't exist, insert it into the collection
        await collection.insertOne(data);
        //send the result to the client
        res.send("se ha insertado correctamente");
    } finally {
        await client.close();
    }
});

app.put('/update/evento', async function (req, res) {
    const id = req.query.id;
    const data = req.body;
    try{
        await client.connect();
        const database = client.db("proyecto_informatico");
        const collection = database.collection("test");
        //check if the id already exists in the collection, if exists send a message to the client and exit
        const result = await collection.findOne({ _id: new ObjectId(id) });
        const result2 = await collection.findOne({ nombre: data.nombre });
        if(!result || result2){
            res.send(`El id ${id} no existe en la base de datos o el nuevo nombre ya existe`);
        }
        else{
            //if the id doesn't exist, insert it into the collection
            await collection.updateOne({_id: new ObjectId(id)}, {$set: data});
            //send the result to the client
            res.send("se ha actualizado correctamente");
        }
    } finally {
        await client.close();
    }
}); 

app.delete('/delete/evento', async function (req, res) {
    const id = req.query.id;
    try{
        await client.connect();
        const database = client.db("proyecto_informatico");
        const collection = database.collection("test");
        //check if the id already exists in the collection, if exists send a message to the client and exit
        const result = await collection.findOne({ _id: new ObjectId(id) });
        if(!result){
            res.send(`El id ${id} no existe en la base de datos`);
        }
        else{
            //if the id doesn't exist, insert it into the collection
            await collection.deleteOne({_id: new ObjectId(id)});
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
        const database = client.db("proyecto_informatico");
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
            const database = client.db("proyecto_informatico");
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
      const database = client.db("proyecto_informatico");
      const collection = database.collection("alumnos");
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
      const database = client.db("proyecto_informatico");
      const collection = database.collection("alumnos");
  
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
        const database = client.db("proyecto_informatico");
        const collection = database.collection("alumnos");
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

app.delete('/delete/alumno', async function (req, res) {
    const matricula = req.query.matricula;
    try{
        await client.connect();
        const database = client.db("proyecto_informatico");
        const collection = database.collection("alumnos");
        //check if the nombre already exists in the collection, if exists send a message to the client and exit
        const result = await collection.findOne({ matricula: matricula });
        if(!result){
            res.send(`El alumno con matricula ${matricula} no existe en la base de datos`);
        }
        else{
            //if the nombre doesn't exist, insert it into the collection
            await collection.deleteOne({matricula: matricula});
            //send the result to the client
            res.send("se ha eliminado correctamente");
        }
    } finally {
        await client.close();
    }
});

// Hay que arreglar los ingresos y egresos ya que el length no se puede medir si no hay nada en el array y tira error
// falta que despues de cada movimiento se calcule el total y se actualice en la base de datos

app.get('/get/all/ingresos', async function (req, res) {
    const id = req.query.id; // assuming the query parameter is named "id"
    try {
        await client.connect();
        const database = client.db("proyecto_informatico");
        const collection = database.collection("test");
        // Check if the document already exists in the collection
        const result = await collection.findOne({ _id: new ObjectId(id) }); // using ObjectId to convert the string id to a BSON ObjectId
        if (!result) {
            // If the document doesn't exist, send a message to the client
            res.send(`El evento con el id "${id}" no existe en la base de datos`);
        } else {
            // sum the first position of the arrays of ingresos and returns the result
            var suma = 0;
            for (var i = 0; i < result.ingresos.length; i++) {
                    if (result.ingresos[i] != null){
                            suma += result.ingresos[i][0];
                    }
            }
            res.send(`El total de ingresos del evento ${result.nombre} es: ${suma}`); // using the "nombre" field from the result document
        }
    } finally {
        await client.close();
    }
});

app.post('/add/ingreso', async function (req, res) {
    const id = req.query.id;
    const data = req.body;
    const data2 = data.ingresos;
    console.log(data2);
    try{
        await client.connect();
        const database = client.db("proyecto_informatico");
        const collection = database.collection("test");
        //check if the id already exists in the collection, if exists send a message to the client and exit
        const result = await collection.findOne({ _id: new ObjectId(id) });
        if(result){
            // if the id exists, add the data to the array named ingresos inside the one that has the same id
            await collection.updateOne({_id: new ObjectId(id)}, {$push: {ingresos: data2}});
            //send the result to the client
            res.send("se ha insertado correctamente");   
        }
        else{
            res.send(`El id ${id} no existe en la base de datos`);
        }
    } finally {
        await client.close();
    }
});

app.get('/get/all/egresos', async function (req, res) {
        const id = req.query.id;
        try {
            await client.connect();
            const database = client.db("proyecto_informatico");
            const collection = database.collection("test");
            // Check if the document already exists in the collection
            const result = await collection.findOne({ _id: new ObjectId(id) });
            if (!result) {
                // If the document doesn't exist, send a message to the client
                res.send(`El evento con el id "${id}" no existe en la base de datos`);
            } else {
                // sum the first position of the arrays of egresos and returns the result
                var suma = 0;
                for (var i = 0; i < result.egresos.length; i++) {
                        if (result.egresos[i] != null){
                                suma += result.egresos[i][0];
                        }
                }
                res.send(`El total de egresos del evento ${result.nombre} es: ${suma}`);
            }
        } finally {
            await client.close();
        }
});

app.post('/add/egreso', async function (req, res) {
        const id = req.query.id;
        const data = req.body;
        const data2 = data.egresos;
        console.log(data2);
        try{
                await client.connect();
                const database = client.db("proyecto_informatico");
                const collection = database.collection("test");
                //check if the id already exists in the collection, if exists send a message to the client and exit
                const result = await collection.findOne({ _id: new ObjectId(id) });
                if(result){
                        // if the id exists, add the data to the array named egresos inside the one that has the same id
                        await collection.updateOne({_id: new ObjectId(id)}, {$push: {egresos: data2}});
                        //send the result to the client
                        res.send("se ha insertado correctamente");   
                }
                else{
                        res.send(`El id ${id} no existe en la base de datos`);
                }
        } finally {
                await client.close();
        }
});

app.get('/get/total', async function (req, res) {
        //total is all ingresos - all egresos
        const id = req.query.id;
        try {
            await client.connect();
            const database = client.db("proyecto_informatico");
            const collection = database.collection("test");
            // Check if the document already exists in the collection
            const result = await collection.findOne({ _id: new ObjectId(id) });
            if (!result) {
                // If the document doesn't exist, send a message to the client
                res.send(`El evento con el id "${id}" no existe en la base de datos`);
            } else {
                // sum the first position of the arrays of ingresos and returns the result
                var suma = 0;
                for (var i = 0; i < result.ingresos.length; i++) {
                        if (result.ingresos[i] != null){
                                suma += result.ingresos[i][0];
                        }
                }
                var suma2 = 0;
                for (var i = 0; i < result.egresos.length; i++) {
                        if (result.egresos[i] != null){
                                suma2 += result.egresos[i][0];
                        }
                }
                res.send(`El total de ingresos del evento ${result.nombre} es: ${suma-suma2}`);
            }
        } finally {
            await client.close();
        }
});


app.get('/get/all/asistencias', async function (req, res) {
    const id = req.query.id;
    try{
        await client.connect();
        const database = client.db("proyecto_informatico");
        const collection = database.collection("test");
        const result = await collection.findOne({ _id: new ObjectId(id) });
        if(!result){
            res.send(`El id ${id} no existe en la base de datos`);
        }
        else{
            res.send(result.asistencia);
        }
    } finally {
        await client.close();
    }
});

app.post('/add/asistencia', async function (req, res) {
    const id = req.query.id;
    const matricula = req.query.matricula;

    try{
        await client.connect();
        const database = client.db("proyecto_informatico");
        const collection = database.collection("test");
        const result = await collection.findOne({ _id: new ObjectId(id) });
        const collection2 = database.collection("alumnos");
        const result2 = await collection2.findOne({ matricula: matricula });
        //check if the matricula already exists in the collection, if exists send a message to the client and exit
        if(!result2){
            res.send(`El alumno con matricula ${matricula} no existe en la base de datos`);             
        }
        else{
            if(!result){
                res.send(`El id ${id} no existe en la base de datos`);
            }
            else{
                //if the matricula doesn't exist in the collection, insert it into the collection
                if(result.asistencia.includes(matricula)){
                    res.send(`El alumno con matricula ${matricula} ya esta registrado en el evento`);
                }else{
                    await collection.updateOne({_id: new ObjectId(id)}, {$push: {asistencia: matricula}});
                    res.send("se ha insertado correctamente");
                }
            }
        }
    } finally {
        await client.close();
    }
});



const puerto = process.env.PORT || 4040;

app.listen(puerto, function () {
    console.log(`Servidor escuchando en el puerto: ${puerto}!`);
});