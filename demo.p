pcode dump


	New pBlock

internal pblock, dbName =M
;; Starting pCode block
_main:	;Function start
; 0 exit points
;	.line	290; "demo.c"	ULAWC=ULAWC_DEFAULT;
	LDA	#0x18
	STA	_ULAWC
;	.line	291; "demo.c"	init();
	CALL	_init
;	.line	292; "demo.c"	if(!(init_io_state&IO_CAP) )
	LDA	#0x08
	AND	_init_io_state
	JNZ	_00290_DS_
;	.line	295; "demo.c"	API_SPI_ERASE((USHORT)R2_STARTPAGE); // first time we erase!!
	LDA	#0x01
	STA	_SPIH
	LDA	#0x70
	STA	_SPIM
	CLRA	
	STA	_SPIL
	LDA	#0x01
	STA	_SPIOP
	LDA	#0x02
	STA	_SPIOP
_00290_DS_:
;	.line	299; "demo.c"	timer_routine();
	CALL	_timer_routine
;	.line	300; "demo.c"	if(key_code)
	LDA	_key_code
	JZ	_00271_DS_
;	.line	302; "demo.c"	if(sys_state!=SYS_IDLE)
	LDA	_sys_state
	JZ	_00268_DS_
;	.line	303; "demo.c"	enter_idle_mode();
	CALL	_enter_idle_mode
	JMP	_00269_DS_
_00268_DS_:
;	.line	305; "demo.c"	switch(key_code)
	LDA	_key_code
	JZ	_00269_DS_
	SETB	_C
	LDA	#0x03
	SUBB	_key_code
	JNC	_00269_DS_
	LDA	_key_code
	DECA	
	CALL	_00336_DS_
_00336_DS_:
	SHL	
	ADD	#_00337_DS_
	STA	_STACKL
	CLRA	
	ADDC	#>(_00337_DS_)
	STA	_STACKH
	RET	
_00337_DS_:
	JMP	_00261_DS_
	JMP	_00260_DS_
	JMP	_00265_DS_
_00260_DS_:
;	.line	308; "demo.c"	enter_rec_mode();
	CALL	_enter_rec_mode
;	.line	309; "demo.c"	break;
	JMP	_00269_DS_
_00261_DS_:
;	.line	312; "demo.c"	API_SPI_READ_PAGE((USHORT)R2_STARTPAGE, 1);// read prev data to 0x100
	LDA	#0x01
	STA	_SPIH
	LDA	#0x70
	STA	_SPIM
	CLRA	
	STA	_SPIL
	LDA	#0x48
	STA	_SPIOP
;	.line	313; "demo.c"	if(TAG==0xff)
	CLRA	
	STA	_ROMPL
	LDA	#0x81
	STA	_ROMPH
	LDA	@_ROMPINC
	XOR	#0xff
	JNZ	_00263_DS_
;	.line	315; "demo.c"	TAG=0;
	LDA	#0x81
	STA	_ROMPH
	CLRA	
	STA	_ROMPL
	STA	@_ROMPINC
;	.line	316; "demo.c"	API_SPI_WRITE_PAGE((USHORT)R2_STARTPAGE,1); // write it
	LDA	#0x01
	STA	_SPIH
	LDA	#0x70
	STA	_SPIM
	CLRA	
	STA	_SPIL
	LDA	#0x01
	STA	_SPIOP
	LDA	#0x44
	STA	_SPIOP
;	.line	317; "demo.c"	enter_play_mode(0);
	CLRA	
	PUSH	
	CALL	_enter_play_mode
	JMP	_00269_DS_
_00263_DS_:
;	.line	320; "demo.c"	enter_play_mode(1);
	LDA	#0x01
	PUSH	
	CALL	_enter_play_mode
;	.line	323; "demo.c"	break;
	JMP	_00269_DS_
_00265_DS_:
;	.line	325; "demo.c"	enter_play_mode(2);
	LDA	#0x02
	PUSH	
	CALL	_enter_play_mode
_00269_DS_:
;	.line	331; "demo.c"	key_code=0;
	CLRA	
	STA	_key_code
_00271_DS_:
;	.line	334; "demo.c"	if(sys_state==SYS_REC)
	LDA	_sys_state
	XOR	#0x02
	JNZ	_00287_DS_
;	.line	335; "demo.c"	sys_rec();
	CALL	_sys_rec
	JMP	_00290_DS_
