const express = require('express');
const morgan = require('morgan');
const cors = require('cors');
const bcrypt = require('bcrypt');
const { json } = require('body-parser');
const MongoClient = require('mongodb').MongoClient;
const ServerApiVersion = require('mongodb').ServerApiVersion;
const { ObjectId } = require('mongodb');
const multer = require('multer'); // Moved this line up
const fs = require('fs');
const path = require('path');
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
app.use(express.json({limit: '50mb'}));
app.use(express.urlencoded({limit: '50mb'}));

// app.use(express.urlencoded({ extended: true })); 
//app.use(express.static(path.join(__dirname, 'public')));


// Definir una ruta POST para '/users/login'
app.post('/users/login', async function (req, res) {
    // Obtener 'matricula' y 'contraseña' de los parámetros de consulta de la solicitud
    const matricula = parseInt(req.query.matricula);
    const contraseña = req.query.password;

    try {
        // Conectar al cliente de MongoDB
        await client.connect();
        // Acceder a la base de datos 'proyecto_informatico'
        const database = client.db("proyecto_informatico");
        // Acceder a la colección 'alumnos' en la base de datos
        const collection = database.collection("alumnos");
        // Buscar un alumno en la colección que tenga la misma 'matricula'
        const result = await collection.findOne({ matricula: matricula });
        if (!result) {
            // Si el alumno no existe, enviar un mensaje al cliente
            res.send(`El alumno con la matricula "${matricula}" no existe en la base de datos`);
        } else {
            // Si el alumno existe, verificar si la 'contraseña' proporcionada coincide con la almacenada en la base de datos
            if (await bcrypt.compare(contraseña, result.contraseña)) {
                // Si las contraseñas coinciden, enviar 'Success' al cliente
                res.send('Success');
            }
            else {
                // Si las contraseñas no coinciden, enviar 'Not Allowed' al cliente
                res.send('Not Allowed');
            }
        }
    } catch {
        // Si ocurre un error, enviar un código de estado 500 al cliente
        res.status(500).send();
    } finally {
        // Cerrar la conexión al cliente de MongoDB
        await client.close();
    }
});



// Definir una ruta GET para '/get/caa'
app.get('/get/caa', async function (req, res) {
    // Obtener 'id' de los parámetros de consulta de la solicitud
    const id = req.query.id;
    try {
        // Conectar al cliente con el servidor
        await client.connect();
        // Acceder a la base de datos 'proyecto_informatico'
        const database = client.db("proyecto_informatico");
        // Acceder a la colección 'caa' en la base de datos
        const collection = database.collection("caa");
        // Verificar si el 'id' ya existe en la colección
        const result = await collection.findOne({ _id: new ObjectId(id) });
        if (!result) {
            // Si el 'id' no existe, enviar un mensaje al cliente
            res.send(`El id ${id} no existe en la base de datos`);
        }
        else {
            // Devolver la fila completa de la colección
            res.send(result);
        }

    } catch (error) {
        // Si ocurre un error, imprimirlo en la consola y enviar un código de estado 500 al cliente
        console.log(error);
        res.status(500).send('Error en el servidor');
    } finally {
        // Asegurarse de que el cliente se cierre cuando termine o ocurra un error
        await client.close();
    }
});


