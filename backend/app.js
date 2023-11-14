const express = require('express');
const morgan = require('morgan');
const cors = require('cors');
const path = require('path');
const bcrypt = require('bcrypt');
const { json } = require('body-parser');
const MongoClient = require('mongodb').MongoClient;
const ServerApiVersion = require('mongodb').ServerApiVersion;
const { ObjectId } = require('mongodb');
require('dotenv').config();

const app = express(); // Inicializamos express.
const uri = process.env.MONGODB_URI;

if (!uri) {
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


app.post('/users/login', async function (req, res) {
    const matricula = parseInt(req.query.matricula);
    const contraseña = req.query.password;

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
            if (await bcrypt.compare(contraseña, result.contraseña)) {
                res.send('Success');
            }
            else {
                res.send('Not Allowed');
            }
        }
    } catch {
        res.status(500).send();
    } finally {
        await client.close();
    }
});




// Ruta Centro de Alumnos

app.get('/get/caa', async function (req, res) {
    const id = req.query.id;
    try {
        // Connect the client to the server	(optional starting in v4.7)
        await client.connect();
        const database = client.db("proyecto_informatico"); //schema
        const collection = database.collection("caa"); //table
        // Check if the id already exists in the collection
        const result = await collection.findOne({ _id: new ObjectId(id) });
        if (!result) {
            // If the id already exists, send a message to the client
            res.send(`El id ${id} no existe en la base de datos`);
        }
        else {
            //return the whole row of the collection
            res.send(result);
        }

    } catch (error) {
        console.log(error);
        res.status(500).send('Error en el servidor');
    } finally {
        // Ensures that the client will close when you finish/error
        await client.close();
    }
});

app.post('/add/caa', async function (req, res) {
    const data = req.body;
    try {
        await client.connect();
        const database = client.db("proyecto_informatico");
        const collection = database.collection("caa");
        //if the nombre doesn't exist, insert it into the collection
        await collection.insertOne(data);
        //send the result to the client
        res.send("se ha insertado correctamente");
    } catch (error) {
        console.log(error);
        res.status(500).send('Error en el servidor');
    } finally {
        await client.close();
    }
});

app.put('/update/caa', async function (req, res) {
    const id = req.query.id;
    const data = req.body;
    try {
        await client.connect();
        const database = client.db("proyecto_informatico");
        const collection = database.collection("caa");
        //check if the id already exists in the collection, if exists send a message to the client and exit
        const result = await collection.findOne({ _id: new ObjectId(id) });
        const result2 = await collection.findOne({ nombre: data.nombre });
        if (!result || result2) {
            res.send(`El id ${id} no existe en la base de datos o el nuevo nombre ya existe`);
        }
        else {
            //if the id doesn't exist, insert it into the collection
            await collection.updateOne({ _id: new ObjectId(id) }, { $set: data });
            //send the result to the client
            res.send("se ha actualizado correctamente");
        }
    } catch (error) {
        console.log(error);
        res.status(500).send('Error en el servidor');
    } finally {
        await client.close();
    }
});

app.delete('/delete/caa', async function (req, res) {
    const id = req.query.id;
    try {
        await client.connect();
        const database = client.db("proyecto_informatico");
        const collection = database.collection("caa");
        //check if the id already exists in the collection, if exists send a message to the client and exit
        const result = await collection.findOne({ _id: new ObjectId(id) });
        if (!result) {
            res.send(`El id ${id} no existe en la base de datos`);
        }
        else {
            //if the id doesn't exist, insert it into the collection
            await collection.deleteOne({ _id: new ObjectId(id) });
            //send the result to the client
            res.send("se ha eliminado correctamente");
        }
    } catch (error) {
        console.log(error);
        res.status(500).send('Error en el servidor');
    } finally {
        await client.close();
    }
});

app.get('/get/all/caas', async function (req, res) {
    try {
        await client.connect();
        const database = client.db("proyecto_informatico");
        const collection = database.collection("caa");
        const data = await collection.find().toArray();
        res.send(data);
    } catch (error) {
        console.log(error);
        res.status(500).send('Error en el servidor');
    }
    finally {
        await client.close();
    }
});

