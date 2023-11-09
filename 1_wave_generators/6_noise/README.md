[Назад в оглавление](../../README.md)

# Генератор псевдослучайного шума
Генератор псевдослучайного шума находится в папке `audio_synth_practice/1_wave_generators/6_noise`.

Чтобы запустить тестбенч, выполните в консоли Modelsim:
```
cd audio_synth_practice/1_wave_generators/6_noise
do make.do
```

Генератор псевдослучайного шума построен по принципу сдвигового регистра с линейной обратной связью.
Алгоритм его работы можно описать следующим листингом на языке Си:

```c
/* Test a bit. Returns 1 if bit is set. */
long bit(long val, byte bitnr) {
  return (val & (1<<bitnr))? 1:0;
}


/* Generate output from noise-waveform */
void Noisewaveform {
  long bit22;	/* Temp. to keep bit 22 */
  long bit17;	/* Temp. to keep bit 17 */

  long reg= 0x7ffff8; /* Initial value of internal register*/

  /* Repeat forever */
  for (;;;) {

    /* Pick out bits to make output value */
    output = (bit(reg,22) << 7) |
	     (bit(reg,20) << 6) |
	     (bit(reg,16) << 5) |
	     (bit(reg,13) << 4) |
	     (bit(reg,11) << 3) |
	     (bit(reg, 7) << 2) |
	     (bit(reg, 4) << 1) |
	     (bit(reg, 2) << 0);

    /* Save bits used to feed bit 0 */
    bit22= bit(reg,22);
    bit17= bit(reg,17);

    /* Shift 1 bit left */
    reg= reg << 1;

    /(* Feed bit 0 */
    reg= reg | (bit22 ^ bit17);
  };
};
```

> Интересный факт заключается в том, что представленный генератор шума является полной копией генератора шума из микросхемы SID, структура генератора была получена в результате реверс-инжиниринга (http://www.sidmusic.org/sid/sidtech5.html).

Также стоит отметить неочевидный момент: выдаваемый генератором шума звук меняется при изменении частоты `freq_i`, так как меняется спектр шума.