// Definir una ruta POST para '/add/caa'
app.post('/add/caa', async function (req, res) {
    // Obtener los datos del cuerpo de la solicitud
    const data = req.body;
    try {
        // Conectar al cliente de MongoDB
        await client.connect();
        // Acceder a la base de datos 'proyecto_informatico'
        const database = client.db("proyecto_informatico");
        // Acceder a la colección 'caa' en la base de datos
        const collection = database.collection("caa");
        // Si el nombre no existe, insertarlo en la colección
        await collection.insertOne(data);
        // Enviar el resultado al cliente
        res.send("se ha insertado correctamente");
    } catch (error) {
        // Si ocurre un error, imprimirlo en la consola y enviar un código de estado 500 al cliente
        console.log(error);
        res.status(500).send('Error en el servidor');
    } finally {
        // Asegurarse de que el cliente se cierre cuando termine o ocurra un error
        await client.close();
    }
});
// Definir una ruta PUT para '/update/caa'
app.put('/update/caa', async function (req, res) {
    // Obtener 'id' de los parámetros de consulta de la solicitud
    const id = req.query.id;
    // Obtener los datos del cuerpo de la solicitud
    const data = req.body;
    try {
        // Conectar al cliente de MongoDB
        await client.connect();
        // Acceder a la base de datos 'proyecto_informatico'
        const database = client.db("proyecto_informatico");
        // Acceder a la colección 'caa' en la base de datos
        const collection = database.collection("caa");
        // Verificar si el 'id' ya existe en la colección
        const result = await collection.findOne({ _id: new ObjectId(id) });
        // Verificar si el 'nombre' ya existe en la colección
        const result2 = await collection.findOne({ nombre: data.nombre });
        if (!result || result2) {
            // Si el 'id' no existe o el 'nombre' ya existe, enviar un mensaje al cliente
            res.send(`El id ${id} no existe en la base de datos o el nuevo nombre ya existe`);
        }
        else {
            // Si el 'id' existe y el 'nombre' no existe, actualizar el documento en la colección
            await collection.updateOne({ _id: new ObjectId(id) }, { $set: data });
            // Enviar el resultado al cliente
            res.send("se ha actualizado correctamente");
        }
    } catch (error) {
        // Si ocurre un error, imprimirlo en la consola y enviar un código de estado 500 al cliente
        console.log(error);
        res.status(500).send('Error en el servidor');
    } finally {
        // Asegurarse de que el cliente se cierre cuando termine o ocurra un error
        await client.close();
    }
});

// Definir una ruta DELETE para '/delete/caa'
app.delete('/delete/caa', async function (req, res) {
    // Obtener 'id' de los parámetros de consulta de la solicitud
    const id = req.query.id;
    try {
        // Conectar al cliente de MongoDB
        await client.connect();
        // Acceder a la base de datos 'proyecto_informatico'
        const database = client.db("proyecto_informatico");
        // Acceder a la colección 'caa' en la base de datos
        const collection = database.collection("caa");
        // Verificar si el 'id' ya existe en la colección
        const result = await collection.findOne({ _id: new ObjectId(id) });
        if (!result) {
            // Si el 'id' no existe, enviar un mensaje al cliente
            res.send(`El id ${id} no existe en la base de datos`);
        }
        else {
            // Si el 'id' existe, eliminar el documento de la colección
            await collection.deleteOne({ _id: new ObjectId(id) });
            // Enviar el resultado al cliente
            res.send("se ha eliminado correctamente");
        }
    } catch (error) {
        // Si ocurre un error, imprimirlo en la consola y enviar un código de estado 500 al cliente
        console.log(error);
        res.status(500).send('Error en el servidor');
    } finally {
        // Asegurarse de que el cliente se cierre cuando termine o ocurra un error
        await client.close();
    }
});

// Definir una ruta GET para '/get/all/caas'
app.get('/get/all/caas', async function (req, res) {
    try {
        // Conectar al cliente de MongoDB
        await client.connect();
        // Acceder a la base de datos 'proyecto_informatico'
        const database = client.db("proyecto_informatico");
        // Acceder a la colección 'caa' en la base de datos
        const collection = database.collection("caa");
        // Recuperar todos los documentos de la colección y convertirlos en un array
        const data = await collection.find().toArray();
        // Enviar los datos al cliente
        res.send(data);
    } catch (error) {
        // Si ocurre un error, imprimirlo en la consola y enviar un código de estado 500 al cliente
        console.log(error);
        res.status(500).send('Error en el servidor');
    }
    finally {
        // Asegurarse de que el cliente se cierre cuando termine o ocurra un error
        await client.close();
    }
});