app.get('/get/ingresos/caa', async function (req, res) {
    const id = req.query.id;
    try {
        await client.connect();
        const database = client.db("proyecto_informatico");
        const collection = database.collection("caa");
        const result = await collection.findOne({ _id: new ObjectId(id) });
        if (!result) {
            res.status(404).send(`El id ${id} no existe en la base de datos`);
        } else {
            if (!result.ingresos) {
                res.send("0");
            } else {
                //check if result.ingresos exists
                var suma = 0;
                for (var i = 0; i < result.ingresos.length; i++) {
                    if (result.ingresos[i] != null) {
                        suma += result.ingresos[i][0];
                    }
                }
                res.send(suma.toString());
            }
        }
    } catch (error) {
        console.log(error);
        res.status(500).send('Error en el servidor');
    } finally {
        await client.close();
    }
});

app.post('/add/ingreso/caa', async function (req, res) {
    const id = req.query.id;
    const data = req.body;
    const data2 = data.ingresos;

    // Agrega la fecha actual en formato ISO 8601
    const currentDate = new Date().toISOString();
    data2.push(currentDate); // Push the amount, description, and current date to the data2 array

    try {
        await client.connect();
        const database = client.db("proyecto_informatico");
        const collection = database.collection("caa");
        //check if the id already exists in the collection, if exists send a message to the client and exit
        const result = await collection.findOne({ _id: new ObjectId(id) });
        if (result) {
            // if the id exists, add the data to the array named ingresos inside the one that has the same id
            await collection.updateOne({ _id: new ObjectId(id) }, { $push: { ingresos: data2 } });

            await collection.updateOne({ _id: new ObjectId(id) }, { $set: { total: result.total + data2[0] } });
            //send the result to the client
            res.send("se ha insertado correctamente");
        }
        else {
            res.send(`El id ${id} no existe en la base de datos`);
        }
    } catch (error) {
        console.log(error);
        res.status(500).send('Error en el servidor');
    } finally {
        await client.close();
    }
});

app.get('/get/egresos/caa', async function (req, res) {
    const id = req.query.id;
    try {
        await client.connect();
        const database = client.db("proyecto_informatico");
        const collection = database.collection("caa");
        const result = await collection.findOne({ _id: new ObjectId(id) });
        if (!result) {
            res.send(`El id ${id} no existe en la base de datos`);
        }
        else {
            if (result.egresos) {
                var suma = 0;
                for (var i = 0; i < result.egresos.length; i++) {
                    if (result.egresos[i] != null) {
                        suma += result.egresos[i][0];
                    }
                }
                res.send(suma.toString());
            } else {
                res.send("0");
            }
        }
    } catch (error) {
        console.log(error);
        res.status(500).send('Error en el servidor');
    } finally {
        await client.close();
    }
});

app.post('/add/egreso/caa', async function (req, res) {
    const id = req.query.id;
    const data = req.body;
    const data2 = data.egresos;

    // Agrega la fecha actual en formato ISO 8601
    const currentDate = new Date().toISOString();
    data2.push(currentDate); // Push the amount, description, and current date to the data2 array

    try {
        await client.connect();
        const database = client.db("proyecto_informatico");
        const collection = database.collection("caa");
        //check if the id already exists in the collection, if exists send a message to the client and exit
        const result = await collection.findOne({ _id: new ObjectId(id) });
        if (result) {
            // if the id exists, add the data to the array named egresos inside the one that has the same id
            await collection.updateOne({ _id: new ObjectId(id) }, { $push: { egresos: data2 } });

            if (result.total) {
                await collection.updateOne({ _id: new ObjectId(id) }, { $set: { total: result.total - data2[0] } });
            } else {
                await collection.updateOne({ _id: new ObjectId(id) }, { $set: { total: -data2[0] } });

            }
            //send the result to the client
            res.send("se ha insertado correctamente");
        }
        else {
            res.send(`El id ${id} no existe en la base de datos`);
        }
    } catch (error) {
        console.log(error);
        res.status(500).send('Error en el servidor');
    } finally {
        await client.close();
    }
});

