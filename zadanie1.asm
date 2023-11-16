INCLUDE Irvine32.inc

.data
	pesel db 12 DUP(?) ;tablica bajt�w o rozmiarze 12 wype�niona niczym (11 pesel + 1 \0 znak ko�ca linii)
	wagi db 1,3,7,9,1,3,7,9,1,3 ; wagi do sumy kontrolnej
	msg db "Podaj swoj numer PESEL:", 0 ;dodatkowe zero oznacza koniec ci�gu znak�w
	dataUrMSG db "Data urodzenia: ", 0
	zlaDlugoscMSG db "Podales/as nieprawidlowy numer pesel!", 0
	zlyZnakMSG db "Numer pesel zawiera tylko cyfry!", 0
	zlaSumaMSG db "Bledna suma kontrolna", 0
	ukosnik db "/", 0

.code
main PROC
	;Wczytujemy napis do edx (EDX z regu�y przechowuje pierwszy argument, dlatego akurat do niego)
	mov edx, OFFSET msg ; Offset pobiera adres gdzie le�y msg, a move wrzuca ten adres do edx
	call WriteString ; Wypisuje to co jest pod EDX
	mov edx, OFFSET pesel 
	mov ecx, SIZEOF pesel 
	;EDX points to the input buffer
    ;ECX max number of non-null chars to read
	call ReadString

	; Sprawdzamy dlugosc napisu
	mov edx, OFFSET pesel ;Tyle powinno by� prawid�owo wi�c wrzucamy sobie do edx
	call StrLength ;Funkcja w�asna, Wywo�uje EDX (wy�ej) a zwraca warto�� w EAX
	cmp eax, 11
	jne zlaDlugosc ; jumpNotEqual wywo�ane je�li pesel (dlugosc w eax) nie ma dlugosci 11

	;Sprawdzamy czy wszystkie znaki to cyfry
	mov esi, OFFSET pesel ; wczytujemy do esi jako �r�d�o
	mov ecx, 11 ; ECX to licznik wiec wczytujemy do niego 11 aby iterowa� przez ca�y pesel 11x

	sprawdzCyfry:
		mov al, [esi] ; Przerzuca rejest esi do jego m�odszej 8-bitowej wersji al co wi��e si� z tym ze bierzemy jeden znak
		cmp al, '0' ; por�wnuje ten jeden znak z kodem ASCII cyfry 0 (48)
		jb zlyZnak ; Je�li jest mniejszy (czyli liczba jest ujemna) to skaczemy do proceduury z�ego znaku
		cmp al, '9' ; Tu tak samo tylko je�li jest wi�ksze
		ja zlyZnak ; skaczemy JumpAbove
		inc esi ; zwi�kszamy wska�nik w esi przesuwaj�c si� o 1.
		loop sprawdzCyfry ; zdekrementujemy warto�� ECX o 1 (ustawiony w linijce 34 jako licznik kt�rym pos�u�y si� instrukcja "loop") a nast�pnie idziemy do poczatku p�tli

	; Sprawdzamy sum� kontroln�
	mov esi, OFFSET pesel ; wrzucamy wska�nik na pierwszy adres z obu tablic
	mov edi, OFFSET wagi ; --||--
	call SumaKontrolna ; wywo�ujemy procedure ----> IDZ DO PROCEDURY
	mov al, [esi] ; wska�nik w esi obecnie bedzie na ostatniej cyfrze numeru pesel
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
    xor ebx, ebx     ; Zerowanie ebx, kt�ry b�dzie przechowywa� sum�
licz:
    mov al, [esi]    ; Wczytanie kolejnej cyfry PESEL, wrzucili�my sobie OFFSET do esi wcze�niej
    sub al, '0'      ; Konwersja z ASCII na liczb� np. ascii w hex to 32 dla '2' wiec jak odejmiemy '0' (30 w hex ascii) to mam cyfre czyli '2' :)
    mov dl, [edi]    ; Wczytanie odpowiedniej wagi kolejno
    imul dl          ; Mno�enie cyfry przez wag�, signed miltiply
    add ebx, eax     ; Dodanie wyniku do sumy
    inc esi          ; Przej�cie do nast�pnej cyfry PESEL
    inc edi          ; Przej�cie do nast�pnej wagi
    loop licz  ; Powt�rzenie p�tli dla wszystkich cyfr
	; W tym miejscu mamy juz sume kontrolna
	; wyciagamy z niej cyfre jednosci
	mov eax, ebx ; wrzucamy sobie sume do rejestru eax do pozniejszego dzielenia
	mov ecx, 10 ; wrzucamy dzielnik do ecx 
	xor edx, edx ; zerujemy sobie rejestr edx bo bedzie on trzmyla reszte z dzielenia
	div ecx ; dzielimy (domy�lnie podzieli eax/ecx)
	sub dl, 10 ; w edx juz jest reszta z dzielenia (np 8 dla tego dl wystarczy) odejmujemy od niej 10 (ze wzoru na pesel) 
	neg dl ; negujemy to jakby wyszla nam ujemna cyfra (-2 -> 2)
    ret ; zwracamy wszystko i nasze dl obecnie zawiera cyfre kontrolna
SumaKontrolna ENDP

; Wypiszmy date urodzenia
ObliczDate PROC
	;Dzien
	movzx eax, byte ptr [esi+5] ; Wczytaj warto�� i rozszerz j� do 32 bit�w (wype�nij reszte zerami)
    sub al, '0' ; zamiana z ascii na dziesi�tny (39 w ascii -> 9 w dziesi�tnym) ['0' -> 30 w ascii]
    movzx ebx, byte ptr [esi+4] ; Wczytaj drug� warto�� i rozszerz j� do 32 bit�w
    sub bl, '0'
	imul ebx, 10                ; Pomn� warto�� przez 10 no bo z peselu wezmiemy ilosc dziesiatek i jednosci dnia urodzenia
    add eax, ebx                ; Dodaj warto�ci
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