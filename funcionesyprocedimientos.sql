--  -------------------------------PROCEDIMIENTOS-------------------------------
-- Procedimiento 12+1-- un procedimiento almacenado que elimine la asignación entre un conductor y un camión (puede ser un eliminado lógico)

CREATE OR REPLACE PROCEDURE SP_ELIMINAR_CONDUCTOR (
    p_placa IN VARCHAR2,
    p_id_conductor IN VARCHAR2
)
AS
    v_placa VARCHAR2(50);
    v_id_conductor VARCHAR2(80);
    
BEGIN
    --
    SELECT ID_CAMION, ID_CONDUCTOR
    INTO v_placa, v_id_conductor
    FROM CAMIONES_ASIGNADOS 
    WHERE ID_CAMION = p_placa AND ID_CONDUCTOR = p_id_conductor;
    
    UPDATE CAMIONES_ASIGNADOS SET eliminado = '1'
    WHERE ID_CAMION = v_placa AND ID_CONDUCTOR = v_id_conductor;
    
    --COMMIT;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      -- Manejo de la excepción cuando no se encuentra ningún dato
      DBMS_OUTPUT.PUT_LINE('No se encontraron datos ');  
END SP_ELIMINAR_CONDUCTOR;
/
 
EXEC SP_ELIMINAR_CONDUCTOR('JQJ845', '33859438');

    UPDATE CAMIONES_ASIGNADOS SET eliminado = '0'
    WHERE ID_CAMION = 'BEV586' AND ID_CONDUCTOR = '9405669751';
    
SELECT * FROM cambios_camiones_asignados;
SELECT * FROM CAMIONES_ASIGNADOS;
--ALTER TABLE CAMIONES_ASIGNADOS 
--ADD ELIMINADO CHAR(1);

ALTER TABLE CAMIONES_ASIGNADOS 
ADD fecha_asignacion TIMESTAMP;



-------------------------------------------------------------------------

-- Un procedimiento almacenado que actualice el color de un camión (se pudo haber pintado)

CREATE OR REPLACE PROCEDURE SP_ACTUALIZAR_COLOR (
    p_placa IN VARCHAR2,
    p_color IN VARCHAR2
)
AS
    v_placa VARCHAR2(50);
    
BEGIN
    --
    SELECT PLACA
    INTO v_placa
    FROM CAMIONES 
    WHERE PLACA = p_placa;
    
    UPDATE CAMIONES SET color = p_color
    WHERE PLACA = v_placa;
    
    --COMMIT;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      -- Manejo de la excepción cuando no se encuentra ningún dato
      DBMS_OUTPUT.PUT_LINE('No se encontró un camión con esa placa ');  
END SP_ACTUALIZAR_COLOR;
/
 
EXEC SP_ACTUALIZAR_COLOR('DEH270', 'negro');

-- Procedimiento nï¿½mero 5 
CREATE OR REPLACE PROCEDURE registrarEntradaCamion (
    p_placa IN VARCHAR2
)
AS
    v_idCamion VARCHAR2(10);
    v_viajeInfo VARCHAR2(255);
    v_fecha_salida CAMIONES_VISITANTES.fecha_entrada%TYPE;
    v_fecha_entrada CAMIONES_VISITANTES.fecha_entrada%TYPE;
    v_tiempo_tardado NUMBER;
    v_tiempo_teorico VIAJES.duracion_estimada%TYPE;
    
    
