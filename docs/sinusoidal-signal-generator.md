# discrete time sinusoidal signal generator

Lo strumento non prevede la generazione di form d'onda sinusoidali, ma permette di generare segnali in corrente e tensione passando una lista di set-point da programamre sulla sorgente di corrente/tensione.

```lua
smu.source.sweeplist("CurrentListSweep", 1,delay,repetition)
```

il parametro delay permette di impostare il ritardo tra i set point. Se la lista dei valori contiene i campioni di un segnale tempo discreto campionato a periodo Tc, impostando un delay pari a Tc dovrebbe essere possibile riprodurre il segnale originale.

Affinchè il segnale generato sia almeno approssimativamente sinusoidale devono essere vericate le seguenti condizioni:

- l'intervallo tra i campioni è molto minore dell'periodo del segnale sinusoidale
- la banda passante del generatore di corrente deve essere molto maggiore della frequenza del segnale sinusoidale

## Generazione del segnale a bordo dello strumento

La libreria delle funzoni matematiche dell'interprete del linguaggio di scriptting LUA include la funzione math.sin()

Per questo progetto sono stati sviluppate due diversi generatori di segnali sinusolidali:

-- Generate sine wave
-- A is the amplitude of the sine wave.
-- b is the signal bias
-- po is the offset (phase shift) of the signal.
-- sampleTime: Specify the sample period in seconds 
-- reference: https://it.mathworks.com/help/simulink/slref/sinewavefunction.html

```LUA
function generateSinusoidalSignal(sampleTime,signalFrequency,A,po,b)
	print(string.format("signal frequency %g",signalFrequency))
	local signalPeriod = 1/signalFrequency
	local p= math.floor(signalPeriod/sampleTime) -- p is the number of time samples per sine wave period
 
	local signal = {}    -- new array
	for k=0,p-1 do 
		--k is a repeating integer value that ranges from 0 to p-1
		-- y=Asin(2pi(k+o)/p)+b
		signal[k]=A*math.sin(2*math.pi*(k+po)/p)+b
	end
	return signal
end

function generateSinusoidalSignalSampleBased(sampleTime,signalFrequency,N,A,po,b)
	print(string.format("signal frequency %g",signalFrequency))
	local signal = {}    -- new array
	for k=0,N-1 do 
		signal[k]=A*math.sin(2*math.pi*k*sampleTime+po)+b
	end
	return signal
end
```

## Measure voltage whil sourcing sinusoidal current signal on 10K Resistive load. Samplig interval 10ms

Utilizzando i campioni generati e la funzione sweeplist è possibile utilizare lo strumento come sorgente di segnali sinusoidali.

```
local sampleTime = 0.1 -- output signal sampling period [s]
local A = 1e-3 -- current signal amplitude [A]
local po=0 -- phase offset
local b = 0 -- DC bias
```

Di seguito i risultati di una misura eseguita con `dealy == 0.01s e nplc = 0.01` su carico resistivo da 10Kohm durante l'esecuzzione di uno sweep in corrente sui valori di un segnale sinusoidale campionato.

![current sweep test - source](../media/current_sweep_test_10K_load_source_current.svg)

![current sweep test - measured voltage](../media/current_sweep_test_10K_load_measured_voltage.svg)

I dati acquisiti sono nel file [sweep test R10K load](../data/sweep_test_R10K_load.csv)

```csv

                          timestamp       current   voltage
0     02/07/2021 18:53:28.161005260  1.253410e-04  1.499570
1     02/07/2021 18:53:28.173474380  1.874520e-04  2.239640
2     02/07/2021 18:53:28.185904860  2.487170e-04  2.972470
3     02/07/2021 18:53:28.198331920  3.090590e-04  3.692990
4     02/07/2021 18:53:28.210758080  3.681550e-04  4.398110
...                             ...           ...       ...
1994  02/07/2021 18:54:10.897382020 -2.487020e-04 -2.969940
1995  02/07/2021 18:54:10.909798880 -1.873780e-04 -2.238570
1996  02/07/2021 18:54:10.922236400 -1.253170e-04 -1.497440
1997  02/07/2021 18:54:11.012413320 -6.279020e-05 -0.750214
1998  02/07/2021 18:54:11.251590480 -1.534770e-12  0.000114

[1999 rows x 3 columns]
```
