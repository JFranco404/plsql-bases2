----- Views del proyecto --------------------------

-- Vista 1 -- Una vista que permita consultar los camiones que han hecho viajes de más de 8 horas en los últimos 7 días.

CREATE VIEW Camiones_viajes_8h7d AS
SELECT PLACA, ID_VIAJE, DESCRIPCION
FROM CAMIONES c
INNER JOIN CAMIONES_ASIGNADOS ca ON ca.id_camion = c.placa
INNER JOIN HISTORICO_VIAJES hv ON ca.id_asignacion = hv.id_asignacion
WHERE HV.TIEMPO_REAL > INTERVAL '8' HOUR AND HV.fecha_salida >= (SYSDATE - INTERVAL '7' DAY);


ALTER TABLE HISTORICO_VIAJES ADD fecha_llegada TIMESTAMP;

-- Vista 3 -------------------------------------------------------------------------

-- Una vista que permita ver el número total de vehículos que están en viaje (estado en curso)

CREATE VIEW Vehiculos_en_curso AS
SELECT count(*) Vehiculos_En_Curso
FROM HISTORICO_VIAJES
WHERE id_estado = 2;


-- Vista 5 -- una vista que permita visualizar el historial de viajes de un camión (con el fin de saber qué tan usado ha sido el camión 

CREATE OR REPLACE TYPE HistorialViajesCamionType AS OBJECT (
    id_camion VARCHAR2(50),
    descripcion VARCHAR2(100),
    id_estado NUMBER,
    fecha_salida DATE,
    fecha_llegada DATE
);


CREATE OR REPLACE TYPE HistorialViajesCamionTableType AS TABLE OF HistorialViajesCamionType;

CREATE OR REPLACE FUNCTION HistorialViajesCamion (
    p_id_camion VARCHAR2
) RETURN HistorialViajesCamionTableType PIPELINED AS
BEGIN
    FOR rec IN (
        SELECT ca.id_camion, hv.descripcion, hv.id_estado, hv.fecha_salida, hv.fecha_llegada
        FROM HISTORICO_VIAJES hv
        INNER JOIN CAMIONES_ASIGNADOS ca ON ca.id_asignacion = hv.id_asignacion
        WHERE ca.id_camion = p_id_camion
    ) LOOP
        PIPE ROW (HistorialViajesCamionType(
            rec.id_camion,
            rec.descripcion,
            rec.id_estado,
            rec.fecha_salida,
            rec.fecha_llegada
        ));
    END LOOP;

    RETURN;
END HistorialViajesCamion;
/

CREATE OR REPLACE VIEW VistaHistorialViajesCamion AS
SELECT * FROM TABLE(HistorialViajesCamion('SMN139'));

select * from VistaHistorialViajesCamion


    -- CREATE OR REPLACE FUNCTION HistorialViajesCamion (
    --    p_id_camion VARCHAR2
    -- ) RETURN SYS_REFCURSOR AS
    --    v_cursor SYS_REFCURSOR;
    --BEGIN
    --    OPEN v_cursor FOR
    --        SELECT ca.id_camion, hv.descripcion, hv.id_estado, hv.fecha_salida, hv.fecha_llegada
    --        FROM HISTORICO_VIAJES hv
    --        INNER JOIN CAMIONES_ASIGNADOS ca ON ca.id_asignacion = hv.id_asignacion
    --        WHERE ca.id_camion = p_id_camion;
    
        --RETURN v_cursor;
    --END HistorialViajesCamion;
    --/

-- No es una vista, pero es la forma de poder consultar los historiales de un camión parametrizando la consulta
    --VAR result_set REFCURSOR;
    --EXEC :result_set := HistorialViajesCamion('SMN139');
    --PRINT result_set;



-- Vista 7 -- Una vista que permita visualizar los viajes con el tipo de carga en ese viaje
CREATE VIEW tipocarga_viajes AS
SELECT CA.id_camion, TC.ID_TIPO_CARGA, TC.DESCRIPCION
FROM CAMIONES_ASIGNADOS CA
INNER JOIN HISTORICO_VIAJES HV ON CA.ID_ASIGNACION = HV.ID_ASIGNACION
INNER JOIN VIAJES V ON V.ID_VIAJE = HV.ID_VIAJE
INNER JOIN TIPO_CARGA TC ON V.ID_TIPO_CARGA = TC.ID_TIPO_CARGA;

-- Vista 9 -- una vista con los camiones que menos viajes han realizado en el último mes

-- Me la dio chepe, toca corregir, revisarla o hacerla de nuevo
CREATE VIEW CamionesMenosViajesUltimoMes AS
SELECT
    ca.id_camion,
    COUNT(hv.id_viaje) AS cantidad_viajes
FROM
    CAMIONES c
JOIN
    CAMIONES_ASIGNADOS ca ON c.PLACA = ca.id_camion
JOIN
    HISTORICO_VIAJES hv ON hv.id_asignacion = ca.id_asignacion
WHERE
    hv.fecha_llegada >= TRUNC(SYSDATE, 'MM') - INTERVAL '1' MONTH
GROUP BY
    ca.id_camion
ORDER BY
    cantidad_viajes ASC; -- Ordenar de menor a mayor cantidad de viajes

-- Vista 11 -- Una vista que permita visualizar los conductores que menos camiones les han sido asignados

CREATE VIEW conductorMenosAsignaciones AS
SELECT CO.CEDULA, CO.NOMBRES, COUNT(*) AS CANTIDAD_ASIGNACIONES
FROM CONDUCTORES CO
INNER JOIN CAMIONES_ASIGNADOS CA ON CA.ID_CONDUCTOR = CO.CEDULA
GROUP BY CO.CEDULA, CO.NOMBRES
ORDER BY CANTIDAD_ASIGNACIONES ASC;


-- Vista 13 -- Una vista con los viajes que fueron entregados antes del tiempo teórico

CREATE VIEW ViajesEntregadosAntesDelTiempo AS
SELECT
    hv.id_viaje,
    ca.id_camion,
    hv.tiempo_teorico,
    hv.tiempo_real
FROM
    HISTORICO_VIAJES HV
INNER JOIN CAMIONES_ASIGNADOS CA ON CA.ID_ASIGNACION = HV.ID_ASIGNACION
WHERE
    hv.tiempo_real < hv.tiempo_teorico;