BEGIN
    -- Obtener el ID del camión usando la placa
    SELECT placa 
    INTO v_idCamion
    FROM CAMIONES
    WHERE placa = p_placa;
    
    --Obtener la fecha_entrada 
    SELECT fecha_entrada
    INTO v_fecha_entrada
    FROM CAMIONES_VISITANTES
    WHERE placa = v_idCamion;
    
    --Obtener la fecha_salida
    SELECT fecha_salida
    INTO v_fecha_entrada
    FROM CAMIONES_VISITANTES
    WHERE placa = v_idCamion;
    
    
    IF v_idcamion is null then --comprobar si la placa del camiï¿½n estï¿½ registrada en el sistema y si no lo estï¿½ comprobar si va entrando o saliendo el visitante
        IF v_fecha_entrada IS NULL then
            INSERT INTO CAMIONES_VISITANTES (placa, fecha_entrada, fecha_salida)
            VALUES (p_placa, SYSDATE, null);
        ELSIF v_fecha_salida IS NULL THEN -- Si la f
            UPDATE CAMIONES_VISITANTES c set fecha_salida = SYSDATE
            WHERE c.placa = v_idCamion;
        END IF;
    ELSE -- Es un camiï¿½n de la empresa por lo tanto se obtiene la informaciï¿½n de su viaje
        -- Obtener la informaciï¿½n del viaje
        SELECT v.ciudad_origen || ' - ' || v.ciudad_destino || ', Carga: ' || tc.descripcion AS viaje_info, (sysdate - v_fecha_salida) tiempo_viaje
        INTO v_viajeInfo, v_tiempo_tardado 
        FROM historico_viajes hv
        INNER JOIN viajes v on v.id_viaje = hv.id_viaje
        INNER JOIN tipo_carga tc ON tc.id_tipo_carga = v.id_tipo_carga
        INNER JOIN camiones_asignados ca ON ca.id_camion = p_placa;
    END IF;
    
    COMMIT;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      -- Manejo de la excepción cuando no se encuentra ningún dato
      DBMS_OUTPUT.PUT_LINE('No se encontraron datos para la placa ' || v_idCamion);  
    DBMS_OUTPUT.PUT_LINE(v_viajeInfo || ' tiempo teï¿½rico: '|| v_tiempo_teorico || 'tiempo real tardado: '|| v_tiempo_tardado);
END registrarEntradaCamion;
/

EXEC registrarEntradaCamion('SSS139');

CREATE TABLE CAMIONES_VISITANTES (
    id NUMBER PRIMARY KEY,
    placa VARCHAR2(20) NOT NULL,
    fecha_entrada DATE,
    fecha_salida DATE
);

DROP TABLE CAMIONES_VISITANTES;

ALTER TABLE HISTORICO_VIAJES ADD FECHA_SALIDA DATE;
-- Procedimiento 7 ---------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE actualizar_conductor(
    p_placa IN CAMIONES_ASIGNADOS.ID_CAMION%TYPE,
    p_nuevo_conductor IN CAMIONES_ASIGNADOS.ID_CONDUCTOR%TYPE
)
AS
v_id_camion CAMIONES_ASIGNADOS.ID_CAMION%TYPE;
v_id_conductor CAMIONES_ASIGNADOS.ID_CONDUCTOR%TYPE;
BEGIN
--comprobar si existen ambos parï¿½metros, camiï¿½n y conductor

--obtener la placa del camión
SELECT DISTINCT id_camion 
INTO v_id_camion
FROM CAMIONES_ASIGNADOS
WHERE id_camion = p_placa;

--obtener el conductor
SELECT DISTINCT id_conductor 
INTO v_id_conductor
FROM CAMIONES_ASIGNADOS
WHERE id_conductor = p_nuevo_conductor;

IF v_id_camion IS NOT NULL and v_id_conductor IS NOT NULL then
    UPDATE CAMIONES_ASIGNADOS set id_camion = p_placa, id_conductor = p_nuevo_conductor
    WHERE id_camion = p_placa;
ELSE
    RAISE_APPLICATION_ERROR(-20001, 'El conductor no estï¿½ registrado en nuestro sistema, o el camiï¿½n no se encuentra');
END IF;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
     v_id_camion := null;
     v_id_conductor := null;
END actualizar_conductor;
/


-- EXEC actualizar_conductor('SMN139','308666420');

-- procedimiento 9 ---------------------------------------------------------------------------------------------------------------

-- CREATE OR REPLACE PROCEDURE SP_actualizarEstado (
--    P_placa IN CAMIONES.PLACA%TYPE
--)
--AS 

--V_estado HISTORICO_VIAJES.ID_ESTADO%TYPE;

--BEGIN

--SELECT hv.id_estado
--INTO v_estado --Obtener el estado del viaje del camiï¿½n que ingresa o sale
--FROM historico_viajes hv
--INNER JOIN camiones_asignados ca ON ca.id_asignacion = hv.id_asignacion
--where ca.id_camion = P_placa;


-- CASE
--  WHEN v_estado = 1 THEN --Cuando un camion llegue el estado 1 es en curso, lo cambia a finalizado
--       UPDATE historico_viajes 
--        SET id_estado = 2;
--   WHEN v_estado = 3 THEN --Cuando un camion sale el estado 3 es en sin asignar, lo cambia a en cuurso
--      UPDATE historico_viajes 
--        SET id_estado = 1;
--    ELSE   
--        RAISE_APPLICATION_ERROR(-20007, 'Tas loco papi');
--  END CASE;

-- END SP_actualizarEstado;
-- /


