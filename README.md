# **Laboratorio 1 de la Unidad 4 — Arquitectura de Computadores**
## Unidad 4 — Lenguaje Ensamblador| Ingeniería de Sistemas 
### Asignatura — Arquitectura de Computadores
**Estudiante:** Andrea Valentina Rivera Fernandez  
**Codigo Estudiante:** 1152444  
**Repositorio:** rivera-post1-u4

## Descripción
Este laboratorio implementa un programa funcional en lenguaje ensamblador **NASM** para entorno **DOS de 16 bits**. El programa demuestra el uso de directivas de sección y datos (`DB`, `DW`, `DD`, `EQU`, `TIMES`), el manejo de registros de segmento y la producción de salida en pantalla mediante las interrupciones DOS `INT 21h` (funciones `09h` y `02h`). La ejecución se verifica mediante **DOSBox**.

## Prerrequisitos

* **DOSBox 0.74 o superior**: Emulador de entorno DOS de 16 bits. [Descarga aquí](https://www.dosbox.com).
* **NASM (Netwide Assembler) 2.14 o superior**: El ejecutable `nasm.exe` (Windows) o `nasm` (macOS/Linux) debe estar disponible en la carpeta de trabajo o en el PATH del sistema.
* **Editor de texto plano**: VS Code, Notepad++ o similar. El archivo fuente `.asm` debe guardarse con codificación **ASCII sin BOM**.

> [!IMPORTANT]
> **Nota sobre el enlazador (macOS):** > La actividad especifica el uso de **ALINK** como enlazador para generar archivos `.exe`. Sin embargo, ALINK no está disponible para macOS (el binario requiere Win32).  
> Como solución equivalente, se utilizó el **formato COM de DOS**. Con este formato, NASM actúa como ensamblador y enlazador simultáneamente mediante el flag `-f bin`, generando el binario ejecutable directamente. DOSBox ejecuta archivos `.com` de forma nativa con idéntico resultado.

## Estructura del repositorio

```text
rivera-post1-u4/
├── programa.asm       # Código fuente NASM (formato COM, 16 bits)
├── programa.com       # Binario generado (resultado de la compilación)
├── README.md          # Este documento
└── capturas/
    ├── captura1_compilacion.png   # Compilación exitosa en DOSBox
    └── captura2_ejecucion.png     # Salida del programa en DOSBox

```

## Compilación y ejecución

### Dentro de DOSBox

**Paso 1 — Montar la carpeta de trabajo:**
Z:> mount C ~/doswork/LAB4P01
Z:> C:
C:>

**Paso 2 — Compilar (un solo comando, sin enlazador):**
C:> nasm -f bin programa.asm -o programa.com
El flag `-f bin` le indica a NASM que genere un binario plano listo para ejecutar,  
equivalente al proceso ensamblado + enlazado del flujo EXE con ALINK.

**Paso 3 — Ejecutar:**
C:> programa.com

---

### Salida esperada en pantalla
=== Laboratorio NASM - Unidad 4 ===

Variable A (byte=42): 42
Tabla de bytes: 10 20 30 40 50
Variable B (word=4660): 4660
Programa finalizado correctamente.

---

## Descripción del programa

El archivo `programa.asm` está organizado en tres bloques lógicos que simulan  
las secciones `.data`, `.bss` y `.text` del modelo de segmentación x86,  
adaptadas al formato COM de NASM.

### Constantes (EQU)

Se definen cuatro constantes que no reservan espacio en memoria:
- `CR` — Carriage Return (`0Dh`)
- `LF` — Line Feed (`0Ah`)
- `TERMINADOR` — carácter `$` (`24h`) requerido por la función `09h` de `INT 21h`
- `ITERACIONES` — número de elementos de la tabla (`5`), usado como contador del bucle

### Datos inicializados (equivalente a .data)
Se declaran con las siguientes directivas:
- `DB` — cadenas de texto y valor de 1 byte (`var_byte = 42`)
- `DW` — valor de 2 bytes (`var_word = 1234h = 4660 decimal`)
- `DD` — valor de 4 bytes (`var_dword = 0DEADBEEFh`)
- `DB` con múltiples valores — tabla de 5 bytes consecutivos (`10, 20, 30, 40, 50`)

### Datos no inicializados (equivalente a .bss)
En formato COM no existe sección `.bss` separada. Se declaran con ceros usando `TIMES`:
- `buffer` — `times 80 db 0` (80 bytes reservados para entrada futura)
- `resultado` — `dw 0` (1 word reservado para cálculo futuro)

### Código (equivalente a .text)

El punto de entrada `main` implementa:
- Salida de cadenas con `INT 21h` / función `09h`: imprime mensajes de bienvenida, separador y etiquetas  
- Salida de carácter individual con `INT 21h` / función `02h`: imprime cada dígito convertido a ASCII  
- Conversión numérica: los valores se dividen entre 10 para extraer decenas y unidades por separado  
- Bucle con `LOOP` y registro `SI`: recorre `tabla_bytes` incrementando `SI` y usando `CX` como contador  
- Uso de la pila: para imprimir `var_word (4660)` los dígitos se apilan en orden inverso y se recuperan con `POP`  
- Terminación limpia con `INT 21h` / función `4Ch` (código de salida `00h`)

---

## Adaptaciones respecto a la guía original (macOS)

| Aspecto | Especificado en la guía | Implementado en macOS |
|----------|-------------------------|-----------------------|
| Formato de salida | `.exe` (formato EXE de DOS) | `.com` (formato COM de DOS) |
| Enlazador | ALINK (`alink.exe`) | No requerido con `-f bin` |
| Comando de compilación | `nasm -f obj + alink` | `nasm -f bin` (un solo paso) |
| Segmentos | `segment data/bss/code` con `@data` | Todo en un bloque con `org 0x100` |
| Inicialización de DS | `mov ax, @data / mov ds, ax` | No necesaria (COM inicializa DS automáticamente) |
| Datos no inicializados | `resb / resw` | `times N db 0 / dw 0` |

El comportamiento en tiempo de ejecución dentro de DOSBox es idéntico en ambos formatos.

---

## Checkpoints verificados

✅ **Checkpoint 1** — El programa compila sin errores con  
`nasm -f bin programa.asm -o programa.com`  

✅ **Checkpoint 2** — El ejecutable `programa.com` corre en DOSBox y produce la salida esperada  

✅ **Checkpoint 3** — Repositorio con código fuente, README, capturas y mínimo 3 commits descriptivos  

---

## Historial de commits

```bash
git commit -m "Agregar README con descripcion del laboratorio y prerrequisitos"
git commit -m "Implementar programa base con directivas DB, DW, DD, EQU y bucle"
git commit -m "Agregar salida numerica correcta con division y uso de pila para var_word"
git push origin main
```

---

## Referencias

- [NASM Manual](https://www.nasm.us/doc/)
- [DOSBox](https://www.dosbox.com)
- [INT 21h DOS interrupts](https://stanislavs.org/helppc/int_21.html)
- Guía de laboratorio: *Arquitectura de Computadores — Unidad 4, Post-Contenido 1 — UFPS 2026*
