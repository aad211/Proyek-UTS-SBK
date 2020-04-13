;----------------------------------------------------------------------------------------------------------------------------------------;
;@2020                                                                                                                                   ;
;AUTHOR     :   - MUHAMMAD AS'AD MUYASSIR   <TEKNIK KOMPUTER - 1806199953 - 1B>                                                          ;
;               - ADITYA GHALIB HENDRYAN    <TEKNIK KOMPUTER - 1806148630 - 1B>                                                          ;
;               - ARVALINNO                 <TEKNIK KOMPUTER - 1806200160 - 1B>                                                          ;
;               - BRYAN DARIO LESMANA       <TEKNIK KOMPUTER - 1806199940 - 1B>                                                          ;
;KELOMPOK   :   1B                                                                                                                       ;
;TEMA       :   GAME ANTI CORONA                                                                                                         ;
;----------------------------------------------------------------------------------------------------------------------------------------;
;SKENARIO   :   1. USER MENUNGGU LOADING DAN MELIHAT JUDUL                                                                               ;
;               2. USER MEMASUKKAN INPUT 'ESC' UNTUK KELUAR GAME ATAU INPUT TOMBOL LAIN UNTUK MEMULAI GAME                               ;
;               3. SAAT GAME PERTAMA DIJALANKAN USER BERADA PADA LEVEL 1                                                                 ;
;               4. USER BERMAIN DENGAN MENGGUNAKAN ARROW UNTUK MENGGERAKKAN KARAKTER                                                     ;
;               5. USER HARUS MEMPERTAHANKAN KARAKTER TETAP DI DALAM RUMAH HINGGA WAKTU TERTENTU                                         ;
;               6. USER AKAN NAIK LEVEL JIKA BERHASIL MEMPERTAHANKAN KARAKTER                                                            ;
;               7. USER DAPAT MENEKAN TOMBOL 'ESC' SAAT SEDANG BERMAIN UNTUK KELUAR DARI GAME                                            ;
;               8. JIKA USER GAGAL, MAKA TERDAPAT MENU PILIHAN UNTUK MENGULANG LEVEL TERSEBUT ATAU KELUAR DARI GAME                      ;
;               9. JIKA USER BERHASIL MENYELESAIKAN SEMUA LEVEL, USER AKAN DIBERI MENU PILIHAN UNTUK BERMAIN ULANG ATAU KELUAR DARI GAME ;
;----------------------------------------------------------------------------------------------------------------------------------------;
;       ANTI CORONA is a classic game implementation which objective is to maintain the player to stay at home and contains several      ;
;       challenges for each level.                                                                                                       ;
;                                                                                                                                        ;
;        Copyright <C> 2020 M. As'ad Muyassir, Aditya Ghalib Hendryan, Arvalinno, Bryan Dario Lesmana                                    ;
;                                                                                                                                        ;
;           This program is free software; you can redistribute it and/or modify                                                         ;
;           it under the terms of the GNU General Public License as published by                                                         ;
;           the Free Software Foundation; either version 3 of the License, or                                                            ;
;           <at your option> any later version.                                                                                          ;
;                                                                                                                                        ;
;           This program is distributed in the hope that it will be useful,                                                              ;
;           but WITHOUT ANY WARRANTY; without even the implied warranty of                                                               ;
;           MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the                                                                 ;
;           GNU General Public License for more details.                                                                                 ;
;                                                                                                                                        ;
;----------------------------------------------------------------------------------------------------------------------------------------;
;REFERENCE  :   1. spike.scu.edu.au/~barry/interrupts.html                                                                               ;
;               2. stanislavs.org/helppc/int_10.html                                                                                     ;
;               3. www.dragonwins.com/domains/getteched/bmp/bmpfileformat.htm                                                            ;
;               4. www.techhelpmanual.com/85-vesa_svga_video_modes.html                                                                  ;
;               5. github.com/oded8bit/Assembly-Lib/blob/master/GrLib/bmp.asm                                                            ;
;----------------------------------------------------------------------------------------------------------------------------------------;

.MODEL SMALL