_00287_DS_:
;	.line	336; "demo.c"	else if(sys_state==SYS_PLAY)
	LDA	_sys_state
	XOR	#0x01
	JNZ	_00284_DS_
;	.line	337; "demo.c"	sys_play();
	CALL	_sys_play
	JMP	_00290_DS_
_00284_DS_:
;	.line	338; "demo.c"	else if(!sleep_timer && !key_state)
	LDA	_sleep_timer
	JNZ	_00280_DS_
	LDA	_key_state
	JNZ	_00280_DS_
;	.line	341; "demo.c"	IODIR=0;
	CLRA	
;	.line	342; "demo.c"	IO=0;
	STA	_IODIR
	STA	_IO
;	.line	343; "demo.c"	IOR=0xff;
	LDA	#0xff
	STA	_IOR
;	.line	345; "demo.c"	IO|=0x80;
	LDA	_IO
	ORA	#0x80
;	.line	346; "demo.c"	if(IO==0xff)
	STA	_IO
	XOR	#0xff
	JNZ	_00290_DS_
;	.line	349; "demo.c"	api_normal_sleep(IO_KEY_ALL,0,1);
	LDA	#0x01
	PUSH	
	CLRA	
	PUSH	
	LDA	#0x07
	PUSH	
	CALL	_api_normal_sleep
	JMP	_00290_DS_
_00280_DS_:
;	.line	372; "demo.c"	if(key_state)
	LDA	_key_state
	JZ	_00275_DS_
;	.line	373; "demo.c"	api_enter_stdby_mode(0 ,0,0); // use tmr wk
	CLRA	
	PUSH	
	PUSH	
	PUSH	
	CALL	_api_enter_stdby_mode
	JMP	_00276_DS_
_00275_DS_:
;	.line	375; "demo.c"	api_enter_stdby_mode(IO_KEY_ALL,0,0); //use tmr+io wk
	CLRA	
	PUSH	
	PUSH	
	LDA	#0x07
	PUSH	
	CALL	_api_enter_stdby_mode
_00276_DS_:
;	.line	376; "demo.c"	if(!TOV)
	LDC	_TOV
	JC	_00290_DS_
;	.line	377; "demo.c"	key_machine(); // wake up by IO, we get keycode first
	CALL	_key_machine
	JMP	_00290_DS_

	New pBlock

CSEG	 (CODE), dbName =C
;; Starting pCode block
_sys_rec:	;Function start
; 0 exit points
;	.line	267; "demo.c"	if(IO&IO_REC)
	LDA	_IO
	SHR	
	JNC	_00245_DS_
;	.line	269; "demo.c"	enter_idle_mode();
	JMP	_enter_idle_mode
_00245_DS_:
;	.line	272; "demo.c"	if(!api_rec_job_alc())
	CALL	_api_rec_job_alc
;	.line	270; "demo.c"	return;
	JNZ	_00250_DS_
;	.line	273; "demo.c"	enter_idle_mode();
	JMP	_enter_idle_mode
_00250_DS_:
;	.line	276; "demo.c"	if(IO&IO_REC)
	LDA	_IO
	SHR	
	JNC	_00247_DS_
;	.line	277; "demo.c"	enter_idle_mode();
	JMP	_enter_idle_mode
_00247_DS_:
;	.line	279; "demo.c"	api_enter_stdby_mode(0,0,0);// use timer wk, adjust 
	CLRA	
	PUSH	
	PUSH	
	PUSH	
	JMP	_api_enter_stdby_mode

	New pBlock

CSEG	 (CODE), dbName =C
;; Starting pCode block
_sys_play:	;Function start
; 0 exit points
;	.line	233; "demo.c"	void sys_play(void)
	LDA	_RAMP1L
	PUSH	
	P02P1	
	PUSH	
;	.line	235; "demo.c"	BYTE result =api_play_job(); 
	CALL	_api_play_job
;	.line	236; "demo.c"	if(!result)
	STA	@_RAMP1
	JNZ	_00237_DS_
;	.line	237; "demo.c"	enter_idle_mode();
	CALL	_enter_idle_mode
	JMP	_00239_DS_
_00237_DS_:
;	.line	238; "demo.c"	else if(result==2)
	LDA	@_RAMP1
	XOR	#0x02
	JNZ	_00234_DS_
