INCLUDE Irvine32.inc

.data
	pesel db 12 DUP(?) ;tablica bajtów o rozmiarze 12 wype³niona niczym (11 pesel + 1 \0 znak koñca linii)
	wagi db 1,3,7,9,1,3,7,9,1,3 ; wagi do sumy kontrolnej
	msg db "Podaj swoj numer PESEL:", 0 ;dodatkowe zero oznacza koniec ci¹gu znaków
	dataUrMSG db "Data urodzenia: ", 0
	zlaDlugoscMSG db "Podales/as nieprawidlowy numer pesel!", 0
	zlyZnakMSG db "Numer pesel zawiera tylko cyfry!", 0
	zlaSumaMSG db "Bledna suma kontrolna", 0
	ukosnik db "/", 0

.code
main PROC
	;Wczytujemy napis do edx (EDX z regu³y przechowuje pierwszy argument, dlatego akurat do niego)
	mov edx, OFFSET msg ; Offset pobiera adres gdzie le¿y msg, a move wrzuca ten adres do edx
	call WriteString ; Wypisuje to co jest pod EDX
	mov edx, OFFSET pesel 
	mov ecx, SIZEOF pesel 
	;EDX points to the input buffer
    ;ECX max number of non-null chars to read
	call ReadString

	; Sprawdzamy dlugosc napisu
	mov edx, OFFSET pesel ;Tyle powinno byæ prawid³owo wiêc wrzucamy sobie do edx
	call StrLength ;Funkcja w³asna, Wywo³uje EDX (wy¿ej) a zwraca wartoœæ w EAX
	cmp eax, 11
	jne zlaDlugosc ; jumpNotEqual wywo³ane jeœli pesel (dlugosc w eax) nie ma dlugosci 11

	;Sprawdzamy czy wszystkie znaki to cyfry
	mov esi, OFFSET pesel ; wczytujemy do esi jako Ÿród³o
	mov ecx, 11 ; ECX to licznik wiec wczytujemy do niego 11 aby iterowaæ przez ca³y pesel 11x

	sprawdzCyfry:
		mov al, [esi] ; Przerzuca rejest esi do jego m³odszej 8-bitowej wersji al co wi¹¿e siê z tym ze bierzemy jeden znak
		cmp al, '0' ; porównuje ten jeden znak z kodem ASCII cyfry 0 (48)
		jb zlyZnak ; Jeœli jest mniejszy (czyli liczba jest ujemna) to skaczemy do proceduury z³ego znaku
		cmp al, '9' ; Tu tak samo tylko jeœli jest wiêksze
		ja zlyZnak ; skaczemy JumpAbove
		inc esi ; zwiêkszamy wskaŸnik w esi przesuwaj¹c siê o 1.
		loop sprawdzCyfry ; zdekrementujemy wartoœæ ECX o 1 (ustawiony w linijce 34 jako licznik którym pos³u¿y siê instrukcja "loop") a nastêpnie idziemy do poczatku pêtli

	; Sprawdzamy sumê kontroln¹
	mov esi, OFFSET pesel ; wrzucamy wskaŸnik na pierwszy adres z obu tablic
	mov edi, OFFSET wagi ; --||--
	call SumaKontrolna ; wywo³ujemy procedure ----> IDZ DO PROCEDURY
	mov al, [esi] ; wskaŸnik w esi obecnie bedzie na ostatniej cyfrze numeru pesel
	sub al, '0' ; zamieniamy cyfre z ascii na dziesietny
	cmp al, dl ; porownujemy ostatnia cyfre peselu z ta obliczona w naszej procedurze 
	jne zlaSuma ; jak al != dl to skocz do wypisania bledu


	;Data urodzenia
	call WypiszDate
	jmp done

zlaDlugosc:
	mov edx, OFFSET zlaDlugoscMSG
	call WriteString
	jmp done

zlyZnak:
	mov edx, OFFSET zlyZnakMSG
	call WriteString
	jmp done

zlaSuma:
	mov edx, OFFSET zlaSumaMSG
	call WriteString
	jmp done

