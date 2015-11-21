"use strict";

const express = require("express");
const http = require("http");
const util = require("util");
const bodyParser = require("body-parser");
const compression = require("compression");
const morgan = require("morgan");

let app = express();
app.use(morgan("combined"));

app.get("/test", function(req, res){
    res.status(200).send("GET /test OK");
});

app.post("/test", function(req, res){
    res.status(201).send("POST /test OK");
});

app.put("/test", function(req, res){
    res.status(202).send("PUT /test OK");
})

app.get("/content-negotiation", function(req, res){
    console.log(req.accepts("application/magic"));
    res.send(501);
})

let server = http.createServer(app);
server.listen(9090);