.DATA
    TULISANC    DB 09,"COUNTER :     AYO JAGA SAMPAI WAKTUNYA SELESAI!"
    PANJANG_TC equ $-TULISANC
    TULISAN_ARAH    DB 09,"KONTROL : ARROW KIRI UNTUK MENGARAHKAN KE KIRI, ARROW KANAN UNTUK MENGARAHKAN KE KANAN", 13,10
                    DB 09,"KEY HARUS DITEKAN BERKALI-KALI, TIDAK DENGAN CARA DITAHAN", 13,10
                    DB 09,"SILAHKAN TEKAN TOMBOL 'ESC' UNTUK KELUAR DARI GAME", 13,10
                    DB 09,"LEVEL 1 : 17 DETIK"
                    DB 09,"LEVEL 2 : 16 DETIK"
                    DB 09,"LEVEL 3 : 31 DETIK"
                    DB 09,"LEVEL 4 : 31 DETIK"
    PANJANG_ARAH equ $-TULISAN_ARAH
    COUNTER DW 0
    REALC   DW 0
    WAKTU   DW 0
    MENANG  DB 0
    ORANG   DB "////^\\\\", 10,08,08,08,08,08,08,08,08,08
            DB "| ^   ^ |", 10,08,08,08,08,08,08,08,08,08,08
            DB "@ (o) (o) @", 10,08,08,08,08,08,08,08,08,08,08
            DB "|   <   |", 10,08,08,08,08,08,08,08,08,08
            DB "|  ___  |", 10,08,08,08,08,08,08,08,08
            DB "\_____/", 10,08,08,08,08,08,08,08,08,08
            DB "____|  |___", 10,08,08,08,08,08,08,08,08,08,08,08,08,08
            DB "/    \__/    \", 10,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08
            DB "/              \", 10,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08
            DB "/\_/|        |\_/\", 10,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08
            DB "/ /  |        |  \ \", 10,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08
            DB "( <   |        |   > )", 10,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08
            DB "\ \  |        |  / /", 10,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08
            DB "\ \ |________| / /"
    PANJANG equ $-ORANG
                
    X_ORANG DB 35H
    Y_ORANG DB 1CH
    
    RUMAH   DB "               ____________________________________________________________________________________ ", 13, 10
            DB "              //\\                                                                              //\\", 13, 10
            DB "             //  \\                                                                            //  \\", 13, 10
            DB "            //    \\                                                                          //    \\", 13, 10
            DB "           //      \\                                                                        //      \\", 13, 10
            DB "          //        \\                                                                      //        \\", 13, 10
            DB "         //__________\\____________________________________________________________________//__________\\", 13, 10
            DB "        ||           ||                                                                    ||           ||", 13, 10
            DB "        ||           ||                                                                    ||           ||", 13, 10
            DB "        ||           ||                                                                    ||           ||", 13, 10
            DB "        ||           ||                                                                    ||           ||", 13, 10
            DB "        ||           ||                                                                    ||           ||", 13, 10
            DB "        ||           ||                                                                    ||           ||", 13, 10
            DB "        ||           ||                                                                    ||           ||", 13, 10
            DB "        ||           ||                                                                    ||           ||", 13, 10
            DB "        ||           ||                                                                    ||           ||", 13, 10
            DB "        ||           ||                                                                    ||           ||", 13, 10
            DB "        ||           ||                                                                    ||           ||", 13, 10
            DB "        ||           ||                                                                    ||           ||", 13, 10
            DB "        ||           ||                                                                    ||           ||", 13, 10
            DB "        ||           ||                                                                    ||           ||", 13, 10
            DB "        ||           ||                                                                    ||           ||", 13, 10
            DB "        ||           ||                                                                    ||           ||", 13, 10
            DB "        ||           ||                                                                    ||           ||", 13, 10
            DB "        ||           ||                                                                    ||           ||", 13, 10
            DB "        ||           ||                                                                    ||           ||", 13, 10
            DB "        ||           ||                                                                    ||           ||", 13, 10
            DB "        ||           ||                                                                    ||           ||", 13, 10
            DB "        ||           ||                                                                    ||           ||", 13, 10
            DB "        ||           ||                                                                    ||           ||", 13, 10
            DB "        ||           ||                                                                    ||           ||", 13, 10
            DB "        ||           ||                                                                    ||           ||", 13, 10
            DB "        ||           ||                                                                    ||           ||", 13, 10
            DB "        ||           ||                                                                    ||           ||", 13, 10
            DB "        ||           ||                                                                    ||           ||", 13, 10
            DB "        ||           ||                                                                    ||           ||", 13, 10
            DB "        ||           ||                                                                    ||           ||", 13, 10
            DB "        ||           ||                                                                    ||           ||", 13, 10
            DB "        ||           ||                                                                    ||           ||", 13, 10
            DB "        ||___________||____________________________________________________________________||___________||"
    PANJANGR equ $-RUMAH
    
    INTRO   DB "  _|_|    _|      _|  _|_|_|_|_|  _|_|_|", 10,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08
            DB "_|    _|  _|_|    _|      _|        _|  ", 10,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08
            DB "_|_|_|_|  _|  _|  _|      _|        _|  ", 10,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08
            DB "_|    _|  _|    _|_|      _|        _|  ", 10,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08
            DB "_|    _|  _|      _|      _|      _|_|_|", 13,10,10,10,09,09
            
            DB "         ___            ___            ___            ___            ___            ___     ", 10,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08
            DB "    /\  \          /\  \          /\  \          /\  \          /\__\          /\  \    ", 10,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08
            DB "   /::\  \        /::\  \        /::\  \        /::\  \        /::|  |        /::\  \   ", 10,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08
            DB "  /:/\:\  \      /:/\:\  \      /:/\:\  \      /:/\:\  \      /:|:|  |       /:/\:\  \  ", 10,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08
            DB " /:/  \:\  \    /:/  \:\  \    /::\~\:\  \    /:/  \:\  \    /:/|:|  |__    /::\~\:\  \ ", 10,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08
            DB "/:/__/ \:\__\  /:/__/ \:\__\  /:/\:\ \:\__\  /:/__/ \:\__\  /:/ |:| /\__\  /:/\:\ \:\__\", 10,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08
            DB "\:\  \  \/__/  \:\  \ /:/  /  \/_|::\/:/  /  \:\  \ /:/  /  \/__|:|/:/  /  \/__\:\/:/  /", 10,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08
            DB " \:\  \         \:\  /:/  /      |:|::/  /    \:\  /:/  /       |:/:/  /        \::/  / ", 10,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08
            DB "  \:\  \         \:\/:/  /       |:|\/__/      \:\/:/  /        |::/  /         /:/  /  ", 10,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08
            DB "   \:\__\         \::/  /        |:|  |         \::/  /         /:/  /         /:/  /   ", 10,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08
            DB "    \/__/          \/__/          \|__|          \/__/          \/__/          \/__/    ", 13,10,10,10,09,09,09,09,09
            
            DB "    _|_|_|  _|        _|    _|  _|_|_|    ", 10,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08
            DB "_|        _|        _|    _|  _|    _|  ", 10,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08
            DB "_|        _|        _|    _|  _|_|_|    ", 10,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08
            DB "_|        _|        _|    _|  _|    _|  ", 10,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08,08
            DB "  _|_|_|  _|_|_|_|    _|_|    _|_|_|    ", 13,10,10,10,10,09,09,09,09,09,09,09
            
            DB "LOADING.....", 13,10
    
    PANJANG_INTRO equ $-INTRO
    
    MENU    DB 09,09,09,09,09,"      SELAMAT DATANG DI GAME ANTI CORONA!!!", 13,10,10,10,10
            DB 09,09,"DI SINI KAMI INGIN MENGAJAK ANDA UNTUK MENJAGA TEMAN DAN KELUARGA ANDA TETAP BERADA DI DALAM RUMAH", 13,10,10
            DB 09,09,09,09,09,09,09,"ENJOY THE GAME :)", 13,10,10,10,10,10
            DB 09,09,09,09,09,"(TEKAN TOMBOL APAPUN UNTUK MEMULAI PERMAINAN)", 13,10
            DB 09,09,09,09,09," (TEKAN TOMBOL 'ESC' UNTUK KELUAR DARI GAME)"
    PANJANG_MENU equ $-MENU
    
    NAIK    DB 09,09,09,09, "   SELAMAT ANDA TELAH BERHASIL MENYELESAIKAN LEVEL INI", 13,10,10,10,10
            DB 09,09,09,09,09, "ANDA BISA MELANJUTKAN KE LEVEL SELANJUTNYA", 13,10
            DB 09,09,09,09, "(TEKAN Y UNTUK MELANJUTKAN, TEKAN ESC UNTUK KELUAR GAME)"
    PANJANG_NAIK equ $-NAIK
    
    GAGAL   DB 09,09,"    YAH GIMANA NIH KAK JAGANYA, JANGAN REBAHAN MULU KAK, AYOK KITA SALING MEMBANTU", 13,10,10,10,10
            DB 09,09,09,09,09,"APAKAH ANDA INGIN MENGULANG LEVEL INI?", 13,10
            DB 09,09,09,09, "(TEKAN Y UNTUK MENGULANG, TEKAN ESC UNTUK KELUAR GAME)"
    PANJANG_GAGAL equ $-GAGAL
    
    TAMAT_SUDAH DB 09,09,09,"    SELAMAT ANDA BERHASIL MENYELAMATKAN ORANG DI SEKITAR ANDA DARI CORONA", 13,10,10
                DB 09,09,09,,09,09," KONTRIBUSI ANDA SANGAT BERARTI BAGI DUNIA INI", 13,10,10
                DB 09,09,,09,09,"SEMOGA WABAH INI BISA CEPAT SELESAI DAN KEADAAN KEMBALI NORMAL", 13,10,10
                DB 09,09,09,09,08,08,"TERIMA KASIH JIKA ANDA TELAH BERKONTRIBUSI SETIDAKNYA #DIRUMAHAJA", 13,10,10,10,10
                DB 09,09,09,09,"          APAKAH ANDA INGIN MEMAINKAN GAME INI LAGI?", 13,10
                DB 09,09,09,09,"    (TEKAN Y UNTUK MENGULANG, TEKAN ESC UNTUK KELUAR GAME)"
    PANJANG_TAMAT_SUDAH equ $-TAMAT_SUDAH
    
    level DB 0
    
