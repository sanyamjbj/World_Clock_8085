.ORG 003CH
RST75:	CALL ISR75
	RET
.ORG 1000H
MAIN:	LXI H, 0FFFFH
	SPHL
	MVI A, 092H
	OUT 03H
	MVI A, 00H
	OUT 03H
INT:	MVI A, 30H
	MOV B, A
	CALL OUTPUT
	CALL CMDOUT
	CALL CMDOUT
	MVI A, 038H
	CALL CMDOUT
	MVI A, 08H
	CALL CMDOUT
	MVI A, 01H
	CALL CMDOUT
	MVI A, 0CH
	CALL CMDOUT
	CALL WCLOCK; PRINT WORLD CLOCK
	CALL DELBIG
	CALL NAMES; PRINT NAMES
	CALL DELBIG
	MVI A, 01H
	CALL CMDOUT
	MVI A, 0CH
	CALL CMDOUT
	CALL WCLOCK; PRINT WORLD CLOCK
	CALL INIT; PRINT 00:00:00
	CALL DELBIG
	SUB A;
	LXI H, 09000H
	MOV M, A;
	INX H
	MOV M, A;
	INX H
	MOV M, A;
	MVI A, 0CBH
	SIM
	EI
L2:	JMP L2	
	
CMDOUT:	MOV B,A
	CALL CHKDB7
OUTPUT:	MVI A, 01H
	OUT 02H
	MOV A, B
	OUT 01H
	MVI A, 00H
	OUT 02H
	RET
	
CHKDB7: MVI A, 092H
	OUT 03H
READ:	MVI A, 05H
	OUT 02H
	IN 01H
	RLC
	MVI A, 04H
	OUT 02H
	JC READ
	MVI A, 80H
	OUT 03H
	RET
	
DATA:	MOV B, A
	CALL CHKDB7
	MVI A, 03H
	OUT 02H
	MOV A, B
	OUT 01H
	MVI A, 02H
	OUT 02H
	RET
	
DELBIG:	MVI D, 0FFH
M2:	LXI B, 01000H
M1:	DCX B
	MOV A, B
	ORA C
	JNZ M1
	DCR D
	JNZ M2
	RET
	
ISR75:	DI
	LXI H, 09000H
	MOV A, M
	ADI 01H
	DAA
	MOV M, A
	CPI 060H
	JNZ SKPSEC;
	MVI M, 00H
	INX H
	MOV A, M
	ADI 01H
	DAA
	MOV M, A
	DCX H
SKPSEC:	INX H
	MOV A,M
	CPI 060H
	JNZ SKPMIN;
	MVI M, 00H
	INX H
	MOV A, M
	ADI 01H
	DAA
	MOV M, A
	DCX H
SKPMIN:	INX H
	MOV A,M
	CPI 024H
	JNZ SKPHRS;
	MVI M, 00H
SKPHRS:	CALL BCDBIN
	MVI A, 01H
	CALL CMDOUT
	MVI A, 0CH
	CALL CMDOUT
	CALL WCLOCK; PRINT WORLD CLOCK
	CALL GETIME; PRINT DISPLAY TIME
	EI
	RET
	
BCDBIN:	LXI H, 9001H
	MOV A, M
	ANI 0FH
	MOV C, A
	MOV A, M
	ANI 0F0H
	RRC
	RRC
	RRC
	RRC
	MVI B, 0AH
L14:	ADD A
	DCX B
	JNZ L14
	ADD C
	STA 0A000H
	LXI H, 9002H
	MOV A, M
	ANI 0FH
	MOV C, A
	MOV A, M
	ANI 0F0H
	RRC
	RRC
	RRC
	RRC
	MVI B, 0AH
L15:	ADD A
	DCX B
	JNZ L15
	ADD C
	STA 0A001H
	RET
	
BINBCD:	MOV D, A
	MVI A, 0FFH
L20:	ADI 01H
	DAA
	DCR D
	JNZ L20
	RET
	
GETIME:	MVI A, 0C0H
	CALL CMDOUT
	MVI A, 020H; PRINT " "
	CALL DATA
	MVI A, 020H; PRINT " "
	CALL DATA
	MVI A, 020H; PRINT " "
	CALL DATA
	MVI A, 020H; PRINT " "
	CALL DATA
	LXI H, 06000H
	IN 00H
	MVI C, 08H
	MVI B, 01H
	MVI E, 00H	
A6:	RLC 
	JNC S7
	MOV D, A
	MOV A, E
	ADD B
	MOV E, A
	MOV A, B
	RLC
	MOV B, A
	MOV A, D
S7:	DCR C
	JNZ A6	
	MOV L, E
	LDA 0A000H
	ADD M
	CPI 03CH
	JC S2
	SUI 03CH
S2:	CALL BINBCD
	STA 0B000H
	INX H
	LDA 0A001H
	ADD M
	CPI 018H
	JC S3
	SUI 018H
