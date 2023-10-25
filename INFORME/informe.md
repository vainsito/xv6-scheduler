## Informe que responde la primera parte del laboratorio.

#### 1- Que politica de planificacion utiliza xv6-riscv para elegir el proximo proceso a ejecutarse?

Analizando el codigo podemos determinar que la politica de planificacion que utiliza xv6 se trata de Round Robin. Esto basado en el hecho de que no sale de forma normal de la funcion Scheduler, si no que se realizan interrupciones luego de ciertos intervalos que se determinan en start.c

Esto implica la existencia de un Quantum de tiempo, y al no existir una cola de prioridades o una forma de determinar si un proceso debe ejecutarse por sobre otro, si no que todos tienen la misma posibilidad de 
ejecutarse podemos determinar que se trata de Round Robin.

---
#### 2- Cuanto dura un Quantum en xv6-riscv?

El Quantum en xv6-riscv como mencionamos en el ejercicio anterior, se determina en el archivo start.c, en donde se define la variable interval, la cual es la que determina el tiempo de cada Quantum. En este caso podemos observar que interval posee el valor de **1000000 cycles (1ms), o 1/10 de segundo**.

```c

void
timerinit()
{
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
  scratch[3] = CLINT_MTIMECMP(id);
  scratch[4] = interval;
  w_mscratch((uint64)scratch);

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
}

```
--- 
#### 3- Cuanto dura un cambio de contexto en xv6-riscv?

Para conocer el **tiempo de duracion** de un cambio de contexto, podemos ir reduciendo gradualmente los ciclos del quantum de hasta que ningun proceso pueda ejecutarse. Esto lo hacemos ya que en la finalizacion de cada time slice se realiza un cambio de contexto, por lo que buscamos apretar el tiempo lo suficiente como para que unicamente se haga un cambio de contexto y asi poder medir su tiempo.
En general cambia en relacion al respectivo hardware pero serian aproximadamente un poco menos de **1000 ciclos**.

--- 

#### 4- El cambio de contexto consume tiempo de un Quantum?

Si, ya que el Quantum esta establecido de **forma global**, lo que quiere decir que el Quantum se rige para todo el Sistema Operativo y no es particular de cada proceso. Por lo mismo, cualquier operacion que se realice en el SO consumira tiempo de Quantum y por lo tanto, el cambio de contexto tambien.

---
#### 5- Hay alguna forma de que a un proceso se le asigne menos tiempo?
Como el quantum se realiza de **forma global**, puede suceder que un proceso termine de ejecutarse antes de que la interrupcion suceda, por lo que al proximo proceso, se le asignaria el tiempo restante hasta que se concrete la interrupcion.

---

#### 6- ¿Cúales son los estados en los que un proceso pueden permanecer en xv6 riscv y que los hace cambiar de estado?

**UNUSED** :
- Se le asigna a un proceso al ser inicializado (procinit).
- Se le asigna a un proceso al ser liberado (freeproc).

**USED** :
- Se le asigna a un proceso cuando encontramos uno sin usar y le reservamos memoria (allocproc).

**SLEEPING** :
- Se le asigna a un proceso cuando queremos bloquear sus funciones (sleep).

**RUNNABLE** :
- Se le asigna a un proceso cuando se inicializa uno de usuario (userinit).
- Se le asigna a un proceso cuando lo dejamos listo para que el planificador decida cuando ejecutarlo (yield).
- Se le asigna a un proceso cuando desbloqueamos su funcionamiento posterior a un sleep (wakeup)

**RUNNING** :
- Se le asigna a un proceso cuando el planificador decidio ejecutarlo (scheduler).

**ZOMBIE** :
- Se le asigna a un proceso cuando An exited process remains in the zombie state
// until its parent calls wait().

---

## Segunda Parte:
### Introduccion:

Lo mas complejo de esta parte fue la implementacion de la syscall pstat la cual fue llevada a cabo empleando 3 campos agregados por nosotros en la estructura del proceso.