app.get('/get/total/caa', async function (req, res) {
    const id = req.query.id;
    try {
        await client.connect();
        const database = client.db("proyecto_informatico");
        const collection = database.collection("caa");
        const result = await collection.findOne({ _id: new ObjectId(id) });
        if (!result) {
            res.send(`El id ${id} no existe en la base de datos`);
        }
        else {
            res.send(result.total.toString());
        }
    } catch (error) {
        console.log(error);
        res.status(500).send('Error en el servidor');
    } finally {
        await client.close();
    }
});

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
        else {
            //return the whole row of the collection
            res.send(result);
        }

    } catch (error) {
        console.log(error);
        res.status(500).send('Error en el servidor');
    } finally {
        // Ensures that the client will close when you finish/error
        await client.close();
    }
});

app.post('/add/evento', async function (req, res) {
    const id_creador = req.query.id_creador;
    const data = req.body;

    if (!data.fecha_inicio || !data.fecha_final) {
        // Si falta una o ambas fechas, establece ambas en la fecha y hora actual.
        const fechaActual = new Date();
        data.fecha_inicio = fechaActual.toISOString();
        data.fecha_final = fechaActual.toISOString();
    }

    try {


        await client.connect();
        const database = client.db("proyecto_informatico");
        const collection = database.collection("test");
        console.log(id_creador.length);
        let es_alumno = false;
        if (id_creador.length < 24) {
            console.log("entro");
            es_alumno = true;
        }
        //check if the id_creador exists either in alumnos or caa
        if (es_alumno) {
            const alumnos = database.collection("alumnos");
            const result = await alumnos.findOne({ matricula: parseInt(id_creador) });
            if (!result) {
                res.send(`El id ${id_creador} no existe en la base de datos`);
                respuestaEnviada = true;
            } else {
                //if the id_creador exists, insert it into the collection
                data.id_creador = id_creador;
                data.global = false;
                //insert the event into the collection
                await collection.insertOne(data);
                res.send("se ha insertado correctamente");

                //add the id of the event to the array mis_eventos of the alumno
                const mis_eventos = result.mis_eventos;
                mis_eventos.push(data._id);
                await alumnos.updateOne({ matricula: parseInt(id_creador) }, { $set: { mis_eventos: mis_eventos } });
            }
        } else {
            const caa = database.collection("caa");
            const result = await caa.findOne({ _id: new ObjectId(id_creador) });
            if (!result) {
                res.send(`El id ${id_creador} no existe en la base de datos`);
                respuestaEnviada = true;
            } else {
                //if the id_creador exists, insert it into the collection
                data.id_creador = id_creador;
                //insert the event into the collection
                await collection.insertOne(data);
                res.send("se ha insertado correctamente");
                respuestaEnviada = true;
            }
        }
    } catch (error) {
        console.log(error);
        res.status(500).send('Error en el servidor');
    } finally {
        await client.close();
    }
});


app.put('/update/evento', async function (req, res) {
    const id = req.query.id;
    const data = req.body;
    try {
        await client.connect();
        const database = client.db("proyecto_informatico");
        const collection = database.collection("test");
        //check if the id already exists in the collection, if exists send a message to the client and exit
        const result = await collection.findOne({ _id: new ObjectId(id) });
        const result2 = await collection.findOne({ nombre: data.nombre });
        if (!result || result2) {
            res.send(`El id ${id} no existe en la base de datos o el nuevo nombre ya existe`);
        }
        else {
            //if the id doesn't exist, insert it into the collection
            await collection.updateOne({ _id: new ObjectId(id) }, { $set: data });
            //send the result to the client
            res.send("se ha actualizado correctamente");
        }
    } catch (error) {
        console.log(error);
        res.status(500).send('Error en el servidor');
    } finally {
        await client.close();
    }
}); 
app.delete('/delete/evento', async function (req, res) {
    const id = req.query.id;
    try {
        await client.connect();
        const database = client.db("proyecto_informatico");
        const collection = database.collection("test");
        //check if the id already exists in the collection, if exists send a message to the client and exit
        const result = await collection.findOne({ _id: new ObjectId(id) });
        if (!result) {
            res.send(`El id ${id} no existe en la base de datos`);
        }
        else {
            //if the id doesn't exist, insert it into the collection
            await collection.deleteOne({ _id: new ObjectId(id) });
            //send the result to the client
            res.send("se ha eliminado correctamente");
        }
    } catch (error) {
        console.log(error);
        res.status(500).send('Error en el servidor');
    } finally {
        await client.close();
    }
});

