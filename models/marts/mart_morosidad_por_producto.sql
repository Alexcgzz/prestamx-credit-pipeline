with creditos as (

    select * from {{ ref('mart_creditos_morosidad') }}

)

select
    producto,

    count(*) as total_creditos,
    count_if(en_mora) as creditos_en_mora,

    round(100.0 * count_if(en_mora) / count(*), 2) as tasa_morosidad_pct,

    round(sum(case when en_mora then saldo_pendiente else 0 end), 2) as saldo_en_riesgo,

    round(sum(saldo_pendiente), 2) as saldo_total,
    round(avg(max_dias_atraso), 0) as dias_atraso_promedio

from creditos
group by producto
order by tasa_morosidad_pct desc