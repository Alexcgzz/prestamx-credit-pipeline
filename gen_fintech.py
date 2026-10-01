import csv, random, os
from datetime import date, timedelta
from faker import Faker

fake = Faker('es_MX')
Faker.seed(7); random.seed(7)

OUT = '/home/claude/fintech_out'
os.makedirs(OUT, exist_ok=True)
HOY = date(2026, 9, 30)

N_USERS = 3000
N_CRED  = 5000

estados = ['Nuevo León','CDMX','Jalisco','Puebla','Yucatán','Coahuila',
           'Guanajuato','Querétaro','Baja California','Sonora']
segmento_variants = {'A':['A','a','Alto'],'B':['B','b','Medio'],'C':['C','c','Bajo']}
producto_variants = {
    'Personal':['Personal','personal','PERSONAL','Préstamo Personal'],
    'Nómina':['Nómina','nomina','NOMINA','Crédito de Nómina'],
    'PyME':['PyME','pyme','PYME','Crédito PyME'],
}
estatus_variants = {
    'Vigente':['Vigente','vigente','VIGENTE','Activo'],
    'Pagado':['Pagado','pagado','PAGADO','Liquidado'],
    'En mora':['En mora','en mora','EN MORA','Moroso'],
    'Castigado':['Castigado','castigado','CASTIGADO','Incobrable'],
}

def maybe_null(v, p=0.07): return '' if random.random() < p else v
def rand_date(y0, y1):
    s, e = date(y0,1,1), date(y1,9,1); return s + timedelta(days=random.randint(0,(e-s).days))
def fmt(d):
    return d.strftime(random.choice(['%Y-%m-%d','%d/%m/%Y','%m-%d-%Y']))
def w(name, header, rows):
    with open(os.path.join(OUT,name),'w',newline='',encoding='utf-8') as f:
        wr=csv.writer(f); wr.writerow(header); wr.writerows(rows)
    print(f'{name}: {len(rows)} filas')

# ---------- USUARIOS ----------
usuarios=[]
for i in range(1, N_USERS+1):
    seg_c = random.choice(list(segmento_variants))
    ingreso = round(random.uniform(8000,80000),2)
    if random.random()<0.01: ingreso = -ingreso
    usuarios.append([f'U{i:05d}', fake.name(), maybe_null(fake.email(),0.05),
        fmt(rand_date(2022,2026)), random.choice(estados),
        random.choice(segmento_variants[seg_c]),
        maybe_null(ingreso,0.06), maybe_null(random.randint(300,850),0.08)])
for _ in range(25): usuarios.append(list(random.choice(usuarios)))  # duplicados
w('usuarios.csv',['usuario_id','nombre','email','fecha_registro','estado','segmento','ingreso_mensual','score'],usuarios)

user_ids=[u[0] for u in usuarios]

# ---------- CREDITOS + PAGOS ----------
creditos=[]; pagos=[]; pago_seq=1
for i in range(1, N_CRED+1):
    cid=f'CR{i:06d}'; uid=random.choice(user_ids)
    prod_c=random.choice(list(producto_variants))
    monto=round(random.uniform(5000,150000),2)
    tasa=round(random.uniform(0.25,0.90),2)
    plazo=random.choice([6,12,18,24])
    orig=rand_date(2023,2026)
    comport=random.choices(['bueno','regular','malo'],weights=[0.55,0.30,0.15])[0]
    cuota_monto=round(monto*(1+tasa*plazo/12)/plazo,2)

    cuotas_vencidas=0; cuotas_impagas=0; total_generadas=0
    for n in range(1, plazo+1):
        f_prog = orig + timedelta(days=30*n)
        total_generadas+=1
        if f_prog > HOY:
            pagos.append([f'PG{pago_seq:07d}',cid,n,fmt(f_prog),'',cuota_monto,'']); pago_seq+=1
            continue
        cuotas_vencidas+=1
        if comport=='bueno': r=random.choices(['ontime','late','unpaid'],weights=[0.9,0.08,0.02])[0]
        elif comport=='regular': r=random.choices(['ontime','late','unpaid'],weights=[0.65,0.22,0.13])[0]
        else: r=random.choices(['ontime','late','unpaid'],weights=[0.35,0.30,0.35])[0]
        if r=='ontime':
            f_pago=f_prog+timedelta(days=random.randint(0,3)); pagado=cuota_monto
        elif r=='late':
            f_pago=f_prog+timedelta(days=random.randint(5,40)); pagado=cuota_monto
        else:
            f_pago=None; pagado=''; cuotas_impagas+=1
        pagos.append([f'PG{pago_seq:07d}',cid,n,fmt(f_prog),fmt(f_pago) if f_pago else '',cuota_monto,pagado]); pago_seq+=1

    # estatus (flag crudo, con algo de ruido: no siempre confiable)
    if cuotas_vencidas>0 and cuotas_vencidas==total_generadas and cuotas_impagas==0:
        est_c='Pagado'
    elif cuotas_impagas>=4: est_c='Castigado'
    elif cuotas_impagas>=1: est_c='En mora'
    else: est_c='Vigente'
    if random.random()<0.08: est_c=random.choice(list(estatus_variants))  # ruido
    creditos.append([cid,uid,random.choice(producto_variants[prod_c]),monto,tasa,plazo,
        fmt(orig),random.choice(estatus_variants[est_c])])

w('creditos.csv',['credito_id','usuario_id','producto','monto','tasa_anual','plazo_meses','fecha_originacion','estatus'],creditos)
w('pagos.csv',['pago_id','credito_id','num_cuota','fecha_programada','fecha_pago','monto_programado','monto_pagado'],pagos)
print('\nListo.')
