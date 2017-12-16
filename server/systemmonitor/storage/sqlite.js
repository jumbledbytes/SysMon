var sqlite3 = require('sqlite3').verbose();
var db = {};
var config = {}

var loadSchema = function(table, schema) {
    db.serialize(function() {
        var tableName = table;
        var tableColumns = [];
        var columnString = "";
        var typeMap = {
          String: "TEXT",
          Number: "REAL",
          Boolean: "BOOLEAN",  
          DateTime: "INTEGER"
        };
        var columnType;
        tableColumns.push("record_time INTEGER");
        for(column in schema) {
            columnType = typeMap[schema[column]];
            tableColumns.push(column + " " + columnType ); 
        }
        columnString = tableColumns.join(",");
        
        var createTableQuery = "CREATE TABLE IF NOT EXISTS "+tableName+" ("+columnString+")";
        db.run(createTableQuery);
        if(! config[table]) {
            config[table] = {};
        }
        config[table].schema = schema;
    })
}

var configure = function(appConfig) {
    var dbFile = ":memory:";
    config = appConfig;
    if(config.sqlite && config.sqlite.database) {
        dbFile = config.sqlite.database;
    }
    db = new sqlite3.Database(dbFile);
}

var save = function(table, dataMap, whereMap) {
    var columns = [], data = [];
    var key;
    var replaceString = "";
    var valueParts = [];
    var valueString = "";
    
    var fieldsMap = {};
    
    if(whereMap) {
        replaceString = "OR REPLACE";
        for(key in whereMap) {
            if(whereMap[key].constructor === Array) {
                orParts = [];
                whereMap[key].forEach(function(value, index) {
                    var fieldName = "$where_" + key;
                    fieldsMap[fieldName] = value;
                    valueString = key + "='" + fieldName;
                    //orParts.push(valueString);
                })
                whereClause = "("+ orParts.join(" OR ") +")"
            } else {
                whereClause = key + "='" + String(whereMap[key]).replace("'", "") + "'";
            }
            valueParts.push(whereClause)
        }
        columns.push("rowid");
        data.push("(SELECT rowid FROM "+table+" WHERE "+whereClause+")")
    }
    columns.push("record_time");
    data.push(Date.now() / 1000);
    
    for(key in dataMap) {
        columns.push(key);
        data.push("$insert_" + key);
        fieldsMap["$insert_" + key] = dataMap[key];
        //data.push("'" + String(dataMap[key]).replace("'", "") + "'");
    }
    
    var columnString = columns.join(",");
    var dataString = data.join(",");
    var query = "INSERT "+replaceString+" INTO " + table + " ("+columnString+") VALUES ("+dataString+")";
    console.log("db.save: " + query + " --> " + JSON.stringify(fieldsMap));
    var result = db.run(query, fieldsMap, function(error) {
        if(error != null) {
            console.log("ERROR: " + JSON.stringify(error) + " -> " + query);
            
        }
        // TODO: error handling
    });
}
var createWhereClause = function(table, dataMap, duration) {
    var queryParts = [];
    var key, whereOperand = "AND";
    var orParts = [];
    var whereClause;
    var latestClause;
    
    var fieldsMap = {}
    var fieldKey;
    var startTime;
    
    for(key in dataMap) {
        if(dataMap[key].constructor === Array) {
            orParts = [];
            dataMap[key].forEach(function(value, index) {
                fieldKey = "$where_" + key;
                fieldsMap[fieldKey] = value;
                latestClause = key + "=" + fieldKey +"";
                if(duration <= 1) {
                    latestClause = latestClause + " AND ROWID = (SELECT MAX(ROWID)  FROM "+ table +" WHERE "+key+"="+fieldKey+") "
                } else if(typeof duration !== "undefined") {
                    startTime = (Date.now() / 1000) - duration;
                    latestClause = latestClause + " AND record_time >= " + startTime;
                }
                orParts.push(latestClause);
            })
            whereClause = "("+ orParts.join(" OR ") +")"
        } else {
            fieldKey = "$where_" + key;
            fieldsMap[fieldKey] = dataMap[key];
            whereClause = key + "=" + fieldKey;
        }
        queryParts.push(whereClause);
    }
    var whereString = "";
    if(queryParts.length > 0) {
        whereString =  queryParts.join(" " + whereOperand + " ");
    }
    return {whereString: whereString, values: fieldsMap};
}

var get = function(table, dataMap, duration, callback) {
    var columns = [];
    var results = [], orParts = [];
    var whereClause;
    var latestClause;
    if(typeof callback !== "function") {
        console.error("No callback for get from " + table);
        return;
    }
    if(! config[table]) {
        console.error("Attempt to get data from non-existant table: " + table);
        return;
    }
    columns.push("rowid");
    columns.push("record_time");
    for(key in config[table].schema) {
        columns.push(key)
    }
    var whereQuery = createWhereClause(table, dataMap, duration);
    if(whereQuery.whereString != "") {
        whereQuery.whereString = " WHERE " + whereQuery.whereString;
    }
    var query = "SELECT " + columns.join(",") + " FROM " + table + " " + whereQuery.whereString;
    db.serialize(function() {
        db.each(query, whereQuery.values, function(error, row) {
            var record = {}
            for(column in row) {
                record[column] = row[column];
            }
            results.push(record);
        },
        function(error, rowCount) {    
            callback(results);
        });
    });
}

var test = function() {
    db.serialize(function() {
        db.run("CREATE TABLE lorem (info TEXT)");

        var stmt = db.prepare("INSERT INTO lorem VALUES (?)");
        for (var i = 0; i < 10; i++) {
            stmt.run("Ipsum " + i);
        }
        stmt.finalize();

        db.each("SELECT rowid AS id, info FROM lorem", function(err, row) {
            console.log(row.id + ": " + row.info);
        });
    });

    db.close();
}

var clear = function(table, dataMap) {
    var whereClause = createWhereClause(table, dataMap, 9999999);
    if(whereClause.whereString != "") {
        whereClause.whereString = " WHERE " + whereClause.whereString;
    }
    var query = "DELETE FROM " +table + " " + whereClause.whereString;
    console.log("db.clear: " + query + " --> " + JSON.stringify(whereClause.values));
    db.serialize(function() {
        db.run(query, whereClause.values, function(error) {
            if(error != null) {
                console.log("ERROR: " + query + " :: " + JSON.stringify(error) + " -> " + query);   
            }
        });
    });
}

module.exports = {
    loadSchema: loadSchema,
    configure: configure,
    save: save,
    get: get,
    clear: clear
}