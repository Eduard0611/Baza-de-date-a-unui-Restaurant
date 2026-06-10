const express = require('express');
const oracledb = require('oracledb');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

app.use(express.static(__dirname));

// Configurare Oracle
const dbConfig = {
    user: "system",    
    password: "Analfabet7386",   
    connectString: "localhost:1521/XE" 
};

// Initializare client Oracle
try { oracledb.initOracleClient({ libDir: process.env.ORACLE_CLIENT_LIB_DIR }); } 
catch (e) { console.log("Driver Thin activat."); }

// Functie executie SQL
async function runQuery(query, params = [], options = {}) {
    let connection;
    try {
        connection = await oracledb.getConnection(dbConfig);
        options.autoCommit = true;
        return await connection.execute(query, params, options);
    } catch (err) {
        console.error("Eroare SQL:", err);
        throw err;
    } finally {
        if (connection) await connection.close();
    }
}

// 1. Listare Tabel (Cerinta A)
app.get('/api/table/:tableName', async (req, res) => {
    try {
        const result = await runQuery(`SELECT * FROM ${req.params.tableName}`);
        const rows = result.rows.map(row => {
            let obj = {};
            result.metaData.forEach((meta, idx) => obj[meta.name] = row[idx]);
            return obj;
        });
        res.json(rows);
    } catch (err) { res.status(500).json({ error: err.message }); }
});

// 2. Stergere (Cerinta B)
app.delete('/api/delete/:tableName/:idCol/:idVal', async (req, res) => {
    try {
        let { tableName, idCol, idVal } = req.params;
        if (tableName === 'v_ingrediente_furnizori') {
            tableName = 'ingrediente';
        }
        await runQuery(`DELETE FROM ${tableName} WHERE ${idCol} = :id`, [idVal]);
        res.json({ success: true });
    } catch (err) { res.status(500).json({ error: err.message }); }
});

// 3. Actualizare (Cerinta B)
app.put('/api/update', async (req, res) => {
    try {
        let { tableName, idCol, idVal, updates } = req.body;
        if (tableName === 'v_ingrediente_furnizori') {
            tableName = 'ingrediente';
        }
        let setClause = [];
        let params = {};
        
        Object.keys(updates).forEach((col, index) => {
            if(col !== idCol) {
                let val = updates[col];
                // Detectare format data YYYY-MM-DD
                const eData = typeof val === 'string' && /^\d{4}-\d{2}-\d{2}$/.test(val);

                if (eData) setClause.push(`${col} = TO_DATE(:val${index}, 'YYYY-MM-DD')`);
                else setClause.push(`${col} = :val${index}`);
                
                params[`val${index}`] = val;
            }
        });

        params['idKey'] = idVal;
        const query = `UPDATE ${tableName} SET ${setClause.join(', ')} WHERE ${idCol} = :idKey`;
        
        await runQuery(query, params);
        res.json({ success: true });
        
    } catch (err) { 
        res.status(500).json({ success: false, message: err.message }); 
    }
});

// 4. Raport Complex (Cerinta C)
app.get('/api/raport-complex', async (req, res) => {
    const query = `
        select nume || ' ' || prenume as "Numele ospatartului",
            denumire_produs, data_comanda as "Data plasarii comenzii"
        from ospatari join comenzi using (id_angajat) 
            join detalii_comanda using (id_comanda)
            join produse using (id_produs)
            join angajati using (id_angajat)
        where data_comanda between to_date('1-1-2026', 'DD-MM-YYYY') and to_date('31-1-2026', 'DD-MM-YYYY')
            and pret > 50
    `;
    try {
        const result = await runQuery(query);
        const rows = result.rows.map(row => {
            let obj = {};
            result.metaData.forEach((meta, idx) => obj[meta.name] = row[idx]);
            return obj;
        });
        res.json(rows);
    } catch (err) { res.status(500).json({ error: err.message }); }
});

// 5. Raport Grup (Cerinta D)
app.get('/api/raport-grup', async (req, res) => {
    const query = `
        select p.denumire_produs, count(i.id_ingredient) as "Nr. de ingrediente"
        from ingrediente i join reteta_produs rp 
            on (i.id_ingredient = rp.id_ingredient)
            join produse p on (p.id_produs = rp.id_produs)
        group by p.denumire_produs
        having count(i.id_ingredient) > 3
    `;
    try {
        const result = await runQuery(query);
        const rows = result.rows.map(row => {
            let obj = {};
            result.metaData.forEach((meta, idx) => obj[meta.name] = row[idx]);
            return obj;
        });
        res.json(rows);
    } catch (err) { res.status(500).json({ error: err.message }); }
});

const port = 3000;
app.listen(port, () => {
    console.log(`Server pornit pe portul ${port}`);
});