.CODE

;------------------------------;
; BAGIAN UNTUK OPERAASI WINDOW ;
;------------------------------;

; setting untuk menggunakan svga
svga proc near
    ; MODE SVGA
    MOV AX, 4F02H
    ; MODE 1024x768 8BIT
    MOV BX, 0105H
    INT 10H
    
    ret
endp

; print 1 untuk print string
PRINT1 PROC NEAR
    ; MEMASUKKAN DS KE ES
    PUSH ES
    PUSH DS
    POP ES
    
    MOV AX, 1301H
    MOV BX, 0002H
    INT 10H
    
    ;MENGEMBALIKAN ES
    POP ES
        
    RET
ENDP

;---------------------------;
; BAGIAN UNTUK KONTROL GAME ;
;---------------------------;

; KONDISI AWAL MEMBUKA GAME
OPENING PROC NEAR
    LEA BP, INTRO
    MOV CX, PANJANG_INTRO
    MOV DH, 10
    MOV DL, 43
    CALL PRINT1
    
    ; DELAY 2,5 DETIK -> 2625A0H
    MOV CX, 26H
    MOV DX, 025A0H
    CALL DELAY
    
    ; PANGGIL MENU
    CALL MENU_GAME
    
    RET
ENDP

; MENAMPILKAN MENU
MENU_GAME PROC NEAR
    ; RESET LAYAR
    CALL SVGA
    ; INISIASI PRINT STRING
    LEA BP, MENU
    MOV CX, PANJANG_MENU
    MOV DH, 10
    MOV DL, 0
    CALL PRINT1
    
    ; LOOP SAMPAI USER MENEKAN TOMBOL
    CEK_LAGI:
        mov ah, 01h
        int 16h
        JZ CEK_LAGI ; 0 ITU KALO GAK DIPENCET
    RET