;	.line	247; "demo.c"	if(PWRH)
	LDA	_PWRH
	JZ	_00228_DS_
;	.line	248; "demo.c"	IO&=0x7F;
	LDA	_IO
	AND	#0x7f
	STA	_IO
	JMP	_00239_DS_
_00228_DS_:
;	.line	250; "demo.c"	IO|=0x80;
	LDA	_IO
	ORA	#0x80
	STA	_IO
	JMP	_00239_DS_
_00234_DS_:
;	.line	253; "demo.c"	if(key_state==KEYS_NOKEY)
	LDA	_key_state
	JNZ	_00231_DS_
;	.line	256; "demo.c"	api_enter_stdby_mode(IO_KEY_ALL, 0, 1);
	LDA	#0x01
	PUSH	
	CLRA	
	PUSH	
	LDA	#0x07
	PUSH	
	CALL	_api_enter_stdby_mode
	JMP	_00239_DS_
_00231_DS_:
;	.line	259; "demo.c"	api_enter_stdby_mode(0,0,0);
	CLRA	
	PUSH	
	PUSH	
	PUSH	
	CALL	_api_enter_stdby_mode
_00239_DS_:
	POP	
	POP	
	STA	_RAMP1L
	RET	

	New pBlock

CSEG	 (CODE), dbName =C
;; Starting pCode block
_enter_idle_mode:	;Function start
; 0 exit points
;	.line	215; "demo.c"	api_play_stop();
	CALL	_api_play_stop
;	.line	217; "demo.c"	if(sys_state==SYS_REC) // stop from recording
	LDA	_sys_state
	XOR	#0x02
	JNZ	_00222_DS_
;	.line	219; "demo.c"	api_rec_stop_alc(1); // it will add endcode here
	LDA	#0x01
	PUSH	
	CALL	_api_rec_stop_alc
;	.line	221; "demo.c"	api_beep_start(NORMAL_BEEP);
	LDA	#0x14
	PUSH	
	CALL	_api_beep_start
;	.line	222; "demo.c"	wait_beep(BEEP_TIME2);
	LDA	#0x50
	PUSH	
	CALL	_wait_beep
;	.line	223; "demo.c"	api_beep_stop();
	CALL	_api_beep_stop
;	.line	224; "demo.c"	wait_beep(BEEP_TIME2);
	LDA	#0x50
	PUSH	
	CALL	_wait_beep
;	.line	225; "demo.c"	api_beep_start(NORMAL_BEEP);
	LDA	#0x14
	PUSH	
	CALL	_api_beep_start
;	.line	226; "demo.c"	wait_beep(BEEP_TIME2);
	LDA	#0x50
	PUSH	
	CALL	_wait_beep
;	.line	227; "demo.c"	api_beep_stop();
	CALL	_api_beep_stop
_00222_DS_:
;	.line	229; "demo.c"	sys_state=SYS_IDLE;
	CLRA	
	STA	_sys_state
;	.line	230; "demo.c"	sleep_timer=KEY_WAIT;
	LDA	#0x05
	STA	_sleep_timer
	RET	

	New pBlock

CSEG	 (CODE), dbName =C
;; Starting pCode block
_enter_rec_mode:	;Function start
; 0 exit points
;	.line	181; "demo.c"	api_beep_start(NORMAL_BEEP);
	LDA	#0x14
	PUSH	
	CALL	_api_beep_start
;	.line	182; "demo.c"	wait_beep(BEEP_TIME1);
	LDA	#0x64
	PUSH	
	CALL	_wait_beep
;	.line	183; "demo.c"	api_beep_stop();
	CALL	_api_beep_stop
;	.line	185; "demo.c"	if(IO&IO_REC)
	LDA	_IO
	SHR	
;	.line	186; "demo.c"	return;
	JC	_00216_DS_
;	.line	192; "demo.c"	API_EN5K_ON // 5k ON means small gain
	LDA	#0x10
	PUSH	
	PUSH	
	LDA	#0xf8
	PUSH	
	LDA	#0xf0
	PUSH	
	LDA	#0x80
	PUSH	
	CALL	_api_rec_prepare_alc
;	.line	194; "demo.c"	wait_beep(REC_WAIT_TIME); // wait settle down
	LDA	#0x64
	PUSH	
	CALL	_wait_beep
;	.line	195; "demo.c"	if(IO&IO_REC)
	LDA	_IO
	SHR	
	JNC	_00213_DS_
