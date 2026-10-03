with fuente as (

    select * from {{ source('raw', 'usuarios') }}

),

limpio as (

    select
        usuario_id,
        nombre,
        nullif(trim(email), '')                          as email,
        try_to_date(fecha_registro, 'YYYY-MM-DD')        as fecha_registro,
        estado,

        case
            when lower(trim(segmento)) in ('a', 'alto')  then 'A'
            when lower(trim(segmento)) in ('b', 'medio') then 'B'
            when lower(trim(segmento)) in ('c', 'bajo')  then 'C'
            else 'Desconocido'
        end                                              as segmento,

        try_to_number(ingreso_mensual)                   as ingreso_mensual,
        try_to_number(score)                             as score

    from fuente

)

select * from limpio