// Definir una ruta GET para '/get/ingresos/caa'
app.get('/get/ingresos/caa', async function (req, res) {
    // Obtener 'id' de los parámetros de consulta de la solicitud
    const id = req.query.id;
    try {
        // Conectar al cliente de MongoDB
        await client.connect();
        // Acceder a la base de datos 'proyecto_informatico'
        const database = client.db("proyecto_informatico");
        // Acceder a la colección 'caa' en la base de datos
        const collection = database.collection("caa");
        // Verificar si el 'id' ya existe en la colección
        const result = await collection.findOne({ _id: new ObjectId(id) });
        if (!result) {
            // Si el 'id' no existe, enviar un código de estado 404 al cliente
            res.status(404).send(`El id ${id} no existe en la base de datos`);
        } else {
            if (!result.ingresos) {
                // Si el campo 'ingresos' no existe, enviar "0" al cliente
                res.send("0");
            } else {
                // Si el campo 'ingresos' existe, calcular la suma de los valores en el campo 'ingresos'
                var suma = 0;
                for (var i = 0; i < result.ingresos.length; i++) {
                    if (result.ingresos[i] != null) {
                        // Sumar el valor en la posición i del campo 'ingresos' a 'suma'
                        suma += result.ingresos[i][0];
                    }
                }
                // Enviar la suma al cliente
                res.send(suma.toString());
            }
        }
    } catch (error) {
        // Si ocurre un error, imprimirlo en la consola y enviar un código de estado 500 al cliente
        console.log(error);
        res.status(500).send('Error en el servidor');
    } finally {
        // Asegurarse de que el cliente se cierre cuando termine o ocurra un error
        await client.close();
    }
});

// Definir una ruta POST para '/add/ingreso/caa'
app.post('/add/ingreso/caa', async function (req, res) {
    // Obtener 'id' de los parámetros de consulta de la solicitud
    const id = req.query.id;
    // Obtener 'data' del cuerpo de la solicitud
    const data = req.body;
    // Extraer el campo 'ingresos' de 'data' y almacenarlo en 'data2'
    const data2 = data.ingresos;

    // Agregar la fecha actual en formato ISO 8601
    const currentDate = new Date().toISOString();
    // Agregar la cantidad, la descripción y la fecha actual al array 'data2'
    data2.push(currentDate);

    try {
        // Conectar al cliente de MongoDB
        await client.connect();
        // Acceder a la base de datos 'proyecto_informatico'
        const database = client.db("proyecto_informatico");
        // Acceder a la colección 'caa' en la base de datos
        const collection = database.collection("caa");
        // Verificar si el 'id' ya existe en la colección
        const result = await collection.findOne({ _id: new ObjectId(id) });
        if (result) {
            // Si el 'id' existe, agregar 'data2' al array 'ingresos' del documento que tiene el mismo 'id'
            await collection.updateOne({ _id: new ObjectId(id) }, { $push: { ingresos: data2 } });
            // Actualizar el campo 'total' del documento sumando el primer elemento de 'data2' al 'total' actual
            await collection.updateOne({ _id: new ObjectId(id) }, { $set: { total: result.total + data2[0] } });
            // Enviar el resultado al cliente
            res.send("se ha insertado correctamente");
        }
        else {
            // Si el 'id' no existe, enviar un mensaje al cliente
            res.send(`El id ${id} no existe en la base de datos`);
        }
    } catch (error) {
        // Si ocurre un error, imprimirlo en la consola y enviar un código de estado 500 al cliente
        console.log(error);
        res.status(500).send('Error en el servidor');
    } finally {
        // Asegurarse de que el cliente se cierre cuando termine o ocurra un error
        await client.close();
    }
});

// Definir una ruta GET para '/get/egresos/caa'
app.get('/get/egresos/caa', async function (req, res) {
    // Obtener 'id' de los parámetros de consulta de la solicitud
    const id = req.query.id;
    try {
        // Conectar al cliente de MongoDB
        await client.connect();
        // Acceder a la base de datos 'proyecto_informatico'
        const database = client.db("proyecto_informatico");
        // Acceder a la colección 'caa' en la base de datos
        const collection = database.collection("caa");
        // Verificar si el 'id' ya existe en la colección
        const result = await collection.findOne({ _id: new ObjectId(id) });
        if (!result) {
            // Si el 'id' no existe, enviar un mensaje al cliente
            res.send(`El id ${id} no existe en la base de datos`);
        } else {
            if (result.egresos) {
                // Si el campo 'egresos' existe, calcular la suma de los valores en el campo 'egresos'
                var suma = 0;
                for (var i = 0; i < result.egresos.length; i++) {
                    if (result.egresos[i] != null) {
                        // Sumar el valor en la posición i del campo 'egresos' a 'suma'
                        suma += result.egresos[i][0];
                    }
                }
                // Enviar la suma al cliente
                res.send(suma.toString());
            } else {
                // Si el campo 'egresos' no existe, enviar "0" al cliente
                res.send("0");
            }
        }
    } catch (error) {
        // Si ocurre un error, imprimirlo en la consola y enviar un código de estado 500 al cliente
        console.log(error);
        res.status(500).send('Error en el servidor');
    } finally {
        // Asegurarse de que el cliente se cierre cuando termine o ocurra un error
        await client.close();
    }
});