ENDP

; GAME LEVEL 0
LEVEL0 PROC NEAR
    ; DELAY 150.000MS -> 249F0H
    MOV CX, 02H
    MOV DX, 049F0H
    CALL DELAY
    
    ; 0,15 DETIK * 100 -> 15 DETIK
    CMP COUNTER, 100
    JNE NAIK1
        CALL NAIK_LEVEL
    NAIK1:
    
    MOV AX, COUNTER
    MOV BL, 6
    DIV BL
    CMP AH, 0
    JNE BELOM_SEDETIK
        INC REALC
    BELOM_SEDETIK:
    RET
ENDP

; GAME LEVEL 1
LEVEL1 PROC NEAR
    ; DELAY 100.000MS -> 186A0H
    MOV CX, 01H
    MOV DX, 086A0H
    CALL DELAY
    
    ; 0,10 DETIK * 150 -> 15 DETIK
    CMP COUNTER, 150
    JNE NAIK2
        CALL NAIK_LEVEL
    NAIK2:
    
    MOV AX, COUNTER
    MOV BL, 10
    DIV BL
    CMP AH, 0
    JNE BELOM_SEDETIK1
        INC REALC
    BELOM_SEDETIK1:
    
    RET
ENDP

; GAME LEVEL 2
LEVEL2 PROC NEAR
    ; DELAY 100.000MS -> 186A0H
    MOV CX, 01H
    MOV DX, 086A0H
    CALL DELAY
    
    ; 0,10 DETIK * 300 -> 30 DETIK
    CMP COUNTER, 300
    JNE NAIK3
        CALL NAIK_LEVEL
    NAIK3:
    
    MOV AX, COUNTER
    MOV BL, 10
    DIV BL
    CMP AH, 0
    JNE BELOM_SEDETIK2
        INC REALC
    BELOM_SEDETIK2:
    
    RET
