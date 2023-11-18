INCLUDE Irvine32.inc

.data
array DWORD 8 DUP(?) 
arraySize DWORD 8  

.code
main PROC
    mov ecx, arraySize
    lea esi, array
ReadLoop:
    call ReadInt
    mov [esi], eax
    add esi, 4
    loop ReadLoop

    push arraySize   
    push OFFSET array
    
    call BubbleSort
    ;call InsertionSort
    ;call SelectionSort
    mov esi, OFFSET array
    mov ecx, arraySize
    ;call QuickSort
    
    mov ecx, arraySize
    lea esi, array
PrintLoop:
    mov eax, [esi]     ; Wczytaj warto?? do wypisania
    call WriteInt      ; Wypisz warto??
    call Crlf          ; Wypisz now? lini?
    add esi, 4         ; Przesu? wska?nik do nast?pnej warto?ci w tablicy
    loop PrintLoop     ; Kontynuuj p?tl? je?li ECX nie jest jeszcze zero


    call ExitProcess
main ENDP

BubbleSort PROC
    push ebp             ; Zapisuje na stosie bazowy wska?nik stosu poprzedniej funkcji/procedury
    mov ebp, esp         ; Ustawia bazowy wska?nik stosu na aktualny wska?nik stosu

    mov ebx, [ebp+8]     ; Wczytuje do rejestru EBX adres pocz?tkowy tablicy (parametr przekazany przez stos)
    mov ecx, [ebp+12]    ; Wczytuje do rejestru ECX rozmiar tablicy (parametr przekazany przez stos)
    dec ecx              ; Dekrementuje ECX, poniewa? w sortowaniu b?belkowym ostatni element jest ju? na miejscu po pierwszym przej?ciu

OuterLoop:
    mov esi, ebx       ; Resetuje ESI do oryginalnego adresu tablicy zapisanego na stosie
    mov edi, ecx         ; Przekopiuje warto?? ECX do EDI
    dec edi              ; Dekrementuje EDI, aby EDI by?o mniejsze o jeden od ECX
    lea edi, [esi + 4*edi + 4] ; Ustawia EDI na koniec cz?ci tablicy, kt?ra b?dzie sortowana (minus jeden element)

InnerLoop:
    mov eax, [esi]       ; Wczytuje bie??cy element tablicy do rejestru EAX
    cmp eax, [esi + 4]   ; Por?wnuje bie??cy element (EAX) z nast?pnym elementem tablicy
    jle NoSwap           ; Skacze do etykiety NoSwap, je?li bie??cy element jest mniejszy lub r?wny nast?pnemu
    xchg eax, [esi + 4]  ; Wymienia miejscami bie??cy element z nast?pnym, je?li jest wi?kszy
    mov [esi], eax       ; Zapisuje now? warto?? bie??cego elementu (by?y nast?pny)
NoSwap:
    add esi, 4           ; Inkrementuje wska?nik tablicy (przesuwa o element do przodu)
    cmp esi, edi         ; Por?wnuje aktualn? pozycj? wska?nika z ko?cem sortowanej cz?ci tablicy
    jb InnerLoop         ; Je?li nie doszli?my do ko?ca, skacze do pocz?tku InnerLoop

    dec ecx              ; Dekrementuje ECX, bo ostatni element jest ju? posortowany
    jnz OuterLoop        ; Je?li ECX nie jest zerem, oznacza to, ?e nie doszli?my do ko?ca tablicy i skacze do OuterLoop

    pop ebp              ; Przywraca poprzedni? warto?? EBP
    ret 8                ; Zwraca sterowanie do wywo?uj?cego, zwalniaj?c miejsce 8 bajt?w (2 parametry * 4 bajty) z stosu
BubbleSort ENDP

InsertionSort PROC
    push ebp                 ; Zapisz na stosie bazowy wska?nik stosu
    mov ebp, esp             ; Ustaw bazowy wska?nik stosu na bie??cy wska?nik stosu
    mov esi, [ebp+8]         ; Za?aduj do rejestru esi adres tablicy (pierwszy argument procedury)
    mov ecx, 1               ; Ustaw licznik p?tli 'i' na 1, poniewa? pierwszy element jest ju? posortowany

OuterLoop:
    mov edx, [esi + ecx*4]   ; Za?aduj bie??cy element (arr[i]) do rejestru edx jako 'klucz'
    mov ebx, ecx             ; Skopiuj licznik p?tli 'i' do ebx jako 'j'
    dec ebx                  ; Zmniejsz ebx o jeden, aby uzyska? 'j = i - 1'
    lea edi, [esi + ebx*4]   ; Za?aduj adres arr[j] do rejestru edi

InnerLoop:
    cmp [edi], edx           ; Por?wnaj warto?? arr[j] z 'kluczem'
    jle InsertFinished       ; Je?li arr[j] <= 'klucz', zako?cz wewn?trzn? p?tl?, bo znaleziono pozycj? do wstawienia
    mov eax, [edi]           ; Za?aduj warto?? arr[j] do rejestru eax
    mov [edi + 4], eax       ; Przepisz warto?? z eax do arr[j+1], przesuwaj?c arr[j] w g?r?
    sub edi, 4               ; Aktualizuj edi, aby wskazywa? na kolejny element w d? w tablicy
    dec ebx                  ; Zmniejsz 'j'
    jns InnerLoop            ; Je?li 'j' wci?? jest nieujemne, kontynuuj wewn?trzn? p?tl?

