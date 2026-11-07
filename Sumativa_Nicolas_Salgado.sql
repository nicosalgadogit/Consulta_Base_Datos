/*Caso 1: Análisis de Propiedades*/
SELECT id_tipo_propiedad                                              AS TIPO,
       COUNT(nro_propiedad)                                           AS TOTAL_PROPIEDADES,
       -- Máximo y mínimo se muestran como en la Figura 2 (con ".00")
       TO_CHAR(MAX(valor_arriendo), 'FM$999G999G999') || '.00'        AS MAX_ARRIENDO,
       -- Promedio redondeado a entero
       TO_CHAR(ROUND(AVG(valor_arriendo)), 'FM$999G999G999')          AS PROMEDIO_ARRIENDO,
       TO_CHAR(MIN(valor_arriendo), 'FM$999G999G999') || '.00'        AS MIN_ARRIENDO,
       -- Clasificación según el valor máximo de arriendo del tipo
       CASE
            WHEN MAX(valor_arriendo) <= 1000000 THEN 'ESTÁNDAR'
            ELSE 'PREMIUM'
       END                                                            AS CLASIFICACION,
       -- NVL: si una propiedad no tiene gasto común se considera 0
       TO_CHAR(SUM(NVL(valor_gasto_comun, 0)), 'FM$999G999G999')      AS TOTAL_GASTOS_COMUNES
FROM   propiedad
GROUP BY id_tipo_propiedad
-- Restricción de grupos: total gasto común mayor al valor ingresado
HAVING SUM(NVL(valor_gasto_comun, 0)) > &VALOR_TOTAL_GASTO_COMUN
ORDER BY SUM(NVL(valor_gasto_comun, 0)) DESC;


/*Caso 2: Análisis de antigüedad de empleados*/
SELECT UPPER(nombre_emp || ' ' || appaterno_emp)                      AS "Nombre Empleado",
       TO_CHAR(sueldo_emp, 'FM$999G999G999')                          AS "Sueldo con Formato",
       CASE
            WHEN sueldo_emp > 2000000 THEN 'ALTO'
            ELSE 'MEDIO'
       END                                                            AS "Clasificación Sueldo",
       -- Años completos de servicio (fecha paramétrica con SYSDATE)
       TRUNC(MONTHS_BETWEEN(SYSDATE, fecing_emp) / 12)                AS "Años Antigüedad",
       'Corresponde bono '
       || LPAD(CASE
                    WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, fecing_emp) / 12) BETWEEN 5 AND 10  THEN 5
                    WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, fecing_emp) / 12) BETWEEN 11 AND 20 THEN 10
                    ELSE 15
               END, 2)
       || '%: '
       || TO_CHAR(ROUND(sueldo_emp *
               CASE
                    WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, fecing_emp) / 12) BETWEEN 5 AND 10  THEN 0.05
                    WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, fecing_emp) / 12) BETWEEN 11 AND 20 THEN 0.10
                    ELSE 0.15
               END), '$999G999G999')                                  AS "BONO"
FROM   empleado
WHERE  id_categoria_emp = 3
AND    id_sucursal <> &CODIGO_SUCURSAL
AND    MONTHS_BETWEEN(SYSDATE, fecing_emp) / 12 > 5
ORDER BY sueldo_emp DESC;


/*Caso 3: Lista de clientes */ 
SELECT CASE
            WHEN renta_cli >= 1000000 THEN 'PREMIUM'
            WHEN renta_cli >= 600000  THEN 'ALTA'
            WHEN renta_cli >= 300000  THEN 'MEDIA'
            ELSE 'BAJA'
       END                                                            AS CLASIFICACION_RENTA,
       COUNT(numrut_cli)                                              AS CANTIDAD_CLIENTES,
       TO_CHAR(ROUND(AVG(renta_cli)), 'FM$999G999G999')               AS RENTA_PROMEDIO,
       -- fonofijo_cli es NOT NULL; el teléfono opcional es celular_cli.
       -- COUNT ignora nulos: si ningún cliente del grupo tiene celular el conteo es 0
       CASE
            WHEN COUNT(celular_cli) = 0 THEN 'Clientes Sin Teléfono'
            ELSE 'Clientes con Teléfono'
       END                                                            AS ESTADO_TELEFONO
FROM   cliente
GROUP BY CASE
              WHEN renta_cli >= 1000000 THEN 'PREMIUM'
              WHEN renta_cli >= 600000  THEN 'ALTA'
              WHEN renta_cli >= 300000  THEN 'MEDIA'
              ELSE 'BAJA'
         END
--Promedio de renta mayor a 200.000
HAVING AVG(renta_cli) > 200000;