// Definir una ruta POST para '/add/egreso/caa'
app.post('/add/egreso/caa', async function (req, res) {
    // Obtener 'id' de los parámetros de consulta de la solicitud
    const id = req.query.id;
    // Obtener 'data' del cuerpo de la solicitud
    const data = req.body;
    // Extraer el campo 'egresos' de 'data' y almacenarlo en 'data2'
    const data2 = data.egresos;

    // Agregar la fecha actual en formato ISO 8601
    const currentDate = new Date().toISOString();
    // Agregar la cantidad, la descripción y la fecha actual al array 'data2'
    data2.push(currentDate);

    try {
        // Conectar al cliente de MongoDB
        await client.connect();
        // Acceder a la base de datos 'proyecto_informatico'
        const database = client.db("proyecto_informatico");
        // Acceder a la colección 'caa' en la base de datos
        const collection = database.collection("caa");
        // Verificar si el 'id' ya existe en la colección
        const result = await collection.findOne({ _id: new ObjectId(id) });
        if (result) {
            // Si el 'id' existe, agregar 'data2' al array 'egresos' del documento que tiene el mismo 'id'
            await collection.updateOne({ _id: new ObjectId(id) }, { $push: { egresos: data2 } });

            if (result.total) {
                // Si el campo 'total' existe, actualizarlo restando el primer elemento de 'data2' al 'total' actual
                await collection.updateOne({ _id: new ObjectId(id) }, { $set: { total: result.total - data2[0] } });
            } else {
                // Si el campo 'total' no existe, establecerlo al negativo del primer elemento de 'data2'
                await collection.updateOne({ _id: new ObjectId(id) }, { $set: { total: -data2[0] } });
            }
            // Enviar el resultado al cliente
            res.send("se ha insertado correctamente");
        }
        else {
            // Si el 'id' no existe, enviar un mensaje al cliente
            res.send(`El id ${id} no existe en la base de datos`);
        }
    } catch (error) {
        // Si ocurre un error, imprimirlo en la consola y enviar un código de estado 500 al cliente
        console.log(error);
        res.status(500).send('Error en el servidor');
    } finally {
        // Asegurarse de que el cliente se cierre cuando termine o ocurra un error
        await client.close();
    }
});
// Definir una ruta GET para '/get/total/caa'
app.get('/get/total/caa', async function (req, res) {
    // Obtener 'id' de los parámetros de consulta de la solicitud
    const id = req.query.id;
    try {
        // Conectar al cliente de MongoDB
        await client.connect();
        // Acceder a la base de datos 'proyecto_informatico'
        const database = client.db("proyecto_informatico");
        // Acceder a la colección 'caa' en la base de datos
        const collection = database.collection("caa");
        // Verificar si el 'id' ya existe en la colección
        const result = await collection.findOne({ _id: new ObjectId(id) });
        if (!result) {
            // Si el 'id' no existe, enviar un mensaje al cliente
            res.send(`El id ${id} no existe en la base de datos`);
        }
        else {
            // Si el 'id' existe, enviar el campo 'total' del documento al cliente
            res.send(result.total.toString());
        }
    } catch (error) {
        // Si ocurre un error, imprimirlo en la consola y enviar un código de estado 500 al cliente
        console.log(error);
        res.status(500).send('Error en el servidor');
    } finally {
        // Asegurarse de que el cliente se cierre cuando termine o ocurra un error
        await client.close();
    }
});
// Definir una ruta GET para '/get/evento'
app.get('/get/evento', async function (req, res) {
    // Obtener 'id' de los parámetros de consulta de la solicitud
    const id = req.query.id;
    try {
        // Conectar al cliente de MongoDB
        await client.connect();
        // Acceder a la base de datos 'proyecto_informatico'
        const database = client.db("proyecto_informatico");
        // Acceder a la colección 'test' en la base de datos
        const collection = database.collection("test");
        // Verificar si el 'id' ya existe en la colección
        const result = await collection.findOne({ _id: new ObjectId(id) });
        if (!result) {
            // Si el 'id' no existe, enviar un mensaje al cliente
            res.send(`El id ${id} no existe en la base de datos`);
        }
        else {
            // Si el 'id' existe, enviar todo el documento al cliente
            res.send(result);
        }
    } catch (error) {
        // Si ocurre un error, imprimirlo en la consola y enviar un código de estado 500 al cliente
        console.log(error);
        res.status(500).send('Error en el servidor');
    } finally {
        // Asegurarse de que el cliente se cierre cuando termine o ocurra un error
        await client.close();
    }
});