InsertFinished:
    mov [edi + 4], edx       ; Wstaw 'klucz' do tablicy na pozycji arr[j+1]
    inc ecx                  ; Zwi?ksz licznik p?tli 'i' aby przej?? do nast?pnego elementu
    cmp ecx, [ebp+12]        ; Por?wnaj licznik p?tli 'i' z rozmiarem tablicy 'n' (drugi argument procedury)
    jl OuterLoop             ; Je?li 'i' jest mniejsze ni? 'n', kontynuuj z kolejn? iteracj? zewn?trznej p?tli
    pop ebp                  ; Przywr?? bazowy wska?nik stosu
    ret 8                    ; Wyjd? z procedury i oczy?? stos z 8 bajt?w (2 argumenty po 4 bajty ka?dy)
InsertionSort ENDP

Swap PROC
    push ebp
    push ecx
    mov ebp, esp
    mov eax, [ebp+16] ; loading address of first item to swap
    mov ecx, [ebp+12] ; loading second item to swap
    mov edx, [eax] ; loading value ot first item to TEMP
    mov ebx, [ecx] ; loading value of second item to TEMP2
    mov [ecx], edx ; store the value of first item in TEMP into address ecx
    mov [eax], ebx ; same for second
    ;now items are swapped
    pop ecx
    pop ebp
    ret
Swap ENDP

SelectionSort PROC
    ; inicializujemy sobie stos
    push ebp
    mov ebp, esp

    ;przygotowywujemy zmienne ze stosu
    mov ecx, [ebp+12] ; n, ecx np = 8
    mov esi, [ebp+8] ; array address, esi np = 0x00F8392D pocz?tek tablicy 

    xor edi, edi ; ustawiamy tak jakby i na zero
    dec ecx ; counter na 7 do pierwszej petli

OuterLoop:
    cmp edi, ecx
    jge EndOuterLoop
    
    mov ebx, edi ; min_index = i
    inc edi ; i++
    mov edx, edi ; j = i (i+1 po inc)
    dec edi ; wracamy z i bo jest 0 normalnie

InnerLoop:  ; ebx -> min_index, edi -> i, edx -> j
    push ecx
    inc ecx
    cmp edx, ecx
    pop ecx
    jge EndInnerLoop
    mov eax, [esi + 4*edx]
    cmp eax, [esi + 4*ebx]
    jge NoSwap ; jae for unsigned numbers, jge for signed
    
    ; If we swap then
    mov ebx, edx ; min_idx = j

NoSwap:
    inc edx
    jmp InnerLoop

EndInnerLoop:
    cmp ebx, edi
    je NoMinSwap
    lea eax, [esi + edi*4]
    lea edx, [esi + ebx*4]
    push edx
    push eax
    call Swap
    add esp, 8

NoMinSwap:
    inc edi
    jmp OuterLoop

EndOuterLoop:
    pop ebp
    ret 8

SelectionSort ENDP

Partition PROC
    ; Ustawienie pivot na ostatni element tablicy
    mov edx, ecx
    dec edx
    mov eax, [esi + edx*4] ; eax = pivot
    mov ebx, -1            ; Indeks mniejszej cz?ci

    ; Przej?cie przez elementy tablicy
    mov edx, 0
    WhileLoop:
        cmp edx, ecx
        jge PartitionEnd  ; Je?li wszystkie elementy zosta?y sprawdzone

        ; Por?wnanie elementu z pivotem
        mov edi, [esi + edx*4] ; Wczytanie bie??cego elementu
        cmp edi, eax
        jge IncrementIndex

        ; Zamiana element?w
        inc ebx
        ; Przesuni?cie ebx o 4*ebx do adresu w?a?ciwego elementu
        mov edi, [esi + ebx*4]
        xchg edi, [esi + edx*4]
        mov [esi + ebx*4], edi

        IncrementIndex:
        inc edx
        jmp WhileLoop

    PartitionEnd:
    ; Zamiana pivota z pierwszym wi?kszym elementem
    inc ebx
    mov edx, [esi + ebx*4]  ; Adres docelowy dla pivota
    xchg edx, [esi + ecx*4 - 4] ; Zamiana miejscami z pivotem
    mov [esi + ebx*4], edx

    ; Zwracanie nowego indeksu pivota
    mov eax, ebx
    ret
Partition ENDP

QuickSort PROC
    cmp ecx, 1
    jle Done ; jak mamy jeden element w tablicy to konczymy

    call Partition
    push ecx ; zachowujemy ecx na stosie

    ;lewa polowa
    mov ecx, eax ; eax jest z partition (index)
    call QuickSort

    ;prawa polowa
    pop ecx
    sub ecx, eax
    add esi, eax
    add esi, 4
    call QuickSort

    ;stan poczatkowy esi
    sub esi, eax
    sub esi, 4

Done:
    ret
QuickSort ENDP

END main