; programa.asm — Laboratorio Post1 Unidad 4
; Asignatura: Arquitectura de Computadores
; Formato: COM de DOS (un solo segmento, offset 0x100)
;
; COMPILACIÓN:  nasm -f bin programa.asm -o programa.com
; EJECUCIÓN:    programa.com  (dentro de DOSBox)

; ===========================================================================
; CONSTANTES (EQU — no reservan memoria)
; ===========================================================================

CR          EQU 0Dh
LF          EQU 0Ah
TERMINADOR  EQU 24h
ITERACIONES EQU 5

; ===========================================================================
; CONFIGURACIÓN FORMATO COM
; ===========================================================================

bits 16
org  0x100

; ===========================================================================
; CÓDIGO
; ===========================================================================

main:
    ; En formato COM, DS ya apunta correctamente al segmento

    ; ── Bienvenida ────────────────────────────────────────────────────────
    mov  ah, 09h
    mov  dx, bienvenida
    int  21h

    ; ── Separador ─────────────────────────────────────────────────────────
    mov  ah, 09h
    mov  dx, separador
    int  21h

    ; ── Variable A: imprimir etiqueta + valor de var_byte (42) ────────────
    mov  ah, 09h
    mov  dx, etiqueta_a
    int  21h

    ; Imprimir 42 como "42": dividir entre 10 → decena=4, unidad=2
    mov  al, [var_byte]     ; AL = 42
    mov  ah, 0              ; limpiar AH para división
    mov  bl, 10
    div  bl                 ; AL = cociente (decenas), AH = resto (unidades)
    mov  bh, ah             ; guardar unidades en BH

    add  al, 30h            ; decena → ASCII
    mov  ah, 02h
    mov  dl, al
    int  21h

    add  bh, 30h            ; unidad → ASCII
    mov  ah, 02h
    mov  dl, bh
    int  21h

    ; Nueva línea
    mov  ah, 02h
    mov  dl, CR
    int  21h
    mov  ah, 02h
    mov  dl, LF
    int  21h

    ; ── Tabla de bytes ────────────────────────────────────────────────────
    mov  ah, 09h
    mov  dx, msg_tabla
    int  21h

    mov  si, tabla_bytes
    mov  cx, ITERACIONES

imprimir_tabla:
    mov  al, [si]           ; AL = valor actual (10, 20, 30, 40, 50)
    mov  ah, 0
    mov  bl, 10
    div  bl                 ; AL = decenas, AH = unidades

    ; imprimir decena
    add  al, 30h
    mov  bh, ah             ; guardar unidades
    mov  ah, 02h
    mov  dl, al
    int  21h

    ; imprimir unidad
    add  bh, 30h
    mov  ah, 02h
    mov  dl, bh
    int  21h

    ; imprimir espacio
    mov  ah, 02h
    mov  dl, 20h
    int  21h

    inc  si
    loop imprimir_tabla

    ; Nueva línea
    mov  ah, 02h
    mov  dl, CR
    int  21h
    mov  ah, 02h
    mov  dl, LF
    int  21h

    ; ── Variable B: imprimir etiqueta + valor de var_word (0x1234 = 4660) ─
    mov  ah, 09h
    mov  dx, etiqueta_b
    int  21h

    ; Imprimir 4660 dividiendo sucesivamente entre 10
    ; Usamos la pila para invertir el orden de los dígitos
    mov  ax, [var_word]     ; AX = 4660
    mov  cx, 0              ; contador de dígitos

extraer_digitos:
    mov  dx, 0
    mov  bx, 10
    div  bx                 ; AX = cociente, DX = resto (dígito)
    add  dl, 30h            ; dígito → ASCII
    push dx                 ; apilar dígito
    inc  cx
    cmp  ax, 0
    jne  extraer_digitos    ; repetir hasta que cociente = 0

imprimir_digitos:
    pop  dx                 ; sacar dígito en orden correcto
    mov  ah, 02h
    int  21h
    loop imprimir_digitos

    ; Nueva línea
    mov  ah, 02h
    mov  dl, CR
    int  21h
    mov  ah, 02h
    mov  dl, LF
    int  21h

    ; ── Mensaje de finalización ───────────────────────────────────────────
    mov  ah, 09h
    mov  dx, fin_msg
    int  21h

    ; ── Terminar programa ─────────────────────────────────────────────────
    mov  ax, 4C00h
    int  21h

; ===========================================================================
; DATOS
; ===========================================================================

bienvenida  db "=== Laboratorio NASM - Unidad 4 ===", CR, LF, TERMINADOR
separador   db "----------------------------------------", CR, LF, TERMINADOR
etiqueta_a  db "Variable A (byte=42):  ", TERMINADOR
etiqueta_b  db "Variable B (word=4660): ", TERMINADOR
msg_tabla   db "Tabla de bytes: ", TERMINADOR
fin_msg     db "Programa finalizado correctamente.", CR, LF, TERMINADOR

; Directivas de datos: DB, DW, DD
var_byte    db  42                   ; 1 byte  — decimal 42
var_word    dw  1234h                ; 2 bytes — 0x1234 = 4660 decimal
var_dword   dd  0DEADBEEFh          ; 4 bytes — 0xDEADBEEF
tabla_bytes db  10, 20, 30, 40, 50  ; 5 bytes consecutivos

; Espacio reservado (equivalente a .bss en formato COM)
buffer      times 80 db 0           ; 80 bytes en cero — equivalente a resb 80
resultado   dw  0                   ; 1 word en cero  — equivalente a resw 1