// Definir una ruta POST para '/add/evento'
app.post('/add/evento', async function (req, res) {
    // Obtener 'id_creador' de los parámetros de consulta de la solicitud
    const id_creador = req.query.id_creador;
    // Obtener 'data' del cuerpo de la solicitud
    const data = req.body;

    // Si falta 'fecha_inicio' o 'fecha_final' en 'data', establecer ambos al tiempo actual
    if (!data.fecha_inicio || !data.fecha_final) {
        const fechaActual = new Date();
        data.fecha_inicio = fechaActual.toISOString();
        data.fecha_final = fechaActual.toISOString();
    }

    try {
        // Conectar al cliente de MongoDB
        await client.connect();
        // Acceder a la base de datos 'proyecto_informatico'
        const database = client.db("proyecto_informatico");
        // Acceder a la colección 'test' en la base de datos
        const collection = database.collection("test");

        // Verificar si 'id_creador' es un alumno
        let es_alumno = false;
        if (id_creador.length < 24) {
            es_alumno = true;
        }

        // Verificar si 'id_creador' existe en 'alumnos' o 'caa'
        if (es_alumno) {
            // Acceder a la colección 'alumnos'
            const alumnos = database.collection("alumnos");
            // Buscar un alumno con 'matricula' igual a 'id_creador'
            const result = await alumnos.findOne({ matricula: parseInt(id_creador) });
            if (!result) {
                // Si el alumno no existe, enviar un mensaje al cliente
                res.send(`El id ${id_creador} no existe en la base de datos`);
            } else {
                // Si el alumno existe, insertar 'data' en la colección 'test'
                data.id_creador = id_creador;
                await collection.insertOne(data);
                res.send("se ha insertado correctamente");

                // Agregar el '_id' de 'data' a 'mis_eventos' del alumno
                const mis_eventos = result.mis_eventos;
                mis_eventos.push(data._id);
                await alumnos.updateOne({ matricula: parseInt(id_creador) }, { $set: { mis_eventos: mis_eventos } });
            }
        } else {
            // Acceder a la colección 'caa'
            const caa = database.collection("caa");
            // Buscar un 'caa' con '_id' igual a 'id_creador'
            const result = await caa.findOne({ _id: new ObjectId(id_creador) });
            if (!result) {
                // Si el 'caa' no existe, enviar un mensaje al cliente
                res.send(`El id ${id_creador} no existe en la base de datos`);
            } else {
                // Si el 'caa' existe, insertar 'data' en la colección 'test'
                data.id_creador = id_creador;
                await collection.insertOne(data);
                res.send("se ha insertado correctamente");
            }
        }
    } catch (error) {
        // Si ocurre un error, imprimirlo en la consola y enviar un código de estado 500 al cliente
        console.log(error);
        res.status(500).send('Error en el servidor');
    } finally {
        // Asegurarse de que el cliente se cierre cuando termine o ocurra un error
        await client.close();
    }
});


