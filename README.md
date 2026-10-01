# PrestaMX - Credit Pipeline

Pipeline de datos de punta a punta para una fintech:


## Problema
La lider de la fintech PrestaMX nos menciona que ha crecido muy rapido la fintech, por lo tanto, requiere que armemos una base de datos confiable y respondamos varias preguntas.

## Objetivo de negocio
Nos solicitan llegar a una conclusion y visualizacion leve de los datos. Asi mismo, se busca resolver 5 incognitas:
1. **Tasa de morosidad**: ¿qué % de nuestra cartera está en mora? Y desglosada por producto y por segmento de riesgo.
2. **Saldo en riesgo**: ¿cuánto dinero está pendiente en créditos morosos?
3. **Comportamiento de pago**: ¿qué % de cuotas se pagan a tiempo, tarde o no se pagan?
4. **Originación**: ¿cuánto hemos colocado por mes y por producto? (crecimiento)
5. **Cartera por estatus**: distribución de créditos vigentes/pagados/en mora/castigados.

## Arquitectura
 
```mermaid
flowchart LR
    A[CSV crudos<br/>~80K registros] --> B[pandas<br/>limpieza y modelado]
    B --> C[Parquet<br/>tipado y comprimido]
```

## Stack
Python | pandas | SQL | AWS S3 | AWS Athena | Git