S3:	CALL BINBCD
	STA 0B001H
	LXI H, 0B001H
	MOV A, M
	MOV C, A
	ANI 0F0H
	RRC
	RRC
	RRC
	RRC
	MOV B, A
	CALL DIST; PRINT UPPER DIGIT OF HRS
	MOV A, C
	ANI 0FH
	MOV B, A
	CALL DIST; PRINT LOWER DIGIT OF HRS
	MVI A, 03AH
	CALL DATA; PRINT ":"
	DCX H
	MOV A, M
	MOV C, A
	ANI 0F0H
	RRC
	RRC
	RRC
	RRC
	MOV B, A
	CALL DIST; PRINT UPPER DIGIT OF MINS
	MOV A, C
	ANI 0FH
	MOV B, A
	CALL DIST; PRINT LOWER DIGIT OF MINS
	MVI A, 03AH
	CALL DATA; PRINT ":"
	LXI H, 09000H
	MOV A, M
	MOV C, A
	ANI 0F0H
	RRC
	RRC
	RRC
	RRC
	MOV B, A
	CALL DIST; PRINT UPPER DIGIT OF SECS
	MOV A, C
	ANI 0FH
	MOV B, A
	CALL DIST; PRINT LOWER DIGIT OF SECS
	RET
	
DIST:	MOV A, B
	CPI 00H
	JNZ L4
	MVI A, 030H
	CALL DATA;
	RET 
L4:	CPI 01H
	JNZ L5
	MVI A, 031H
	CALL DATA
	RET
L5:	CPI 01H
	JNZ L6
	MVI A, 031H
	CALL DATA
	RET
L6:	CPI 02H
	JNZ L7
	MVI A, 032H
	CALL DATA
	RET
L7:	CPI 03H
	JNZ L8
	MVI A, 033H
	CALL DATA
	RET
L8:	CPI 04H
	JNZ L9
	MVI A, 034H
	CALL DATA
	RET
L9:	CPI 05H
	JNZ L10
	MVI A, 035H
	CALL DATA
	RET
L10:	CPI 06H
	JNZ L11
	MVI A, 036H
	CALL DATA
	RET
L11:	CPI 07H
	JNZ L12
	MVI A, 037H
	CALL DATA
	RET
L12:	CPI 08H
	JNZ L13
	MVI A, 038H
	CALL DATA
	RET
L13:	CPI 09H
	MVI A, 039H
	CALL DATA
	RET

	
NAMES:	MVI A, 0C0H
	CALL CMDOUT
	MVI A, 053H
	CALL DATA
	MVI A, 041H
	CALL DATA
	MVI A, 04EH
	CALL DATA
	MVI A, 059H
	CALL DATA
	MVI A, 041H
	CALL DATA
	MVI A, 04DH
	CALL DATA
	MVI A, 020H
	CALL DATA
	MVI A, 020H
	CALL DATA
	MVI A, 026H
	CALL DATA
	MVI A, 020H
	CALL DATA
	MVI A, 020H
	CALL DATA
	MVI A, 041H
	CALL DATA
	MVI A, 04EH
	CALL DATA
	MVI A, 04DH; PRINT "M"
	CALL DATA
	MVI A, 04FH; PRINT "0"
	CALL DATA
	MVI A, 04CH; PRINT "L"
	CALL DATA
	RET
	
INIT:	MVI A, 0C0H
	CALL CMDOUT
	MVI A, 020H; PRINT " "
	CALL DATA
	MVI A, 020H; PRINT " "
	CALL DATA
	MVI A, 020H; PRINT " "
	CALL DATA
	MVI A, 020H; PRINT " "
	CALL DATA
	MVI A, 030H; PRINT "0"
	CALL DATA
	MVI A, 030H; PRINT "0"
	CALL DATA
	MVI A, 03AH; PRINT ":"
	CALL DATA
	MVI A, 030H; PRINT "0"
	CALL DATA
	MVI A, 030H; PRINT "0"
	CALL DATA
	MVI A, 03AH; PRINT ":"
	CALL DATA
	MVI A, 030H; PRINT "0"
	CALL DATA
	MVI A, 030H; PRINT "0"
	CALL DATA
	RET

	
WCLOCK: MVI A, 080H
	CALL CMDOUT
	MVI A, 020H
	CALL DATA
	MVI A, 020H
	CALL DATA
	MVI A, 057H
	CALL DATA
	MVI A, 04FH
	CALL DATA
	MVI A, 052H
	CALL DATA
	MVI A, 04CH
	CALL DATA
	MVI A, 044H
	CALL DATA
	MVI A, 020H
	CALL DATA
	MVI A, 020H
	CALL DATA
	MVI A, 043H
	CALL DATA
	MVI A, 04CH
	CALL DATA
	MVI A, 04FH
	CALL DATA
	MVI A, 043H
	CALL DATA
	MVI A, 04BH
	CALL DATA
	RET

		