app.get('/get/all/eventos', async function (req, res) {
    try {
        await client.connect();
        const database = client.db("proyecto_informatico");
        const collection = database.collection("test");
        //check if the nombre already exists in the collection, if exists send a message to the client and exit
        const result = await collection.find().toArray();
        if (!result) {
            res.send(`No hay eventos en la base de datos`);
        }
        else {
            //if the nombre doesn't exist, insert it into the collection
            res.send(result);
        }
    } finally {
        await client.close();
    }
});

/*app.get('/get/filter/eventos', async function (req, res) {
    const categoria = req.query.categoria;
    if (categoria != "certamen" && categoria != "actividad") {
        res.send(`La categoria ${categoria} no existe en la base de datos`);
    } else {
        try {
            await client.connect();
            const database = client.db("proyecto_informatico");
            const collection = database.collection("test");
            //check if the nombre already exists in the collection, if exists send a message to the client and exit
            const result = await collection.find({ categoria: categoria }).toArray();
            if (!result) {
                res.send(`No hay eventos del tipo ${categoria} en la base de datos`);
            }
            else {
                res.send(result);
            }
        } catch (error) {
            console.log(error);
            res.status(500).send('Error en el servidor');
        } finally {
            await client.close();
        }
    }
});*/

app.get('/get/filter/eventos', async (req, res) => {
    try {
        await client.connect();
        const database = client.db("proyecto_informatico");
        const collection = database.collection("test");

        // Obtén todos los parámetros de filtro de la URL
        const parametrosFiltro = req.query;

        // Inicializa un objeto de filtro vacío
        const filtroFinal = {};

        // Agrega parámetros al filtro final según sea necesario
        const booleanMapping = {
            'true': true,
            'false': false
        };
        
        for (const param in parametrosFiltro) {
            if (param === 'visible' || param ==='global') {
                // Si el parámetro es 'visible', mapear el valor al formato correcto
                filtroFinal[param] = booleanMapping[parametrosFiltro[param]];
            } else {
                filtroFinal[param] = parametrosFiltro[param];
            }
        }
        
        //console.log(req.query.visible);
        // Realiza la consulta en la colección utilizando el filtro final
        const result = await collection.find(filtroFinal).toArray();
        //console.log(result);
        if (result.length === 0) {
            res.send('No se encontraron eventos que cumplan con los criterios de filtro.');
        } else {
            res.send(result);
        }
    } catch (error) {
        console.log(error);
        res.status(500).send('Error en el servidor');
    } finally {
        await client.close();
    }
});



app.get('/get/alumno', async function (req, res) {
    const matricula = parseInt(req.query.matricula);
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
    } catch (error) {
        console.log(error);
        res.status(500).send('Error en el servidor');
    } finally {
        await client.close();
    }
});

app.post('/add/alumno', async function (req, res) {
    const nombre = req.query.nombre;
    const matricula = req.query.matricula;
    const apellido = req.query.apellido;
    const id_caa = req.query.id_caa;
    const es_caa = req.query.es_caa;
    const data = req.body;
    const mis_eventos = [];
    const mis_asistencias = [];

    // Unify the data into a single object
    data.nombre = nombre;
    data.apellido = apellido;
    data.matricula = parseInt(matricula);
    data.id_caa = id_caa;
    data.es_caa = es_caa;
    data.mis_eventos = mis_eventos;
    data.mis_asistencias = mis_asistencias;

    //check if the matricula has at least 4 digits
    if (matricula.length < 4) {
        res.send(`La matricula ${matricula} no tiene el minimo de 4 digitos`);
        return;
    }

    //first two digits of the matricula and first two digits of the nombre in lowercase are the password
    const password = matricula.substring(0, 4) + nombre.toLowerCase().substring(0, 2) + apellido.toLowerCase().substring(0,2);
    data.contraseña = password
    try {
        await client.connect();
        const database = client.db("proyecto_informatico");
        const collection = database.collection("alumnos");

        // Check if the alumno already exists in the collection
        const result = await collection.findOne({ matricula: data.matricula });
        if (result) {
            // If the alumno already exists, send a message to the client
            res.send(`El alumno ${data.matricula} ya existe en la base de datos`);
        } else {
            // If the alumno doesn't exist, insert it into the collection
            data.contraseña = await bcrypt.hash(password, 10);
            await collection.insertOne(data);
            // Send the result to the client
            res.send("se ha insertado correctamente");
        }
    } catch (error) {
        console.log(error);
        res.status(500).send('Error en el servidor');
    } finally {
        await client.close();
    }
});