ENDP

; GAME LEVEL 3
LEVEL3 PROC NEAR
    ; DELAY 75.000MS -> 124F8H
    MOV CX, 01H
    MOV DX, 024F8H
    CALL DELAY
    
    ; 0,075 DETIK * 400 -> 30 DETIK
    CMP COUNTER, 400
    JNE NAIK4
        CALL TAMAT
    NAIK4:
    
    MOV AX, COUNTER
    MOV BL, 13
    DIV BL
    CMP AH, 0
    JNE BELOM_SEDETIK3
        INC REALC
    BELOM_SEDETIK3:
    
    RET
ENDP

; TAMPILAN SAAT NAIK LEVEL
NAIK_LEVEL PROC NEAR
    MOV COUNTER, 0
    MOV REALC, 0
    INC LEVEL
    ; RESET LAYAR
    CALL SVGA
    ; INISIASI PRINT STRING
    LEA BP, NAIK
    MOV CX, PANJANG_NAIK
    MOV DH, 10
    MOV DL, 0
    CALL PRINT1
    
    CEK_LAGI1:
        MOV AH, 00H
        INT 16H
        CMP AH, 15H ;TOMBOL Y
    JE LAGI
        
        CMP AX, 011BH ;TOMBOL ESC
    JNE CEK_LAGI1
    
    ; EXIT
    MOV AX, 04C00H
    INT 21H
    
    LAGI:
    ; RESET LAYAR
    CALL SVGA
    RET
ENDP

KALAH PROC NEAR
    ; RESET LAYAR
    CALL SVGA
    ; INISIASI PRINT STRING
    LEA BP, GAGAL
    MOV CX, PANJANG_GAGAL
    MOV DH, 10
    MOV DL, 0
    CALL PRINT1
    
    CEK_LAGI2:
        MOV AH, 00H
        INT 16H
        CMP AH, 15H ;TOMBOL Y
    JE YA
        
        CMP AX, 011BH ;TOMBOL ESC
    JNE CEK_LAGI2
    
    CALL SELESAI
    
    YA:
        MOV X_ORANG, 35H
        MOV Y_ORANG, 1CH
        MOV COUNTER, 0
        MOV REALC, 0
        ; RESET LAYAR
        CALL SVGA
    RET
ENDP

TAMAT PROC NEAR
    ; RESET LAYAR
    CALL SVGA
    ; INISIASI PRINT STRING
    LEA BP, TAMAT_SUDAH
    MOV CX, PANJANG_TAMAT_SUDAH
    MOV DH, 10
    MOV DL, 0
    CALL PRINT1
    
    CEK_LAGI3:
        MOV AH, 00H
        INT 16H
        CMP AH, 15H ;TOMBOL Y
    JE YA1
        
        CMP AX, 011BH ;TOMBOL ESC
    JNE CEK_LAGI3
    
    CALL SELESAI
    
    YA1:
        MOV X_ORANG, 35H
        MOV Y_ORANG, 1CH
        
        MOV LEVEL, 0
        MOV COUNTER, 0
        MOV REALC, 0
        ; RESET LAYAR
        CALL SVGA
    RET
ENDP

