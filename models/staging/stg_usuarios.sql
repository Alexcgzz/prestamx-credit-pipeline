with fuente as (

    select distinct * from {{ source('raw', 'usuarios') }}

),

limpio as (

    select
        usuario_id,
        nombre,
        nullif(trim(email), '') as email,
        coalesce(
            try_to_date(fecha_registro, 'YYYY-MM-DD'),
            try_to_date(fecha_registro, 'DD/MM/YYYY'),
            try_to_date(fecha_registro, 'MM/DD/YYYY')
        ) as fecha_registro,
        estado,
        case
            when lower(trim(segmento)) in ('a', 'alto')  then 'A'
            when lower(trim(segmento)) in ('b', 'medio') then 'B'
            when lower(trim(segmento)) in ('c', 'bajo')  then 'C'
            else 'Desconocido'
        end as segmento,
        try_to_number(ingreso_mensual) as ingreso_mensual,
        try_to_number(score) as score

    from fuente

)

select * from limpio