WypiszDate:
	mov edx, OFFSET dataUrMSG
	call WriteString
	mov esi, OFFSET pesel
	call ObliczDate
	jmp done

done:
	call Crlf
	exit

main ENDP

; Funkcja do obliczenia sumy kontrolnej
SumaKontrolna PROC
    mov ecx, 10      ; Licznik iteracji
    xor ebx, ebx     ; Zerowanie ebx, który bêdzie przechowywa³ sumê
licz:
    mov al, [esi]    ; Wczytanie kolejnej cyfry PESEL, wrzuciliœmy sobie OFFSET do esi wczeœniej
    sub al, '0'      ; Konwersja z ASCII na liczbê np. ascii w hex to 32 dla '2' wiec jak odejmiemy '0' (30 w hex ascii) to mam cyfre czyli '2' :)
    mov dl, [edi]    ; Wczytanie odpowiedniej wagi kolejno
    imul dl          ; Mno¿enie cyfry przez wagê, signed miltiply
    add ebx, eax     ; Dodanie wyniku do sumy
    inc esi          ; Przejœcie do nastêpnej cyfry PESEL
    inc edi          ; Przejœcie do nastêpnej wagi
    loop licz  ; Powtórzenie pêtli dla wszystkich cyfr
	; W tym miejscu mamy juz sume kontrolna
	; wyciagamy z niej cyfre jednosci
	mov eax, ebx ; wrzucamy sobie sume do rejestru eax do pozniejszego dzielenia
	mov ecx, 10 ; wrzucamy dzielnik do ecx 
	xor edx, edx ; zerujemy sobie rejestr edx bo bedzie on trzmyla reszte z dzielenia
	div ecx ; dzielimy (domyœlnie podzieli eax/ecx)
	sub dl, 10 ; w edx juz jest reszta z dzielenia (np 8 dla tego dl wystarczy) odejmujemy od niej 10 (ze wzoru na pesel) 
	neg dl ; negujemy to jakby wyszla nam ujemna cyfra (-2 -> 2)
    ret ; zwracamy wszystko i nasze dl obecnie zawiera cyfre kontrolna
SumaKontrolna ENDP

; Wypiszmy date urodzenia
ObliczDate PROC
	;Dzien
	movzx eax, byte ptr [esi+5] ; Wczytaj wartoœæ i rozszerz j¹ do 32 bitów (wype³nij reszte zerami)
    sub al, '0' ; zamiana z ascii na dziesiêtny (39 w ascii -> 9 w dziesiêtnym) ['0' -> 30 w ascii]
    movzx ebx, byte ptr [esi+4] ; Wczytaj drug¹ wartoœæ i rozszerz j¹ do 32 bitów
    sub bl, '0'
	imul ebx, 10                ; Pomnó¿ wartoœæ przez 10 no bo z peselu wezmiemy ilosc dziesiatek i jednosci dnia urodzenia
    add eax, ebx                ; Dodaj wartoœci
    call WriteDec
	mov edx, OFFSET ukosnik
    call WriteString

	;Miesiac
	movzx eax, byte ptr [esi+3]
	sub al, '0'
	movzx ebx, byte ptr [esi+2]
	sub bl, '0'
	imul ebx, 10

	cmp ebx, 12
	jg po2000

	;wykonuj dla urodzonych przed 2000

	;miesiac
	add eax, ebx
	call WriteDec
	call WriteString
	;rok
	mov eax, 19
	call WriteDec
	movzx eax, byte ptr [esi +1]
	sub al, '0'
	movzx ebx, byte ptr [esi]
	sub bl, '0'
	imul ebx, 10
	add eax, ebx
	call WriteDec
	ret

	po2000:
		;Miesiac
		add eax, ebx
		sub eax, 20
		call WriteDec
		call WriteString ;znow ukosnik

		;Rok
		mov eax, 20
		call WriteDec
		movzx eax, byte ptr [esi +1]
		sub al, '0'
		movzx ebx, byte ptr [esi]
		sub bl, '0'
		imul ebx, 10
		add eax, ebx
		call WriteDec

	ret
ObliczDate ENDP

END main