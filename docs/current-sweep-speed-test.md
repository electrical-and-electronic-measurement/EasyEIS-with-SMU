# Current Sweep Speed Test

Esecuzione di un source current sweep per verificare la velocità dello strumento nel produrre la forma d'onda richiesta e nell'eseguire la misura

```lua
-- -------------------------------------
-- SOURCE SETTIGNS

smu.source.func = smu.FUNC_DC_CURRENT
smu.source.range = 100e-3
smu.source.vlimit.level = 20

-- setting for maximum speed 
smu.source.delay=sourceDelay
smu.source.readback = smu.OFF

-- -------------------------------
-- Measure setting

smu.measure.func = smu.FUNC_DC_VOLTAGE
smu.measure.sense=smu.SENSE_4WIRE
smu.measure.range = 10

-- settings for maximum speed
smu.measure.nplc = nplc
smu.measure.autozero.enable = smu.OFF
smu.measure.autozero.once()


smu.source.sweeplog("RES", 100e-6, 10e-3, 10, delay, 1, smu.RANGE_BEST, smu.OFF)
trigger.model.initiate()
waitcomplete()
```

## Configurazione per massima velocità

Lo strumento mette a disposizione diversi parametri per sceglire il compromesso desiderato tra la precisione della msiurazione e la velocità meòò'esecuzione delle mesure. In questo esperimento si è cercato di spingere al massimo la velocità agendo sui seguenti parametri di configurazione:

- smu.source.delay
- smu.source.readback = smu.OFF
- smu.measure.nplc
- smu.measure.autozero

L'esperimento è stato ripetuto con diverse combinazioni dei parametri `nplc e delay` utilizzando un carico puramente resistivo ed un carico costituito da un parallelo RC.

## Risultati

Di seguit0 un sintesi dei rusltati degli eseprimenti eseguiti. I dati sono disponibili due della cartella current speed test]

- [carico resistivo 10Kohm](../current-sweep-speed-test/current_sweep_test_R10K_LOAD.txt) 
- [carico RC](../current-sweep-speed-test/current_sweep_test_R10K_LOAD.txt)

### Delay 1s - 0.1 s

Programmando lo sweep con un delay di 1s e di 0.1s lo strumento riesce ad eseguire le misure rischieste con un timing sostanzialmente preciso, rispettando l'intervallo di campionamento.

![sweep test - delay 1s - 0.1s](../media/currrent_sweep_test_100ms.png)

Riducendo il ritardo a 10ms (0.01s) i timing delle misure è preciso fino alle seconda cifra decimale, ma si notano delle irregolarità enll'intervallo sulla terza cifra decimale

![sweep test - delay 10ms](../media/currrent_sweep_test_10ms.png)

I limiti di precisone a livello risultano evidenti riducendo il ritardo a 1ms (0.001s): l'intervallo tra due diverse misure è sempre superiore a 1ms

![sweep test - dealy 1ms](../media/currrent_sweep_test_1ms.png)

Per cercare indagare sulla possibilità di spingere al massimo le velocità a discapito della precisione sono stati condotti altri espeimenti modificanado anche il parametro `nplc` rispetto al valore di default `nplc=1`

![sweep test - delay 1ms NPLC](../media/currrent_sweep_test_1ms._npcl.png)

Putroppo neppure impostando il valore minimo consentito `nplc=0.01` si riesce ad ottenre un intervallo campionamento costante di 1ms
![sweep test deplay 1ms NPLC](../media/currrent_sweep_test_1ms._npcl_RC_load.png)

Il limite inferiore di circa 1-2 mS per l'intervallo tra le diverse misurazioni eseguite nel source sweep è coerente con quanto riportato nel manuale di riverimento al paragrafo "source dealy" (pag. 4-46)

![about source delay on reference manual](./media/../../media/manual4-46_source_delay.png)

### Conclusioni

La massima velocità di esecuzione delle misure può essere ottentuta solo rinuncianto a parte della precisione.

L'intervallo tra le misure eseguite determina la frequenza massima che è possibile analizzare per la EIS. Perp poter eseguire correttamente l'analisi spettrale devono essere soddisfatti due requisiti:

- l'intervallo tra le diverse misure (intervallo di capionamenot) deve essere costante
- il valore della corrente deve essere quello reale (misurato) e non quello teorico programmato sulla sorgente di corrente
  
Questi due requisiti determinano il limite inferiore per il parametro "source delay" che è possible ottimizzare.

Un altro fattore da tenere in considerazione è la precisione numerica richiesta dalla misura. L'intervallo tra le misure è infatti inversamente proporzioanle al parametro  `NPLC`

NPLC Set the amount of time that the input signal is measured. Lower NPLC settings result
in faster reading rates, but increased noise. Higher NPLC settings result in lower
reading noise, but slower reading rates.

The amount of time is specified in parameters that are based on the number of power line cycles
(NPLCs). Each power line cycle for 60 Hz is 16.67 ms (1/60); for 50 Hz, it is 20 ms (1/50).
The shortest amount of time results in the fastest reading rate, but increases the reading noise and
decreases the number of usable digits.
The longest amount of time provides the lowest reading noise and more usable digits, but has the
slowest reading rate.
Settings between the fastest and slowest number of power line cycles are a compromise between
speed and noise.

'analis spettrale è necessario che il tempo di 

Per l'esecuzione di una EIS è necessario avere una misura relae della conrrente in ingresso e
è stato possibile generare un segnale in corrente e misurare la tensione ai capi del DUT in maniiera accurata solo per intervalli di campionamento a partire 10ms.
Lo strumento non riesce ad eseguire misure con intervallo inferiore a qualche ms.
