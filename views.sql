----- Views del proyecto --------------------------

-- Vista 1 -- Una vista que permita consultar los camiones que han hecho viajes de m�s de 8 horas en los �ltimos 7 d�as.

CREATE VIEW Camiones_viajes_8h7d AS
SELECT PLACA, ID_VIAJE, DESCRIPCION
FROM CAMIONES c
INNER JOIN CAMIONES_ASIGNADOS ca ON ca.id_camion = c.placa
INNER JOIN HISTORICO_VIAJES hv ON ca.id_asignacion = hv.id_asignacion
WHERE HV.TIEMPO_REAL > INTERVAL '8' HOUR AND HV.fecha_salida >= (SYSDATE - INTERVAL '7' DAY);


ALTER TABLE HISTORICO_VIAJES ADD fecha_llegada TIMESTAMP;

-- Vista 2 -------------------------------------------------------------------------

CREATE OR REPLACE VIEW CamionesConductoresEnViaje AS
SELECT
  ca.ID_ASIGNACION,
  c.PLACA AS PLACA_CAMION,
  c.MARCA,
  c.MODELO,
  co.NOMBRES || ' ' || co.APELLIDOS AS NOMBRE_CONDUCTOR,
  tv.CIUDAD_ORIGEN,
  tv.CIUDAD_DESTINO,
  tv.DURACION_ESTIMADA,
  hv.FECHA_SALIDA,
  hv.FECHA_LLEGADA,
  ev.ESTADO AS ESTADO_VIAJE
FROM
  CAMIONES_ASIGNADOS ca
  JOIN CAMIONES c ON ca.ID_CAMION = c.PLACA
  JOIN CONDUCTORES co ON ca.ID_CONDUCTOR = co.CEDULA
  JOIN HISTORICO_VIAJES hv ON ca.ID_ASIGNACION = hv.ID_ASIGNACION
  JOIN VIAJES tv ON hv.ID_VIAJE = tv.ID_VIAJE
  JOIN ESTADOS_VIAJE ev ON hv.ID_ESTADO = ev.ID_ESTADO
WHERE
  ev.ESTADO = 'EN CURSO';

-- Vista 3 -------------------------------------------------------------------------

-- Una vista que permita ver el n�mero total de veh�culos que est�n en viaje (estado en curso)

CREATE VIEW Vehiculos_en_curso AS
SELECT count(*) Vehiculos_En_Curso
FROM HISTORICO_VIAJES
WHERE id_estado = 2;

--Vista 4 --------------------------------------------------------------------------
CREATE OR REPLACE VIEW ViajesEntregadosEnUltimas24Horas AS
SELECT
  hv.ID_VIAJE,
  tv.CIUDAD_ORIGEN,
  tv.CIUDAD_DESTINO,
  hv.FECHA_SALIDA,
  hv.FECHA_LLEGADA,
  ev.ESTADO AS ESTADO_VIAJE
FROM
  HISTORICO_VIAJES hv
  JOIN VIAJES tv ON hv.ID_VIAJE = tv.ID_VIAJE
  JOIN ESTADOS_VIAJE ev ON hv.ID_ESTADO = ev.ID_ESTADO
WHERE
  ev.ESTADO = 'Entregado'
  AND hv.FECHA_LLEGADA IS NOT NULL
  AND hv.FECHA_LLEGADA >= SYSDATE - INTERVAL '24' HOUR;