;	.line	197; "demo.c"	api_rec_stop_alc(0); // if key released , we stop
	CLRA	
	PUSH	
;	.line	198; "demo.c"	return;	
	JMP	_api_rec_stop_alc
_00213_DS_:
;	.line	204; "demo.c"	,callbackchk)) // callback means a function to check if finish
	LDA	#(_callbackchk+0)
	PUSH	
	LDA	#>(_callbackchk+0)
	PUSH	
	CLRA	
	PUSH	
	LDA	#0x08
	PUSH	
	LDA	#0x80
	PUSH	
	LDA	#0x01
	PUSH	
	CLRA	
	PUSH	
	LDA	#0xff
	PUSH	
	LDA	#0x06
	PUSH	
	CALL	_api_rec_start_alc
	JNZ	_00215_DS_
;	.line	206; "demo.c"	api_rec_stop_alc(0); // return 0 means stopped
	CLRA	
	PUSH	
;	.line	207; "demo.c"	return;		
	JMP	_api_rec_stop_alc
_00215_DS_:
;	.line	209; "demo.c"	sys_state=SYS_REC;
	LDA	#0x02
	STA	_sys_state
_00216_DS_:
	RET	

	New pBlock

CSEG	 (CODE), dbName =C
;; Starting pCode block
_callbackchk:	;Function start
; 2 exit points
;	.line	173; "demo.c"	api_enter_stdby_mode(0,0,1);
	LDA	#0x01
	PUSH	
	CLRA	
	PUSH	
	PUSH	
	CALL	_api_enter_stdby_mode
;	.line	174; "demo.c"	if(IO&IO_REC)
	LDA	_IO
	SHR	
	JNC	_00204_DS_
;	.line	175; "demo.c"	return 1;
	LDA	#0x01
	RET	
_00204_DS_:
;	.line	176; "demo.c"	return 0;
	CLRA	
	RET	

	New pBlock

CSEG	 (CODE), dbName =C
;; Starting pCode block
_wait_beep:	;Function start
; 0 exit points
;	.line	154; "demo.c"	void wait_beep(BYTE count)
	LDA	_RAMP1L
	PUSH	
	P02P1	
	LDA	@P1,-2
	STA	_beep_timer
_00195_DS_:
;	.line	157; "demo.c"	while(beep_timer)
	LDA	_beep_timer
	JZ	_00198_DS_
;	.line	159; "demo.c"	timer_routine();
	CALL	_timer_routine
;	.line	160; "demo.c"	if(key_state)
	LDA	_key_state
	JZ	_00193_DS_
;	.line	161; "demo.c"	api_enter_stdby_mode(0 ,0,0); // use tmr wk
	CLRA	
	PUSH	
	PUSH	
	PUSH	
	CALL	_api_enter_stdby_mode
	JMP	_00195_DS_
_00193_DS_:
;	.line	163; "demo.c"	api_enter_stdby_mode(IO_KEY_ALL,0,0); //use tmr+io wk
	CLRA	
	PUSH	
	PUSH	
	LDA	#0x07
	PUSH	
	CALL	_api_enter_stdby_mode
	JMP	_00195_DS_
_00198_DS_:
	POP	
	STA	_RAMP1L
	POP	
	RET	

	New pBlock

CSEG	 (CODE), dbName =C
;; Starting pCode block
_enter_play_mode:	;Function start
; 2 exit points
;	.line	131; "demo.c"	BYTE enter_play_mode(BYTE seg)
	LDA	_RAMP1L
	PUSH	
	P02P1	
	PUSH	
;	.line	133; "demo.c"	BYTE try_play=0;
	CLRA	
	STA	@_RAMP1
;	.line	134; "demo.c"	api_set_vol(API_PAGV_DEFAULT,0x78);
	LDA	#0x78
	PUSH	
	LDA	#0x3f
	PUSH	
	CALL	_api_set_vol
;	.line	135; "demo.c"	switch(seg)
	SETB	_C
	LDA	#0x03
	SUBB	@P1,-2
	JNC	_00175_DS_
	LDA	@P1,-2
	CALL	_00186_DS_
_00186_DS_:
	SHL	
	ADD	#_00187_DS_
	STA	_STACKL
	CLRA	
	ADDC	#>(_00187_DS_)
	STA	_STACKH
	RET	