CREATE OR REPLACE PROCEDURE SP_HISTORIAL_VIAJES_CAMION(
	V_PLACA CAMIONES.PLACA%TYPE;
)
BEGIN 
	
	SELECT TC.NOMBRE , v.CIUDAD_ORIGEN , V.CIUDAD_DESTINO , HV.TIEMPO_REAL , CA.ID_CAMION  FROM TIPO_CARGA tc 
		INNER JOIN VIAJES v ON TC.ID_TIPO_CARGA = V.ID_TIPO_CARGA 
		INNER JOIN HISTORICO_VIAJES hv ON v.ID_VIAJE = hv.ID_VIAJE 
		INNER JOIN CAMIONES_ASIGNADOS ca ON CA.ID_ASIGNACION = HV.ID_ASIGNACION 
		INNER JOIN CAMIONES c ON CA.ID_CAMION = C.PLACA WHERE C.PLACA = V_PLACA; 
END;


CREATE OR REPLACE PROCEDURE SP_HISTORIAL_VIAJES_CAMION(
	V_PLACA CAMIONES.PLACA%TYPE;
)
BEGIN 
	
	SELECT TC.NOMBRE , v.CIUDAD_ORIGEN , V.CIUDAD_DESTINO , HV.TIEMPO_REAL , CA.ID_CAMION  FROM TIPO_CARGA tc 
		INNER JOIN VIAJES v ON TC.ID_TIPO_CARGA = V.ID_TIPO_CARGA 
		INNER JOIN HISTORICO_VIAJES hv ON v.ID_VIAJE = hv.ID_VIAJE 
		INNER JOIN CAMIONES_ASIGNADOS ca ON CA.ID_ASIGNACION = HV.ID_ASIGNACION 
		INNER JOIN CAMIONES c ON CA.ID_CAMION = C.PLACA WHERE C.PLACA = V_PLACA; 
END;




CREATE OR REPLACE PROCEDURE SP_CAMBIAR_FECHA_ENTREGA(
	V_NFECHA DATE;
)
BEGIN 
	UPDATE HISTORICO_VIAJES SET FECHA_LLEGADA = V_NFECHA; 
END;

CREATE OR REPLACE PROCEDURE SP_DESPEDIR_CONDUCTOR(
	V_CEDULA CONDUCTORES.CEDULA%TYPE;
)
BEGIN 
	DELETE FROM CAMIONES_ASIGNADOS WHERE ID_CONDUCTOR = V_CEDULA;
	DELETE FROM CONDUCTORES WHERE CEDULA = V_CEDULA;
END;


--  -----------------------------FUNCIONES--------------------------------------

-- Funcion almacenada 1 --------------------------------------------------------

CREATE OR REPLACE FUNCTION FnOrigenViaje
(
  Vplaca IN CAMIONES.PLACA%TYPE
)
RETURN VARCHAR2
AS
  Origen VARCHAR2(50);
BEGIN

    SELECT CIUDAD_ORIGEN
    INTO Origen
    FROM (
        SELECT CIUDAD_ORIGEN
          FROM CAMIONES_ASIGNADOS CA
            INNER JOIN HISTORICO_VIAJES HV ON CA.ID_ASIGNACION = HV.ID_ASIGNACION
            INNER JOIN VIAJES V ON V.ID_VIAJE = HV.ID_VIAJE
          WHERE CA.ID_CAMION = Vplaca
            AND HV.ID_ESTADO = 2
          ORDER BY HV.FECHA_LLEGADA DESC
    )
    WHERE ROWNUM = 1;
    RETURN Origen;
END FnOrigenViaje;
/
SHOW ERRORS;

--SELECT FnOrigenViaje('SMN139') AS RESULTADO
--FROM DUAL;


-- Funcion almacenada 3 --------------------------------------------------------

CREATE OR REPLACE FUNCTION FnDetalleCarga
(
    Vplaca IN CAMIONES.PLACA%TYPE
)
RETURN CLOB
AS
    carga CLOB:='';
BEGIN
    -- tipo de carga, peso y destino.
    SELECT car
    INTO carga
    FROM (
    
        SELECT 'Tipo carga: '|| TC.descripcion || ' || '||'Peso: '|| V.PESO_CARGA_KG || ' || Ciudad Destino: ' || V.CIUDAD_DESTINO AS car
        
        FROM CAMIONES_ASIGNADOS CA
        INNER JOIN HISTORICO_VIAJES HV ON CA.ID_ASIGNACION = HV.ID_ASIGNACION
        INNER JOIN VIAJES V ON V.ID_VIAJE = HV.ID_VIAJE
        INNER JOIN TIPO_CARGA TC ON V.ID_TIPO_CARGA = TC.ID_TIPO_CARGA
        WHERE CA.ID_CAMION = Vplaca
        ORDER BY HV.FECHA_LLEGADA DESC)
    WHERE ROWNUM = 1;
    RETURN carga; 