GAME PROC NEAR
    ;x>35H ORANGNYA ADA DI KANAN
    ;MAKA ORANG AKAN BERGERAK KE KIRI
    CMP X_ORANG, 35H
    JA KAN
    JBE KIR
    
        ; UBAH POSISI ORANG
        ; SETIAP WAKTUNYA
        KIR:
            DEC X_ORANG
        JMP NJUT
        
        KAN:
            INC X_ORANG
        JMP NJUT
    
    NJUT:
    
    RET
ENDP


DELAY PROC NEAR
    ; DELAY INT 15H 86H DALAM MS
    ; COUNTER DI CX DAN DX
    ; CONTOH :
    ; 10.000MS -> 2710H
    ; MOV CX, 0H
    ; MOV DX, 02710H
    MOV AH, 86H
    INT 15H
    RET
ENDP

HEXTOBCD PROC NEAR
    MOV BX, 0
    ;PULUHAN
    P:  CMP AX, 10
    JB  S
    SUB AX, 10
    INC BL
    JMP P
    
    ;SATUAN
    S: MOV BH, AL
    
    RET
ENDP

PRINT_PRINT PROC NEAR
    ; MACRO UNTUK MEMPERMUDAH PRINT
    PRINT1C MACRO STRING, UKURAN, X, Y
        ; SIMPAN ALAMAT STRING UNTUK DICOPY
        LEA BP, STRING
        ; PANJANG STRING YANG INGIN DIPRINT
        MOV CX, UKURAN
        ; KOORDINAT
        MOV DH, Y
        MOV DL, X
        CALL PRINT1
    ENDM
    
    print1c tulisanc, panjang_tc, 0, 0
    
    ; SUPAYA BISA PRINT COUNTER MENGGUNAKAN ASCII
    MOV AX, REALC
    CALL HEXTOBCD
    XOR BX, 3030H
    MOV WAKTU, BX
    
    print1c waktu, 2, 18, 0
    print1c rumah, panjangr, 0, 2
    print1c orang, panjang, x_orang, y_orang
    
    print1c tulisan_arah, panjang_arah, 0, 43
    
    RET
ENDP

SELESAI PROC NEAR
    ; RESET LAYAR
    CALL SVGA
    
    ; EXIT
    MOV AX, 04C00H
    INT 21H
    
    RET
ENDP

.STARTUP
; SET WINDOW
CALL SVGA
; INTRO GAME
CALL OPENING
; RESET LAYAR
CALL SVGA

START:
    CALL PRINT_PRINT
    
    ; PANGGIL GAME
    CALL GAME
    
    ; KALO ORANG NEROBOS RUMAH
    CMP X_ORANG, 0FH
    JBE PANGGIL_KALAH
    
    CMP X_ORANG, 5AH
    JAE PANGGIL_KALAH
    
    SELESAI_PANGGIL_KALAH:
    
    ; PEMILIHAN LEVEL
    CMP LEVEL, 0
    JNE AKHIRLEVEL0
        CALL LEVEL0
    
    AKHIRLEVEL0:
    
    CMP LEVEL, 1
    JNE AKHIRLEVEL1
        CALL LEVEL1
    
    AKHIRLEVEL1:
    
    CMP LEVEL, 2
    JNE AKHIRLEVEL2
        CALL LEVEL2
    
    AKHIRLEVEL2:
    
    CMP LEVEL, 3
    JNE AKHIRLEVEL3
        CALL LEVEL3
    
    AKHIRLEVEL3:
    
    INC COUNTER
    
    ; CEK INPUT
    mov ah, 01h
    int 16h
    JZ START ; 0 ITU KALO GAK DIPENCET
    
    mov ah, 00H
    int 16h
    ; PENCET KANAN
    CMP AX, 4D00H
    JE NAN
    
    ; PENCET KIRI
    CMP AX, 4B00H
    JE RI    
    
    ;KALO DIPENCET ESC
    CMP AX, 011BH 
    JE AKHIR
    
    ;LOOP GAME
    JMP START
    
    ; UBAH POSISI ORANG
    ; DARI BERDASARKAN INPUT
    NAN:
        INC X_ORANG
        INC X_ORANG
    JMP START
    
    RI:
        DEC X_ORANG
        DEC X_ORANG
    JMP START
    
    PANGGIL_KALAH:
        CALL KALAH
    JMP SELESAI_PANGGIL_KALAH
    
    AKHIR:
    CALL SELESAI
END