_00187_DS_:
	JMP	_00171_DS_
	JMP	_00172_DS_
	JMP	_00173_DS_
	JMP	_00174_DS_
_00171_DS_:
;	.line	138; "demo.c"	try_play=API_PSTARTH(P0);
	LDA	#0x04
	PUSH	
	CLRA	
	PUSH	
	LDA	#0x70
	PUSH	
	LDA	#0x02
	PUSH	
	LDA	#0x1d
	PUSH	
	CLRA	
	PUSH	
	LDA	#0x10
	PUSH	
	CLRA	
	PUSH	
	CALL	_api_play_start
	STA	@_RAMP1
;	.line	139; "demo.c"	break;
	JMP	_00175_DS_
_00172_DS_:
;	.line	141; "demo.c"	try_play=API_PSTARTH(P1);
	LDA	#0x04
	PUSH	
	CLRA	
	PUSH	
	LDA	#0x70
	PUSH	
	LDA	#0x02
	PUSH	
	LDA	#0x6c
	PUSH	
	LDA	#0x01
	PUSH	
	LDA	#0x1d
	PUSH	
	CLRA	
	PUSH	
	CALL	_api_play_start
	STA	@_RAMP1
;	.line	142; "demo.c"	break;
	JMP	_00175_DS_
_00173_DS_:
;	.line	144; "demo.c"	try_play= API_PSTARTH_NOSAT(R3);
	LDA	#0x04
	PUSH	
	LDA	#0x80
	PUSH	
	LDA	#0xff
	PUSH	
	LDA	#0x01
	PUSH	
	CLRA	
	PUSH	
	LDA	#0x08
	PUSH	
	LDA	#0x80
	PUSH	
	LDA	#0x01
	PUSH	
	CALL	_api_play_start
	STA	@_RAMP1
;	.line	145; "demo.c"	break;
	JMP	_00175_DS_
_00174_DS_:
;	.line	147; "demo.c"	try_play= API_PSTARTL(R3);
	CLRA	
	PUSH	
	PUSH	
	LDA	#0xff
	PUSH	
	LDA	#0x01
	PUSH	
	CLRA	
	PUSH	
	LDA	#0x08
	PUSH	
	LDA	#0x80
	PUSH	
	LDA	#0x01
	PUSH	
	CALL	_api_play_start
	STA	@_RAMP1
_00175_DS_:
;	.line	150; "demo.c"	if(try_play)
	LDA	@_RAMP1
	JZ	_00177_DS_
;	.line	151; "demo.c"	sys_state=SYS_PLAY;
	LDA	#0x01
	STA	_sys_state
_00177_DS_:
;	.line	152; "demo.c"	return try_play; // return the result
	LDA	@_RAMP1
	STA	_PTRCL
	POP	
	POP	
	STA	_RAMP1L
	POP	
	LDA	_PTRCL
	RET	
;; end of function enter_play_mode
; exit point of _enter_play_mode

	New pBlock

CSEG	 (CODE), dbName =C
;; Starting pCode block
_timer_routine:	;Function start
; 0 exit points
;	.line	119; "demo.c"	if(!TOV)
	LDC	_TOV
;	.line	120; "demo.c"	return ;
	JNC	_00166_DS_
;	.line	121; "demo.c"	TOV=0;
	CLRB	_TOV
;	.line	122; "demo.c"	if(sleep_timer)
	LDA	_sleep_timer
;	.line	123; "demo.c"	sleep_timer--;
	JZ	_00163_DS_
	DECA	
	STA	_sleep_timer
_00163_DS_:
;	.line	124; "demo.c"	if(beep_timer)
	LDA	_beep_timer
;	.line	125; "demo.c"	beep_timer--;
	JZ	_00165_DS_
	DECA	
	STA	_beep_timer
_00165_DS_:
;	.line	127; "demo.c"	key_machine();
	CALL	_key_machine
_00166_DS_:
	RET	

	New pBlock

CSEG	 (CODE), dbName =C
;; Starting pCode block
_key_machine:	;Function start
; 0 exit points
;	.line	83; "demo.c"	void key_machine(void)
	LDA	_RAMP1L
	PUSH	
	P02P1	
	PUSH	
;	.line	86; "demo.c"	k=get_key();
	CALL	_get_key
	STA	@_RAMP1