app.put('/update/alumno', async function (req, res) {
    const matricula = parseInt(req.query.matricula);
    const data = req.body;

    try {
        await client.connect();
        const database = client.db("proyecto_informatico");
        const collection = database.collection("alumnos");
        //check if the nombre already exists in the collection, if exists send a message to the client and exit
        const result = await collection.findOne({ matricula: matricula });
        if (!result) {
            res.send(`El alumno con matricula ${matricula} no existe en la base de datos`);
        }
        else {
            //if the nombre doesn't exist, insert it into the collection
            await collection.updateOne({ matricula: matricula }, { $set: data });
            //send the result to the client
            res.send("se ha actualizado correctamente");
        }
    } catch (error) {
        console.log(error);
        res.status(500).send('Error en el servidor');
    } finally {
        await client.close();
    }
});

app.delete('/delete/alumno', async function (req, res) {
    const matricula = parseInt(req.query.matricula);
    try {
        await client.connect();
        const database = client.db("proyecto_informatico");
        const collection = database.collection("alumnos");
        //check if the nombre already exists in the collection, if exists send a message to the client and exit
        const result = await collection.findOne({ matricula: matricula });
        if (!result) {
            res.send(`El alumno con matricula ${matricula} no existe en la base de datos`);
        }
        else {
            //if the nombre doesn't exist, insert it into the collection
            await collection.deleteOne({ matricula: matricula });
            //send the result to the client
            res.send("se ha eliminado correctamente");
        }
    } catch (error) {
        console.log(error);
        res.status(500).send('Error en el servidor');
    } finally {
        await client.close();
    }
});

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
            if (result.ingresos) {
                var suma = 0;
                for (var i = 0; i < result.ingresos.length; i++) {
                    if (result.ingresos[i] != null) {
                        suma += result.ingresos[i][0];
                    }
                }
                res.send(suma.toString()); // using the "nombre" field from the result document
            } else {
                res.send("0");
            }
        }
    } catch (error) {
        console.log(error);
        res.status(500).send('Error en el servidor');
    } finally {
        await client.close();
    }
});

app.post('/add/ingreso', async function (req, res) {
    const id = req.query.id;
    const data = req.body;
    const data2 = data.ingresos;

    // Agrega la fecha actual en formato ISO 8601
    const currentDate = new Date().toISOString();
    data2.push(currentDate); // Push the amount, description, and current date to the data2 array



    try {
        await client.connect();
        const database = client.db("proyecto_informatico");
        const collection = database.collection("test");
        const caa = database.collection("caa");
        //check if the id already exists in the collection, if exists send a message to the client and exit
        const result = await collection.findOne({ _id: new ObjectId(id) });
        id_caa = result.id_caa;
        const caa_result = await caa.findOne({ _id: new ObjectId(id_caa) });

        if (result) {
            // if the id exists, add the data to the array named ingresos inside the one that has the same id
            await collection.updateOne({ _id: new ObjectId(id) }, { $push: { ingresos: data2 } });
            data3 = data2;
            data3.push(id);
            await caa.updateOne({ _id: new ObjectId(id_caa) }, { $push: { ingresos: data2 } });
            //send the result to the client

            await collection.updateOne({ _id: new ObjectId(id) }, { $set: { total: result.total + data2[0] } });
            //add to the data the id of the event to the array data2
            data2.push(id);
            await caa.updateOne({ _id: new ObjectId(id_caa) }, { $set: { total: caa_result.total + data2[0] } });
            res.send("se ha insertado correctamente");
        }
        else {
            res.send(`El id ${id} no existe en la base de datos`);
        }
    } catch (error) {
        console.log(error);
        res.status(500).send('Error en el servidor');
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
            if (result.egresos) {
                var suma = 0;
                for (var i = 0; i < result.egresos.length; i++) {
                    if (result.egresos[i] != null) {
                        suma += result.egresos[i][0];
                    }
                }
                res.send(suma.toString()); // Send the calculated value as the response
            } else {
                res.send("0");
            }
        }
    } catch (error) {
        console.log(error);
        res.status(500).send('Error en el servidor');
    } finally {
        await client.close();
    }
});


