with fuente as (

    select * from {{ source('raw', 'pagos') }}

),

limpio as (

    select
        pago_id,
        credito_id,
        try_to_number(num_cuota) as num_cuota,

        coalesce(
            try_to_date(fecha_programada, 'YYYY-MM-DD'),
            try_to_date(fecha_programada, 'DD/MM/YYYY'),
            try_to_date(fecha_programada, 'MM-DD-YYYY')
        ) as fecha_programada,

        coalesce(
            try_to_date(fecha_pago, 'YYYY-MM-DD'),
            try_to_date(fecha_pago, 'DD/MM/YYYY'),
            try_to_date(fecha_pago, 'MM-DD-YYYY')
        ) as fecha_pago,

        try_to_number(monto_programado) as monto_programado,
        try_to_number(monto_pagado) as monto_pagado

    from fuente

),

enriquecido as (

    select
        *,

        case
            when fecha_pago is not null then 'Pagada'
            when fecha_programada >= current_date() then 'Por vencer'
            else 'Vencida impaga'
        end as estatus_cuota,

        case
            when fecha_pago is not null
                then datediff('day', fecha_programada, fecha_pago)
            when fecha_programada < current_date()
                then datediff('day', fecha_programada, current_date())
            else 0
        end as dias_atraso

    from limpio

)

select * from enriquecido