;	.line	87; "demo.c"	switch(key_state)
	SETB	_C
	LDA	#0x02
	SUBB	_key_state
	JNC	_00133_DS_
	LDA	_key_state
	CALL	_00153_DS_
_00153_DS_:
	SHL	
	ADD	#_00154_DS_
	STA	_STACKL
	CLRA	
	ADDC	#>(_00154_DS_)
	STA	_STACKH
	RET	
_00154_DS_:
	JMP	_00120_DS_
	JMP	_00124_DS_
	JMP	_00129_DS_
_00120_DS_:
;	.line	90; "demo.c"	if(!key_code && k)
	LDA	_key_code
	JNZ	_00133_DS_
;	.line	92; "demo.c"	last_stroke=k;
	LDA	@_RAMP1
	JZ	_00133_DS_
	STA	_last_stroke
;	.line	93; "demo.c"	key_state=KEYS_DEB;
	LDA	#0x01
	STA	_key_state
;	.line	94; "demo.c"	key_timer=KEY_WAIT;
	LDA	#0x05
	STA	_key_timer
;	.line	96; "demo.c"	break;
	JMP	_00133_DS_
_00124_DS_:
;	.line	98; "demo.c"	if(k!=last_stroke)
	LDA	_last_stroke
	XOR	@_RAMP1
;	.line	100; "demo.c"	key_state=KEYS_NOKEY;
	JZ	_00126_DS_
	CLRA	
	STA	_key_state
;	.line	101; "demo.c"	break;
	JMP	_00133_DS_
_00126_DS_:
;	.line	103; "demo.c"	if(!--key_timer)
	LDA	_key_timer
	DECA	
	STA	_key_timer
	JNZ	_00133_DS_
;	.line	105; "demo.c"	key_code=last_stroke;
	LDA	_last_stroke
	STA	_key_code
;	.line	106; "demo.c"	key_state=KEYS_WAITRELEASE;
	LDA	#0x02
	STA	_key_state
;	.line	108; "demo.c"	break;
	JMP	_00133_DS_
_00129_DS_:
;	.line	110; "demo.c"	if(!k)
	LDA	@_RAMP1
	JNZ	_00133_DS_
;	.line	111; "demo.c"	key_state=KEYS_NOKEY;
	CLRA	
	STA	_key_state
_00133_DS_:
;	.line	114; "demo.c"	};
	POP	
	POP	
	STA	_RAMP1L
	RET	

	New pBlock

CSEG	 (CODE), dbName =C
;; Starting pCode block
_init:	;Function start
; 0 exit points
;	.line	70; "demo.c"	IO=0xFF; // all high
	LDA	#0xff
	STA	_IO
;	.line	71; "demo.c"	IODIR=0xc0;
	LDA	#0xc0
	STA	_IODIR
;	.line	72; "demo.c"	IOWK=0; // deep sleep mode no use wk
	CLRA	
	STA	_IOWK
;	.line	73; "demo.c"	sleep_timer=KEY_WAIT;
	LDA	#0x05
	STA	_sleep_timer
;	.line	74; "demo.c"	API_USE_ERC;
	LDA	#0x98
	AND	_RCCON
	ORA	#0x03
	STA	_RCCON
;	.line	80; "demo.c"	api_timer_on(TMR_RLD);
	LDA	#0xe0
	PUSH	
	JMP	_api_timer_on

	New pBlock

CSEG	 (CODE), dbName =C
;; Starting pCode block
_get_key:	;Function start
; 2 exit points
;	.line	56; "demo.c"	if(!(IO&IO_PLAY))
	LDA	#0x02
	AND	_IO
	JNZ	_00106_DS_
;	.line	57; "demo.c"	return KEY_CODE_PLAY;
	LDA	#0x01
	RET	
_00106_DS_:
;	.line	58; "demo.c"	if(!(IO&IO_PLAYREC))
	LDA	#0x04
	AND	_IO
	JNZ	_00108_DS_
;	.line	59; "demo.c"	return KEY_CODE_PLAYREC;
	LDA	#0x03
	RET	
_00108_DS_:
;	.line	60; "demo.c"	if(!(IO&IO_REC))
	LDA	_IO
	SHR	
	JC	_00110_DS_
;	.line	61; "demo.c"	return KEY_CODE_REC;
	LDA	#0x02
	RET	
_00110_DS_:
;	.line	64; "demo.c"	return 0;
	CLRA	
	RET	