app.post('/add/egreso', async function (req, res) {
    const id = req.query.id;
    const data = req.body;
    const data2 = data.egresos;

    // Agrega la fecha actual en formato ISO 8601
    const currentDate = new Date().toISOString();
    data2.push(currentDate); // Push the amount, description, and current date to the data2 array
    try {
        await client.connect();
        const database = client.db("proyecto_informatico");
        const collection = database.collection("test");
        //check if the id already exists in the collection, if exists send a message to the client and exit
        const caa = database.collection("caa");
        const result = await collection.findOne({ _id: new ObjectId(id) });
        if (result) {
            // if the id exists, add the data to the array named egresos inside the one that has the same id
            await collection.updateOne({ _id: new ObjectId(id) }, { $push: { egresos: data2 } });
            data3 = data2;
            data3.push(id);
            await caa.updateOne({ _id: new ObjectId(result.id_caa) }, { $push: { egresos: data2 } });
            //update total
            await collection.updateOne({ _id: new ObjectId(id) }, { $set: { total: result.total - data2[0] } });
            await caa.updateOne({ _id: new ObjectId(result.id_caa) }, { $set: { total: result.total - data2[0] } });
            res.send("se ha insertado correctamente");
        }
        else {
            res.send(`El id ${id} no existe en la base de datos`);
        }
    } catch (error) {
        console.log(error);
        res.status(500).send('Error en el servidor');
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

            res.send(result.total.toString());
        }
    } catch (error) {
        console.log(error);
        res.status(500).send('Error en el servidor');
    } finally {
        await client.close();
    }
});

app.get('/get/all/asistencias', async function (req, res) {
    const id = req.query.id;
    try {
        await client.connect();
        const database = client.db("proyecto_informatico");
        const collection = database.collection("test");
        const result = await collection.findOne({ _id: new ObjectId(id) });
        if (!result) {
            res.send(`El id ${id} no existe en la base de datos`);
        }
        else {
            res.send(result.asistencia);
        }
    } catch (error) {
        console.log(error);
        res.status(500).send('Error en el servidor');
    } finally {
        await client.close();
    }
});

app.post('/add/asistencia', async function (req, res) { //quizá añadir nombre del alumno
    const id = req.query.id;
    const matricula = parseInt(req.query.matricula);

    try {
        await client.connect();
        const database = client.db("proyecto_informatico");
        const collection = database.collection("test");
        const result = await collection.findOne({ _id: new ObjectId(id) });
        const collection2 = database.collection("alumnos");
        const result2 = await collection2.findOne({ matricula: matricula });
        //check if the matricula already exists in the collection, if exists send a message to the client and exit
        if (!result2) {
            res.send(`El alumno con matricula ${matricula} no existe en la base de datos`);
        }
        else {
            if (!result) {
                res.send(`El id ${id} no existe en la base de datos`);
            }
            else {
                //if the matricula doesn't exist in the collection, insert it into the collection
                if (result.asistencia.includes(matricula)) {
                    res.send(`El alumno con matricula ${matricula} ya esta registrado en el evento`);
                }else{
                    await collection.updateOne({_id: new ObjectId(id)}, {$push: {asistencia: matricula}});
                    // add the id of the event to the array mis_asistencias of the alumno
                    const mis_asistencias = result2.mis_asistencias;
                    mis_asistencias.push(id);
                    await collection2.updateOne({ matricula: parseInt(matricula) }, { $set: { mis_asistencias: mis_asistencias } });
                    res.send("se ha insertado correctamente");
                }
            }
        }
    } catch (error) {
        console.log(error);
        res.status(500).send('Error en el servidor');
    } finally {
        await client.close();
    }
});


const puerto = process.env.PORT || 4040;

    app.listen(puerto, function () {
        console.log(`Servidor escuchando en el puerto: ${puerto}!`);
    });