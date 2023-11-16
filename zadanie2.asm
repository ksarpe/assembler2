INCLUDE Irvine32.inc

.data
string db 81 dup(0)   ; Tablica na 80 znaków + znak koñca linii
counts db 256 dup(0)  ; Tablica na zliczanie wystšpieñ ka¿dego z 256 mo¿liwych znaków

.code
main PROC
    ; Wczytaj napis
    mov edx, OFFSET string
    mov ecx, 80
    call ReadString ; ReadString bierze EDX jako pointer na bufor a ECX jakos max numer znaków do przeczytania
    
    ; Zlicz wystšpienia ka¿dego znaku
    mov esi, OFFSET string
count:
    mov al, [esi] ; przerzuc znak z esi (naszego stringa)
    cmp al, 0 ; sprawdz czy jest cokolwiek czy juz koniec
    je  countDone ; jak koniec to skoncz
    inc counts[eax] ; jak nie to zwieksz tablice pod wartoscia tego znaku w ascii
    inc esi ; zwieksz wskaznik na znak w tablicy string
    jmp count ; wroc do naszej petli zliczajacej
countDone:
    ; Wypisz wyniki
    mov esi, 0 ; sprawdzamy od znaku 0 (ascii)

print:
    cmp esi, 256 ; jak tablica ascii sie skonczyla to zakoncz program
    jge done
    mov al, counts[esi] ; przerzuc ilosc z counts
    cmp al, 0 ; jak al jest zero (czyli nic)
    je next ; to przeskocz literke
    mov dl, al ;tymczasowo przerzucamy aby najpierw wypisaæ literke a potem iloœæ
    mov eax, esi ;teraz podstawiamy do eax znak z ascii
    call WriteChar ; wypisujemy go (wezmie eax)
    mov al, ':'
    call WriteChar ; wypisujemy ":"
    movzx eax, dl ; wrzucamy ilosc do eax
    call WriteDec
    call Crlf ; nowa linia

next:
    inc esi
    jmp print
done:
    call Crlf
    invoke ExitProcess, 0

main ENDP
END main