END FnDetalleCarga;
/
SHOW ERRORS;
--Cambios
ALTER TABLE VIAJES ADD PESO_CARGA_KG NUMBER;

SELECT FnDetalleCarga('SMN139') AS RESULTADO
FROM DUAL;

-- Funcion almacenada 5 --------------------------------------------------------
    --El trigger TR_CALCULAR_TIEMPO_TEORICO ya cumple esa funciï¿½n
-- Funcion almacenada 7 --------------------------------------------------------
    -- Una funciï¿½n almacenada que me permita conocer cuï¿½l es la ciudad de donde vienen la mayor cantidad de viajes

    CREATE OR REPLACE FUNCTION FnCiudadMasViajes
    RETURN VARCHAR2
    AS
        ciudad VIAJES.CIUDAD_DESTINO%TYPE;
    BEGIN
        -- ciudad con mï¿½s viajes
        SELECT ciudad_origen 
        --INTO ciudad
        FROM (
            SELECT v.ciudad_origen, count(*) AS CANTIDAD_VIAJES
            FROM VIAJES V
            WHERE v.ciudad_destino = 'Manizales' 
            GROUP BY v.ciudad_origen
            ORDER BY count(*) DESC
            )
        WHERE ROWNUM = 1;
        
        RETURN ciudad; 
    END FnCiudadMasViajes;
    /
    
SELECT FnCiudadMasViajes() AS RESULTADO
FROM DUAL; 
     
    SHOW ERRORS;
-- Funcion almacenada 9 --------------------------------------------------------
    -- Una funciï¿½n almacenada que me permita conocer cuï¿½l es la carga que mï¿½s se transporta en la empresa
    CREATE OR REPLACE FUNCTION FnCargaMasTransportada
    RETURN VARCHAR
    AS
        carga VARCHAR(255);
    BEGIN
        -- carga mas transportada
        SELECT 'id de la carga: ' || id_tipo_carga || ' nombre: '||nombre  --
        INTO carga
        FROM (
            SELECT v.id_tipo_carga, v.peso_carga_kg, count(*) AS CANTIDAD, tc.nombre
            FROM VIAJES V
            INNER JOIN TIPO_CARGA tc ON v.id_tipo_carga = tc.id_tipo_carga
            GROUP BY v.peso_carga_kg, v.id_tipo_carga, tc.nombre
            ORDER BY count(*) DESC
            )
        WHERE ROWNUM = 1;
        
        RETURN carga; 
    END FnCargaMasTransportada;
    /
    SHOW ERRORS;

SELECT FnCargaMasTransportada() AS RESULTADO
FROM DUAL; 
   
CREATE OR REPLACE FUNCTION SF_DIFERENCIA_TIEMPO(
	V_PLACA IN CAMIONES.PLACA%TYPE;
)
RETURN NUMBER 
AS 
V_DELTA_HORAS INTERVAL DAY TO SECOND;
V_TIEMPO_TEORICO INTERVAL DAY TO SECOND;
V_TIEMPO_REAL INTERVAL DAY TO SECOND;
BEGIN
	SELECT TIEMPO_REAL, TIEMPO_TEORICO INTO V_TIEMPO_REAL, V_TIEMPO_TEORICO FROM HISTORICO_VIAJES hv INNER JOIN CAMIONES_ASIGNADOS ca ON hv.ID_ASIGNACION = ca.ID_ASIGNACION WHERE ca.ID_CAMION = V_PLACA;
	V_DELTA_HORAS := V_TIEMPO_REAL - V_TIEMPO_TEORICO;
	RETURN V_DELTA_HORAS;
END SF_DIFERENCIA_TIEMPO;


CREATE OR REPLACE FUNCTION SF_OBTENER_DETALLES_CONDUCTOR(p_placa IN VARCHAR2)
RETURN VARCHAR2
AS
  v_conductor_info VARCHAR2(200);
BEGIN
  SELECT 'Conductor: ' || c.NOMBRES || ' ' || c.APELLIDOS || 
         ', Licencia: ' || c.LICENCIA || 
         ', TelÃ©fono: ' || c.TELEFONO || 
         ', Email: ' || c.EMAIL
  INTO v_conductor_info
  FROM CAMIONES_ASIGNADOS ca
  JOIN CONDUCTORES c ON ca.ID_CONDUCTOR = c.CEDULA
  WHERE ca.ID_CAMION = p_placa;

  RETURN v_conductor_info;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 'No se encontraron detalles para la placa del camiÃ³n proporcionada.';
  WHEN OTHERS THEN
    RETURN 'Error al procesar la solicitud: ' || SQLERRM;