// Definir una ruta PUT para '/update/evento'
app.put('/update/evento', async function (req, res) {
    // Obtener 'id' de los parámetros de consulta de la solicitud
    const id = req.query.id;
    // Obtener 'data' del cuerpo de la solicitud
    const data = req.body;
    try {
        // Conectar al cliente de MongoDB
        await client.connect();
        // Acceder a la base de datos 'proyecto_informatico'
        const database = client.db("proyecto_informatico");
        // Acceder a la colección 'test' en la base de datos
        const collection = database.collection("test");
        // Verificar si el 'id' ya existe en la colección
        const result = await collection.findOne({ _id: new ObjectId(id) });
        // Verificar si el 'nombre' ya existe en la colección
        const result2 = await collection.findOne({ nombre: data.nombre });
        if (!result || result2) {
            // Si el 'id' no existe o el 'nombre' ya existe, enviar un mensaje al cliente
            res.send(`El id ${id} no existe en la base de datos o el nuevo nombre ya existe`);
        }
        else {
            // Si el 'id' existe y el 'nombre' no existe, actualizar el documento en la colección
            await collection.updateOne({ _id: new ObjectId(id) }, { $set: data });
            // Enviar el resultado al cliente
            res.send("se ha actualizado correctamente");
        }
    } catch (error) {
        // Si ocurre un error, imprimirlo en la consola y enviar un código de estado 500 al cliente
        console.log(error);
        res.status(500).send('Error en el servidor');
    } finally {
        // Asegurarse de que el cliente se cierre cuando termine o ocurra un error
        await client.close();
    }
});

// Definir una ruta DELETE para '/delete/evento'
app.delete('/delete/evento', async function (req, res) {
    // Obtener 'id' de los parámetros de consulta de la solicitud
    const id = req.query.id;
    try {
        // Conectar al cliente de MongoDB
        await client.connect();
        // Acceder a la base de datos 'proyecto_informatico'
        const database = client.db("proyecto_informatico");
        // Acceder a la colección 'test' en la base de datos
        const collection = database.collection("test");
        // Verificar si el 'id' ya existe en la colección
        const result = await collection.findOne({ _id: new ObjectId(id) });
        if (!result) {
            // Si el 'id' no existe, enviar un mensaje al cliente
            res.send(`El id ${id} no existe en la base de datos`);
        }
        else {
            // Si el 'id' existe, eliminar el documento de la colección
            await collection.deleteOne({ _id: new ObjectId(id) });
            // Enviar el resultado al cliente
            res.send("se ha eliminado correctamente");
        }
    } catch (error) {
        // Si ocurre un error, imprimirlo en la consola y enviar un código de estado 500 al cliente
        console.log(error);
        res.status(500).send('Error en el servidor');
    } finally {
        // Asegurarse de que el cliente se cierre cuando termine o ocurra un error
        await client.close();
    }
});

// Definir una ruta GET para '/get/all/eventos'
app.get('/get/all/eventos', async function (req, res) {
    try {
        // Conectar al cliente de MongoDB
        await client.connect();
        // Acceder a la base de datos 'proyecto_informatico'
        const database = client.db("proyecto_informatico");
        // Acceder a la colección 'test' en la base de datos
        const collection = database.collection("test");
        // Intentar encontrar todos los documentos en la colección y convertirlos a un array
        const result = await collection.find().toArray();
        if (!result) {
            // Si no se encuentran documentos, enviar un mensaje al cliente
            res.send(`No hay eventos en la base de datos`);
        }
        else {
            // Si se encuentran documentos, enviarlos al cliente
            res.send(result);
        }
    } finally {
        // Asegurarse de que el cliente se cierre cuando termine o ocurra un error
        await client.close();
    }
});
// Definir una ruta GET para '/get/filter/eventos'
app.get('/get/filter/eventos', async (req, res) => {
    try {
        // Conectar al cliente de MongoDB
        await client.connect();
        // Acceder a la base de datos 'proyecto_informatico'
        const database = client.db("proyecto_informatico");
        // Acceder a la colección 'test' en la base de datos
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
            if (param === 'visible') {
                // Si el parámetro es 'visible', mapear el valor al formato correcto
                filtroFinal[param] = booleanMapping[parametrosFiltro[param]];
            } else {
                filtroFinal[param] = parametrosFiltro[param];
            }
        }
        
        // Realiza la consulta en la colección utilizando el filtro final
        const result = await collection.find(filtroFinal).toArray();
        if (result.length === 0) {
            // Si no se encontraron documentos, enviar un mensaje al cliente
            res.send('No se encontraron eventos que cumplan con los criterios de filtro.');
        } else {
            // Si se encontraron documentos, enviarlos al cliente
            res.send(result);
        }
    } catch (error) {
        // Si ocurre un error, imprimirlo en la consola y enviar un código de estado 500 al cliente
        console.log(error);
        res.status(500).send('Error en el servidor');
    } finally {
        // Asegurarse de que el cliente se cierre cuando termine o ocurra un error
        await client.close();
    }
});

