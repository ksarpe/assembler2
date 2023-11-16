; Co pozostalo do zrobienia
; - posprawdzac czy daty pasuja w przedzialy
; - sprawdzic czy komunikaty sie zgadzaja
; - dodac ewentualnie znak nowej linii
INCLUDE Irvine32.inc

.386
.model flat, stdcall
.stack 4096

.data

pesel BYTE 12 DUP(0) ;tablica bajtów o rozmiarze 12 wype³niona 0 (11 pesel + 1 \0 znak koñca linii)
weights BYTE 1,3,7,9,1,3,7,9,1,3 ; wagi do sumy kontrolnej
msg BYTE "Podaj numer PESEL:", 0 ;dodatkowe zero oznacza koniec ci¹gu znaków
birthDateMsg BYTE "Data urodzenia: ", 0
wrongLengthMsg BYTE "Niepoprawna dlugosc numeru PESEL! Poprawna to 11 znakow", 0
correctLengthMsg BYTE "Poprawna dlugosc numeru PESEL. ", 0
wrongCharMsg BYTE "Mozesz podac tylko cyfry oraz musza byc >= 0", 0
correctCharMsg BYTE "Prawidlowe znaki. ", 0
wrongChecksumMsg BYTE "Niepoprawna suma kontrolna", 0
correctChecksumMsg BYTE "Poprawna suma kontrolna. ", 0
wrongDateMsg BYTE "Niepoprawna data urodzenia", 0
slash BYTE "/", 0

.code

main PROC

	;Wczytujemy napis do edx (EDX z regu³y przechowuje pierwszy argument, dlatego akurat do niego)
	mov edx, OFFSET msg ; Offset pobiera adres gdzie le¿y msg, a move wrzuca ten adres do edx
	call WriteString ; Wypisuje to co jest pod EDX
	mov edx, OFFSET pesel ; Ustawia wskaŸnik tam gdzie zaczyna siê miejsce na pesel, do EDX
	mov ecx, SIZEOF pesel ; ReadString oczekuje dwoch argumentów wiec jeszcze podajemy rozmiar i wrzucamy go do ECX (drugi argument)
	call ReadString ; ReadString pobierze te dwa argumenty i wpisze to co podamy

	; Sprawdzamy dlugosc napisu
	mov edx, OFFSET pesel ;Tyle powinno byæ prawid³owo wiêc wrzucamy sobie do edx
	call StrLength ;Funkcja w³asna, Wywo³uje EDX (wy¿ej) a zwraca wartoœæ w EAX
	cmp eax, 11
	jne wrongLength ; jumpNotEqual wywo³ane jeœli pesel nie ma dlugosci 11
	mov edx, OFFSET correctLengthMsg
	call WriteString

	;Sprawdzamy czy wszystkie znaki to cyfry
	mov esi, OFFSET pesel ; wczytujemy do esi jako Ÿród³o
	mov ecx, 11 ; ECX to licznik wiec wczytujemy do niego 11 aby iterowaæ przez ca³y pesel 11x

checkDigits:
	mov al, [esi] ; Przerzuca rejest esi do jego m³odszej 8-bitowej wersji al co wi¹¿e siê z tym ze bierzemy jeden znak
	cmp al, '0' ; porównuje ten jeden znak z kodem ASCII cyfry 0 (48)
	jb invalidChar ; Jeœli jest mniejszy (czyli liczba jest ujemna) to skaczemy do proceduury z³ego znaku
	cmp al, '9' ; Tu tak samo tylko jeœli jest wiêksze
	ja invalidChar ; skaczemy JumpAbove
	inc esi ; zwiêkszamy wskaŸnik w esi przesuwaj¹c siê o 1.
	loop checkDigits ; zdekrementujemy wartoœæ ECX o 1 (ustawiony w linijce 34 jako licznik którym pos³u¿y siê instrukcja "loop") a nastêpnie idziemy do poczatku pêtli
	mov edx, OFFSET correctCharMsg
	call WriteString

	; Sprawdzamy sumê kontroln¹
	mov esi, OFFSET pesel ; wrzucamy wskaŸnik na pierwszy adres z obu tablic
	mov edi, OFFSET weights ; --||--
	call Checksum ; wywo³ujemy procedure ----> IDZ DO PROCEDURY
	mov al, [esi] ; wskaŸnik w esi obecnie bedzie na ostatniej cyfrze numeru pesel
	sub al, '0' ; zamieniamy cyfre z ascii na dziesietny
	cmp al, dl ; porownujemy ostatnia cyfre peselu z ta obliczona w naszej procedurze 
	jne invalidChecksum ; jak al != dl to skocz do wypisania bledu
	mov edx, OFFSET correctChecksumMsg
	call WriteString

	;Data urodzenia
	call WriteBirthDate
	jmp done