- **p->priority** : Indica la prioridad de ejecucion de un proceso, como estamos trabajando en RR, no es algo necesario ya que todos poseen exactamente la misma.

- **p->contador** : Indica la cantidad de veces que el proceso fue elejido por el planificador  (incrementado dentro del scheduler antes de que el estado del proceso sea asignado a running).

- **p->lst**: 
  Indica la ultima vez que fue ejecutado el proceso (implementado, antes de que el estado del proceso sea asignado a running en scheduler) utilizando la variable ticks que cuenta la cantidad de veces que se realizo una interrupcion hasta el momento de su llamado. vamos actualizando el campo hasta que el planificador llame por ultima vez al proc.

```c
uint64 
sys_pstat()
{
  int pid;
  argint(0, &pid);
  
  struct proc *p = myproc();
  acquire(&p->lock);
  printf("Priority of process: %d \n",p->priority);
  printf("Number of times run: %d \n",p->contador);
  printf ("Last time executed: %d \n",p->lst);
  release(&p->lock);
return 1;
}
```

### Punto 1:
- #### Caso 1: Solo un iobench:
  ![Caso 1](./Tablas_Experimentos/caso1.jpeg)

  **Descripcion del escenario:**

- #### Caso 2: Solo un cpubench:
  ![Caso 2](./Tablas_Experimentos/caso2.jpeg)

  **Descripcion del escenario:**
- #### Caso 3: 1 iobench; 1 cpubench:
  ![Caso 3](./Tablas_Experimentos/caso3.jpeg)

  **Descripcion del escenario:**
- #### Caso 4: 2 cpubench:
  ![Caso 4](./Tablas_Experimentos/caso4.jpeg)

  **Descripcion del escenario:**
- #### Caso 5: 2 cpubench 1 iobench:
  ![Caso 5](./Tablas_Experimentos/caso5.jpeg)

  **Descripcion del escenario:**
---

### Punto 2: Repetir el experimento para Quantums 10 veces mas cortos:
- #### Caso 1: Solo un iobench:
  ![Caso 1](./Tablas_Experimentos/caso1_10.jpeg)

  **Descripcion del escenario:**

- #### Caso 2: Solo un cpubench:
  ![Caso 2](./Tablas_Experimentos/caso2_10.jpeg)

  **Descripcion del escenario:**
- #### Caso 3: 1 cpubench; 1 iobench :
  ![Caso 3](./Tablas_Experimentos/caso3_10.jpeg)

  **Descripcion del escenario:**
- #### Caso 4: 2 cpubench:
  ![Caso 4](./Tablas_Experimentos/caso4_10.jpeg)

  **Descripcion del escenario:**
- #### Caso 5: 2 cpubench 1 iobench:
  ![Caso 5](./Tablas_Experimentos/caso5_10.jpeg)

  **Descripcion del escenario:**

---

## Tercera Parte:

### Implementacion de las reglas MLFQ:

- **Para la R3** : Lo primero que vimos fue _donde_ se inicializa un proceso de usuario dentro de XV6.
Buscando dimos con que la funcion **_userinit_** toma un proceso y realiza todas aquellas operaciones necesarias para que el proceso este listo para ejecutarse, dentro de esas operaciones notamos que en **_allocproc_** cuando un proc no esta en uso, va a una guarda que se encarga de setear todos aquellos campos necesarios para la inicializacion del mismo, por lo tanto fue alli donde nosotros agregamos lo siguiente: 
  
  ```c
  found:
    p->pid = allocpid();
    p->state = USED;
    p->priority = NPRIO-1;
    p->contador = 0;
    p->lst = 0;
  ```
- Para la R4, al aprender del anterior laboratorio que la syscall sleep bloquea el proceso, nos dirijimos a ella y agregamos lo siguiente:
  ```c
  if (p->priority < NPRIO-1){
    p->priority++;
  }
  // Go to sleep.
  p->chan = chan;
  p->state = SLEEPING;
  ```

Tan solo realizando estas modificaciones el rastreo de prioridad de los procesos fue exitoso.

## Cuarta Parte: