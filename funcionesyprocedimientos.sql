--  -------------------------------PROCEDIMIENTOS-------------------------------
-- Procedimiento n�mero 5 
CREATE OR REPLACE PROCEDURE registrarEntradaCamion (
    p_placa IN VARCHAR2
)
AS
    v_idCamion NUMBER;
    v_viajeInfo VARCHAR2(255);
    v_fecha_salida CAMIONES_VISITANTES.fecha_entrada%TYPE;
    v_fecha_entrada CAMIONES_VISITANTES.fecha_entrada%TYPE;
    v_tiempo_tardado NUMBER;
    v_tiempo_teorico VIAJES.duracion_estimada%TYPE;
    
    
BEGIN
    -- Obtener el ID del cami�n usando la placa
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
    
    
    IF v_idcamion is null then --comprobar si la placa del cami�n est� registrada en el sistema y si no lo est� comprobar si va entrando o saliendo el visitante
        IF v_fecha_entrada IS NULL then
            INSERT INTO CAMIONES_VISITANTES (placa, fecha_entrada, fecha_salida)
            VALUES (p_placa, SYSDATE, null);
        ELSIF v_fecha_salida IS NULL THEN -- Si la f
            UPDATE CAMIONES_VISITANTES c set fecha_salida = SYSDATE
            WHERE c.placa = v_idCamion;
        END IF;
    ELSE -- Es un cami�n de la empresa por lo tanto se obtiene la informaci�n de su viaje
        -- Obtener la informaci�n del viaje
        SELECT v.ciudad_origen || ' - ' || v.ciudad_destino || ', Carga: ' || tc.descripcion AS viaje_info, (sysdate - v_fecha_salida) tiempo_viaje
        INTO v_viajeInfo, v_tiempo_tardado 
        FROM historico_viajes hv
        INNER JOIN viajes v on v.id_viaje = hv.id_viaje
        INNER JOIN tipo_carga tc ON tc.id_tipo_carga = v.id_tipo_carga
        INNER JOIN camiones_asignados ca ON ca.id_camion = p_placa;
    END IF;
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE(v_viajeInfo || ' tiempo te�rico: '|| v_tiempo_teorico || 'tiempo real tardado: '|| v_tiempo_tardado);
END registrarEntradaCamion;
/

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
--comprobar si existen ambos par�metros, cami�n y conductor

SELECT id_camion, id_conductor 
INTO v_id_camion, v_id_conductor
FROM CAMIONES_ASIGNADOS
WHERE id_camion = p_placa and id_conductor = p_nuevo_conductor;

IF v_id_camion IS NOT NULL and v_id_conductor IS NOT NULL then
    UPDATE CAMIONES_ASIGNADOS set id_camion = p_placa, id_conductor = p_nuevo_conductor;
ELSE
    RAISE_APPLICATION_ERROR(-20001, 'El conductor no est� registrado en nuestro sistema, o el cami�n no se encuentra');
END IF;
END actualizar_conductor;
/

-- procedimiento 9 ---------------------------------------------------------------------------------------------------------------

-- CREATE OR REPLACE PROCEDURE SP_actualizarEstado (
--    P_placa IN CAMIONES.PLACA%TYPE
--)
--AS 

--V_estado HISTORICO_VIAJES.ID_ESTADO%TYPE;

--BEGIN

--SELECT hv.id_estado
--INTO v_estado --Obtener el estado del viaje del cami�n que ingresa o sale
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
FROM CAMIONES_ASIGNADOS CA
INNER JOIN HISTORICO_VIAJES HV ON CA.ID_ASIGNACION = HV.ID_ASIGNACION
INNER JOIN VIAJES V ON V.ID_VIAJE = HV.ID_VIAJE
WHERE CA.ID_CAMION = Vplaca;

RETURN Origen;
END FnOrigenViaje;
/
SHOW ERRORS;

SELECT FNFiltro('HIS',101,'A')
FROM DUAL;

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
    SELECT 'Tipo carga: '|| TC.descripcion || ' || '||'Peso: '|| V.PESO_CARGA_KG || ' || ' || V.CIUDAD_DESTINO
    INTO carga
    FROM CAMIONES_ASIGNADOS CA
    INNER JOIN HISTORICO_VIAJES HV ON CA.ID_ASIGNACION = HV.ID_ASIGNACION
    INNER JOIN VIAJES V ON V.ID_VIAJE = HV.ID_VIAJE
    INNER JOIN TIPO_CARGA TC ON V.ID_TIPO_CARGA = TC.ID_TIPO_CARGA
    WHERE CA.ID_CAMION = Vplaca;
    
    RETURN carga; 
END FnDetalleCarga;
/
SHOW ERRORS;
--Cambios
ALTER TABLE VIAJES ADD PESO_CARGA_KG NUMBER;

-- Funcion almacenada 5 --------------------------------------------------------
    --El trigger TR_CALCULAR_TIEMPO_TEORICO ya cumple esa funci�n
-- Funcion almacenada 7 --------------------------------------------------------
    -- Una funci�n almacenada que me permita conocer cu�l es la ciudad de donde vienen la mayor cantidad de viajes

    CREATE OR REPLACE FUNCTION FnCiudadMasViajes
    RETURN VARCHAR2
    AS
        ciudad VIAJES.CIUDAD_DESTINO%TYPE;
    BEGIN
        -- ciudad con m�s viajes
        SELECT ciudad_origen 
        INTO ciudad
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
     
    SHOW ERRORS;
-- Funcion almacenada 9 --------------------------------------------------------
    -- Una funci�n almacenada que me permita conocer cu�l es la carga que m�s se transporta en la empresa
    CREATE OR REPLACE FUNCTION FnCargaMasTransportada
    RETURN VIAJES.ID_TIPO_CARGA%TYPE
    AS
        carga VIAJES.ID_TIPO_CARGA%TYPE;
    BEGIN
        -- carga mas transportada
        SELECT id_tipo_carga --, peso_carga_kg, CANTIDAD por si se quiere devolver algo m�s que solo el id del m�s buscado (se necesitan m�s variables)
        INTO carga
        FROM (
            SELECT v.id_tipo_carga, v.peso_carga_kg, count(*) AS CANTIDAD
            FROM VIAJES V
            GROUP BY v.peso_carga_kg, v.id_tipo_carga
            ORDER BY count(*) DESC
            )
        WHERE ROWNUM = 1;
        
        RETURN carga; 
    END FnCargaMasTransportada;
    /
    SHOW ERRORS;
   
   
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
         ', Teléfono: ' || c.TELEFONO || 
         ', Email: ' || c.EMAIL
  INTO v_conductor_info
  FROM CAMIONES_ASIGNADOS ca
  JOIN CONDUCTORES c ON ca.ID_CONDUCTOR = c.CEDULA
  WHERE ca.ID_CAMION = p_placa;

  RETURN v_conductor_info;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 'No se encontraron detalles para la placa del camión proporcionada.';
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
    RETURN 'No hay información disponible sobre ciudades de destino.';
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
    RETURN 'No hay información disponible sobre camiones con viajes realizados.';
  WHEN OTHERS THEN
    RETURN 'Error al procesar la solicitud: ' || SQLERRM;
END SF_CAMION_CON_MAS_VIAJES;
/


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
      
      