wrongLength:
	mov edx, OFFSET wrongLengthMsg
	call WriteString
	jmp done

invalidChar:
	mov edx, OFFSET wrongCharMsg
	call WriteString
	jmp done

invalidChecksum:
	mov edx, OFFSET wrongChecksumMsg
	call WriteString
	jmp done

WriteBirthDate:
	mov edx, OFFSET birthDateMsg
	call WriteString
	mov esi, OFFSET pesel
	call ExtractDate
	jmp done

done:
	call Crlf
	exit

main ENDP

; Funkcja do obliczenia sumy kontrolnej
Checksum PROC
    mov ecx, 10      ; Licznik iteracji
    xor ebx, ebx     ; Zerowanie ebx, który bêdzie przechowywa³ sumê
calculate:
    mov al, [esi]    ; Wczytanie kolejnej cyfry PESEL, wrzuciliœmy sobie OFFSET do esi wczeœniej
    sub al, '0'      ; Konwersja z ASCII na liczbê np. ascii w hex to 32 dla '2' wiec jak odejmiemy '0' (30 w hex ascii) to mam cyfre czyli '2' :)
    mov dl, [edi]    ; Wczytanie odpowiedniej wagi kolejno
    imul dl          ; Mno¿enie cyfry przez wagê, signed miltiply
    add ebx, eax     ; Dodanie wyniku do sumy
    inc esi          ; Przejœcie do nastêpnej cyfry PESEL
    inc edi          ; Przejœcie do nastêpnej wagi
    loop calculate   ; Powtórzenie pêtli dla wszystkich cyfr
	; W tym miejscu mamy juz sume kontrolna i jest poprawna
	; wyciagamy z niej cyfre jednosci
	mov eax, ebx ; wrzucamy sobie sume do rejestru eax do pozniejszego dzielenia
	mov ecx, 10 ; wrzucamy dzielnik do ecx 
	xor edx, edx ; zerujemy sobie rejestr edx bo bedzie on trzmyla reszte z dzielenia
	div ecx ; dzielimy (domyœlnie podzieli eax/ecx)
	sub dl, 10 ; w edx juz jest reszta z dzielenia (np 8 dla tego dl wystarczy) odejmujemy od niej 10 (ze wzoru na pesel) 
	neg dl ; negujemy to jakby wyszla nam ujemna cyfra (-2 -> 2)
    ret ; zwracamy wszystko i nasze dl obecnie zawiera cyfre kontrolna
Checksum ENDP

; Wypiszmy date urodzenia
ExtractDate PROC
	;Dzien
	movzx eax, byte ptr [esi+5] ; Wczytaj wartoœæ i rozszerz j¹ do 32 bitów
    sub al, '0'
    movzx ebx, byte ptr [esi+4] ; Wczytaj drug¹ wartoœæ i rozszerz j¹ do 32 bitów
    sub bl, '0'
	imul ebx, 10                ; Pomnó¿ wartoœæ przez 10 no bo z peselu wezmiemy ilosc dziesiatek i jednosci dnia urodzenia
    add eax, ebx                ; Dodaj wartoœci
    call WriteDec
	mov edx, OFFSET slash
    call WriteString

	;Miesiac
	movzx eax, byte ptr [esi+3]
	sub al, '0'
	movzx ebx, byte ptr [esi+2]
	sub bl, '0'
	imul ebx, 10
	add eax, ebx
	call WriteDec
	call WriteString

	;Rok
	movzx eax, byte ptr [esi +1]
	sub al, '0'
	movzx ebx, byte ptr [esi]
	sub bl, '0'
	imul ebx, 10
	add eax, ebx
	call WriteDec

	ret
ExtractDate ENDP

END main