-- Vista 5 -- una vista que permita visualizar el historial de viajes de un cami�n (con el fin de saber qu� tan usado ha sido el cami�n 

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
SELECT * FROM TABLE(HistorialViajesCamion('PQQ875'));

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

-- No es una vista, pero es la forma de poder consultar los historiales de un cami�n parametrizando la consulta
    --VAR result_set REFCURSOR;
    --EXEC :result_set := HistorialViajesCamion('SMN139');
    --PRINT result_set;

-- Vista 6 -----------------------------------------------------

CREATE OR REPLACE VIEW ViajesRealizados AS
SELECT
  hv.ID_VIAJE,
  tv.CIUDAD_ORIGEN,
  tv.CIUDAD_DESTINO,
  hv.FECHA_SALIDA,
  hv.FECHA_LLEGADA,
  ev.ESTADO AS ESTADO_VIAJE
FROM
  HISTORICO_VIAJES hv
  JOIN VIAJES tv ON hv.ID_VIAJE = tv.ID_VIAJE
  JOIN ESTADOS_VIAJE ev ON hv.ID_ESTADO = ev.ID_ESTADO
WHERE
  hv.FECHA_LLEGADA IS NOT NULL;

 
 
SELECT * FROM ViajesRealizados;

-- Vista 7 -- Una vista que permita visualizar los viajes con el tipo de carga en ese viaje
CREATE VIEW tipocarga_viajes AS
SELECT CA.id_camion, TC.ID_TIPO_CARGA, TC.DESCRIPCION
FROM CAMIONES_ASIGNADOS CA
INNER JOIN HISTORICO_VIAJES HV ON CA.ID_ASIGNACION = HV.ID_ASIGNACION
INNER JOIN VIAJES V ON V.ID_VIAJE = HV.ID_VIAJE
INNER JOIN TIPO_CARGA TC ON V.ID_TIPO_CARGA = TC.ID_TIPO_CARGA;

-- Vista 8 ----------------------------------------------------------------

CREATE OR REPLACE VIEW CamionesMasViajesUltimoMes AS
SELECT
  ca.ID_CAMION,
  c.PLACA,
  c.MARCA,
  c.MODELO,
  COUNT(hv.ID_VIAJE) AS CANTIDAD_VIAJES
FROM
  CAMIONES_ASIGNADOS ca
  JOIN CAMIONES c ON ca.ID_CAMION = c.PLACA
  JOIN HISTORICO_VIAJES hv ON ca.ID_ASIGNACION = hv.ID_ASIGNACION
WHERE
  hv.FECHA_LLEGADA IS NOT NULL
  AND hv.FECHA_LLEGADA >= TRUNC(SYSDATE, 'MM') - INTERVAL '1' MONTH
GROUP BY
  ca.ID_CAMION, c.PLACA, c.MARCA, c.MODELO
ORDER BY
  CANTIDAD_VIAJES DESC;

 
SELECT * FROM CamionesMasViajesUltimoMes;



-- Vista 9 -- una vista con los camiones que menos viajes han realizado en el �ltimo mes

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
    
    
-- Vista 10 -----------------------------------------------------------------------------

CREATE OR REPLACE VIEW CondMasCamionesAsig AS
SELECT
  co.CEDULA,
  co.NOMBRES,
  co.APELLIDOS,
  COUNT(ca.ID_CAMION) AS CANTIDAD_CAMIONES_ASIGNADOS
FROM
  CONDUCTORES co
  JOIN CAMIONES_ASIGNADOS ca ON co.CEDULA = ca.ID_CONDUCTOR
GROUP BY
  co.CEDULA, co.NOMBRES, co.APELLIDOS
ORDER BY
  CANTIDAD_CAMIONES_ASIGNADOS DESC;

SELECT * FROM CondMasCamionesAsig;

-- Vista 11 -- Una vista que permita visualizar los conductores que menos camiones les han sido asignados

CREATE VIEW conductorMenosAsignaciones AS
SELECT CO.CEDULA, CO.NOMBRES, COUNT(*) AS CANTIDAD_ASIGNACIONES
FROM CONDUCTORES CO
INNER JOIN CAMIONES_ASIGNADOS CA ON CA.ID_CONDUCTOR = CO.CEDULA
GROUP BY CO.CEDULA, CO.NOMBRES
ORDER BY CANTIDAD_ASIGNACIONES ASC;


-- Vista 12 --------------------------------------------------------------------

CREATE OR REPLACE VIEW ViajesEntregadosFueraDeTiempoTeorico AS
SELECT
  hv.ID_HISTORIAL,
  tv.CIUDAD_ORIGEN,
  tv.CIUDAD_DESTINO,
  hv.FECHA_SALIDA,
  hv.FECHA_LLEGADA,
  tv.DURACION_ESTIMADA,
  hv.TIEMPO_TEORICO,
  ev.ESTADO AS ESTADO_VIAJE
FROM
  HISTORICO_VIAJES hv
  JOIN VIAJES tv ON hv.ID_VIAJE = tv.ID_VIAJE
  JOIN ESTADOS_VIAJE ev ON hv.ID_ESTADO = ev.ID_ESTADO
WHERE
  ev.ESTADO = 'FINALIZADO'
  AND hv.FECHA_LLEGADA IS NOT NULL
  AND hv.FECHA_LLEGADA > hv.FECHA_SALIDA + hv.TIEMPO_TEORICO;

 SELECT * FROM ViajesEntregadosFueraDeTiempoTeorico;




-- Vista 13 -- Una vista con los viajes que fueron entregados antes del tiempo te�rico

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