END SF_OBTENER_DETALLES_CONDUCTOR;
/

CREATE OR REPLACE FUNCTION SF_CONTAR_TURNOS_DIA(p_fecha IN DATE)
RETURN NUMBER
AS
  v_cantidad_turnos NUMBER;
BEGIN
  SELECT COUNT(*)
  INTO v_cantidad_turnos
  FROM TURNOS_DESCARGA
  WHERE TRUNC(HORA_ASIGNADA) = TRUNC(p_fecha) AND EXTRACT(HOUR FROM HORA_ASIGNADA) BETWEEN 8 AND 16;

  RETURN v_cantidad_turnos;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 0; -- No hay turnos asignados en la fecha proporcionada.
  WHEN OTHERS THEN
    RETURN -1; -- Error al procesar la solicitud.
END SF_CONTAR_TURNOS_DIA;
/


CREATE OR REPLACE FUNCTION SF_CIUDAD_MAYOR_CARGA
RETURN VARCHAR2
AS
  v_ciudad_destino VARCHAR2(50);
BEGIN
  SELECT CIUDAD_DESTINO
  INTO v_ciudad_destino
  FROM (
    SELECT CIUDAD_DESTINO, COUNT(*) AS CANTIDAD_VIAJES
    FROM VIAJES
    GROUP BY CIUDAD_DESTINO
    ORDER BY COUNT(*) DESC
  )
  WHERE ROWNUM = 1;

  RETURN v_ciudad_destino;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 'No hay informaciÃ³n disponible sobre ciudades de destino.';
  WHEN OTHERS THEN
    RETURN 'Error al procesar la solicitud: ' || SQLERRM;
END SF_CIUDAD_MAYOR_CARGA;
/

CREATE OR REPLACE FUNCTION SF_CAMION_CON_MAS_VIAJES
RETURN VARCHAR2
AS
  v_camion_placa VARCHAR2(50);
BEGIN
  SELECT ID_CAMION
  INTO v_camion_placa
  FROM (
    SELECT ID_CAMION, COUNT(*) AS CANTIDAD_VIAJES
    FROM HISTORICO_VIAJES
    GROUP BY ID_CAMION
    ORDER BY COUNT(*) DESC
  )
  WHERE ROWNUM = 1;

  RETURN v_camion_placa;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 'No hay informaciÃ³n disponible sobre camiones con viajes realizados.';
  WHEN OTHERS THEN
    RETURN 'Error al procesar la solicitud: ' || SQLERRM;
END SF_CAMION_CON_MAS_VIAJES;
/

CREATE OR REPLACE FUNCTION ConductoresAsignadosACamion(
    p_placa_camion IN VARCHAR2
) RETURN VARCHAR2
AS
  v_info_conductores VARCHAR2(4000);
BEGIN
  SELECT LISTAGG('Cédula: ' || cd.CEDULA || ', Nombre: ' || cd.NOMBRES || ' ' || cd.APELLIDOS, '; ')
         WITHIN GROUP (ORDER BY ca.ID_CONDUCTOR) INTO v_info_conductores
  FROM CAMIONES_ASIGNADOS ca
  JOIN CONDUCTORES cd ON ca.ID_CONDUCTOR = cd.CEDULA
  WHERE ca.ID_CAMION = p_placa_camion;

  IF v_info_conductores IS NOT NULL THEN
    RETURN v_info_conductores;
  ELSE
    RETURN 'No hay conductores asignados al camión con placa ' || p_placa_camion;
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 'No hay información disponible.';
  WHEN OTHERS THEN
    RETURN 'Error al procesar la solicitud: ' || SQLERRM;
END ConductoresAsignadosACamion;
/


SELECT ConductoresAsignadosACamion('SMN139') FROM DUAL;

-- ----------------TRIGGERS--------------------------
    -- Trigger max id de CAMIONES_VISITANTES
      CREATE OR REPLACE TRIGGER TgrGenIdCV
      BEFORE INSERT ON CAMIONES_VISITANTES
      FOR EACH ROW
      
      BEGIN 
      SELECT MAX(ID)+1
      INTO :NEW.ID
      FROM CAMIONES_VISITANTES;
      END TgrGenId;
      /
      show errors;
      
      