// Definir una ruta GET para '/get/alumno'
app.get('/get/alumno', async function (req, res) {
    // Parsear la 'matricula' de los parámetros de consulta de la solicitud a un entero
    const matricula = parseInt(req.query.matricula);
    try {
        // Conectar al cliente de MongoDB
        await client.connect();
        // Acceder a la base de datos 'proyecto_informatico'
        const database = client.db("proyecto_informatico");
        // Acceder a la colección 'alumnos' en la base de datos
        const collection = database.collection("alumnos");
        // Verificar si el alumno ya existe en la colección
        const result = await collection.findOne({ matricula: matricula });
        if (!result) {
            // Si el alumno ya existe, enviar un mensaje al cliente
            res.send(`El alumno con la matricula "${matricula}" no existe en la base de datos`);
        } else {
            // Si el alumno no existe, insertarlo en la colección
            res.send(result);
        }
    } catch (error) {
        // Si ocurre un error, imprimirlo en la consola y enviar un código de estado 500 al cliente
        console.log(error);
        res.status(500).send('Error en el servidor');
    } finally {
        // Asegurarse de que el cliente se cierre cuando termine o ocurra un error
        await client.close();
    }
});

// Definir una ruta POST para '/add/alumno'
app.post('/add/alumno', async function (req, res) {
    // Extraer los parámetros de consulta de la solicitud
    const nombre = req.query.nombre;
    const matricula = req.query.matricula;
    const apellido = req.query.apellido;
    const id_caa = req.query.id_caa;
    const es_caa = req.query.es_caa;
    // Extraer el cuerpo de la solicitud
    const data = req.body;
    // Inicializar un array vacío 'mis_eventos'
    const mis_eventos = [];

    // Verificar si se subió un archivo de imagen con la solicitud
    if (!req.file) {
        // Si no se subió un archivo de imagen, enviar un mensaje al cliente
        return res.status(400).send('No se subió ningún archivo de imagen');
    }

    // Unificar los datos en un solo objeto
    data.nombre = nombre;
    data.apellido = apellido;
    data.matricula = parseInt(matricula);
    data.id_caa = id_caa;
    data.es_caa = es_caa;
    data.mis_eventos = mis_eventos;

    // Verificar si la 'matricula' tiene al menos 4 dígitos
    if (matricula.length < 4) {
        // Si la 'matricula' no tiene al menos 4 dígitos, enviar un mensaje al cliente
        res.send(`La matricula ${matricula} no tiene el mínimo de 4 dígitos`);
        return;
    }

    // Los primeros dos dígitos de la 'matricula' y los primeros dos caracteres del 'nombre' y 'apellido' en minúsculas son la contraseña
    const password = matricula.substring(0, 4) + nombre.toLowerCase().substring(0, 2) + apellido.toLowerCase().substring(0,2);

    try {
        // Conectar al cliente de MongoDB
        await client.connect();
        // Acceder a la base de datos 'proyecto_informatico'
        const database = client.db("proyecto_informatico");
        // Acceder a la colección 'alumnos' en la base de datos
        const collection = database.collection("alumnos");

        // Verificar si el alumno ya existe en la colección
        const result = await collection.findOne({ matricula: data.matricula });
        if (result) {
            // Si el alumno ya existe, enviar un mensaje al cliente
            res.send(`El alumno ${data.matricula} ya existe en la base de datos`);
        } else {
            // Si el alumno no existe, insertarlo en la colección
            data.contraseña = await bcrypt.hash(password, 10);
            await collection.insertOne(data);
            // Enviar el resultado al cliente
            res.send("Se ha insertado correctamente");
        }
    } catch (error) {
        // Si ocurre un error, imprimirlo en la consola y enviar un código de estado 500 al cliente
        console.log(error);
        res.status(500).send('Error en el servidor');
    } finally {
        // Asegurarse de que el cliente se cierre cuando termine o ocurra un error
        await client.close();
    }
});
// Definir una ruta PUT para '/update/alumno'
app.put('/update/alumno', async function (req, res) {
    // Parsear la 'matricula' de los parámetros de consulta de la solicitud a un entero
    const matricula = parseInt(req.query.matricula);
    // Extraer el cuerpo de la solicitud
    const data = req.body;

    try {
        // Conectar al cliente de MongoDB
        await client.connect();
        // Acceder a la base de datos 'proyecto_informatico'
        const database = client.db("proyecto_informatico");
        // Acceder a la colección 'alumnos' en la base de datos
        const collection = database.collection("alumnos");
        // Verificar si el alumno ya existe en la colección
        const result = await collection.findOne({ matricula: matricula });
        if (!result) {
            // Si el alumno no existe, enviar un mensaje al cliente
            res.send(`El alumno con matricula ${matricula} no existe en la base de datos`);
        } else {
            // Si el alumno existe, actualizarlo en la colección
            await collection.updateOne({ matricula: matricula }, { $set: data });
            // Enviar el resultado al cliente
            res.send("se ha actualizado correctamente");
        }
    } catch (error) {
        // Si ocurre un error, imprimirlo en la consola y enviar un código de estado 500 al cliente
        console.log(error);
        res.status(500).send('Error en el servidor');
    } finally {
        // Asegurarse de que el cliente se cierre cuando termine o ocurra un error
        await client.close();
    }
});
// Definir una ruta DELETE para '/delete/alumno'
app.delete('/delete/alumno', async function (req, res) {
    // Parsear la 'matricula' de los parámetros de consulta de la solicitud a un entero
    const matricula = parseInt(req.query.matricula);

    try {
        // Conectar al cliente de MongoDB
        await client.connect();
        // Acceder a la base de datos 'proyecto_informatico'
        const database = client.db("proyecto_informatico");
        // Acceder a la colección 'alumnos' en la base de datos
        const collection = database.collection("alumnos");
        // Verificar si el alumno ya existe en la colección
        const result = await collection.findOne({ matricula: matricula });
        if (!result) {
            // Si el alumno no existe, enviar un mensaje al cliente
            res.send(`El alumno con matricula ${matricula} no existe en la base de datos`);
        } else {
            // Si el alumno existe, eliminarlo de la colección
            await collection.deleteOne({ matricula: matricula });
            // Enviar el resultado al cliente
            res.send("se ha eliminado correctamente");
        }
    } catch (error) {
        // Si ocurre un error, imprimirlo en la consola y enviar un código de estado 500 al cliente
        console.log(error);
        res.status(500).send('Error en el servidor');
    } finally {
        // Asegurarse de que el cliente se cierre cuando termine o ocurra un error
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
        const eventos = database.collection("test");
        const caa = database.collection("caa");
        //check if the id already exists in the collection, if exists send a message to the client and exit
        const result = await eventos.findOne({ _id: new ObjectId(id) });
        id_caa = result.id_creador;
        const caa_result = await caa.findOne({ _id: new ObjectId(id_caa) });

        if (result) {
            // if the id exists, add the data to the array named ingresos inside the one that has the same id
            await eventos.updateOne({ _id: new ObjectId(id) }, { $push: { ingresos: data2 } });
            data3 = data2;
            data3.push(id);
            await caa.updateOne({ _id: new ObjectId(id_caa) }, { $push: { ingresos: data2 } });
            //send the result to the client

            await eventos.updateOne({ _id: new ObjectId(id) }, { $set: { total: result.total + data2[0] } });
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
        const caa = database.collection("caa");
        const result = await collection.findOne({ _id: new ObjectId(id) });

        if (result) {
            // if the id exists, add the data to the array named egresos inside the one that has the same id
            await collection.updateOne({ _id: new ObjectId(id) }, { $push: { egresos: data2 } });

            // Create a new array with the data and the id of the event it is coming from
            const data3 = [...data2, id];

            // Update the caa collection with the new array
            await caa.updateOne({ _id: new ObjectId(result.id_creador) }, { $push: { egresos: data3 } });
            res.send("se ha insertado correctamente");
        } else {
            res.send(`El id ${id} no existe en la base de datos.`);
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
                    //calculate the length of result.asistencia
                    const result = await collection.findOne({ _id: new ObjectId(id) });
                    if (result.asistencia.length >= 5){
                        await collection.updateOne({_id: new ObjectId(id)}, {$set: {global: true}});
                    }
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