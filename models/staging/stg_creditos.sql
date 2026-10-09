with fuente as (

    select * from {{ source('raw', 'creditos') }}

),

limpio as (

    select
        credito_id,
        usuario_id,

        case
            when lower(trim(producto)) in ('personal', 'préstamo personal')        then 'Personal'
            when lower(trim(producto)) in ('nómina', 'crédito de nómina')          then 'Nómina'
            when lower(trim(producto)) in ('pyme', 'crédito pyme')                 then 'PyME'
            else 'Desconocido'
        end as producto,

        try_to_number(monto) as monto,
        try_to_number(tasa_anual) as tasa_anual,
        try_to_number(plazo_meses) as plazo_meses,

        coalesce(
            try_to_date(fecha_originacion, 'YYYY-MM-DD'),
            try_to_date(fecha_originacion, 'DD/MM/YYYY'),
            try_to_date(fecha_originacion, 'MM-DD-YYYY')
        ) as fecha_originacion,

        case
            when lower(trim(estatus)) in ('vigente', 'activo')     then 'Vigente'
            when lower(trim(estatus)) in ('pagado', 'liquidado')   then 'Pagado'
            when lower(trim(estatus)) in ('en mora', 'moroso')     then 'En mora'
            when lower(trim(estatus)) in ('castigado', 'incobrable') then 'Castigado'
            else 'Desconocido'
        end as estatus

    from fuente

)

select * from limpio