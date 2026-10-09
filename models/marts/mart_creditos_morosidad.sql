with creditos as (

    select * from {{ ref('stg_creditos') }}

),

pagos as (

    select * from {{ ref('stg_pagos') }}

),

resumen_pagos as (

    select
        credito_id,
        count(*) as total_cuotas,
        count_if(estatus_cuota = 'Pagada') as cuotas_pagadas,
        count_if(estatus_cuota = 'Vencida impaga') as cuotas_vencidas_impagas,
        max(dias_atraso) as max_dias_atraso,
        sum(case when estatus_cuota = 'Pagada' then monto_pagado else 0 end) as total_pagado,
        sum(monto_programado) as monto_total_programado
    from pagos
    group by credito_id

)

select
    c.credito_id,
    c.usuario_id,
    c.producto,
    c.monto,
    c.estatus as estatus_origen,

    r.total_cuotas,
    r.cuotas_pagadas,
    r.cuotas_vencidas_impagas,
    r.max_dias_atraso,
    r.monto_total_programado - r.total_pagado as saldo_pendiente,

    case
        when r.cuotas_vencidas_impagas > 0 then true
        else false
    end as en_mora

from creditos c
left join resumen_pagos r on c.credito_id = r.credito_id