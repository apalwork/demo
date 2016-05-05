#include<ms311.h>
#include<ms311sphlib.h>
#include "spidata.h"

// timer is independent from the lib
#define TMR_RLD (256-32)

// system state 
#define SYS_PLAY 1
#define SYS_REC 2
#define SYS_IDLE 0

// For EMI consideration
#define ULAWC_DEFAULT 0x18

// here we define the key related operation
#define KEYS_NOKEY 0
#define KEYS_DEB 1
#define KEYS_WAITRELEASE 2

#define KEY_CODE_PLAY 1
#define KEY_CODE_REC 2
#define KEY_CODE_PLAYREC 3
//#define KEY_CODE_PLAYREC2 4

#define KEY_WAIT 5

#define IO_REC 0x01
#define IO_PLAY 0x02
#define IO_PLAYREC 0x4
//#define IO_PLAYREC2 0x8
#define IO_KEY_ALL 0x7
// add a cap for power-on play
#define IO_CAP 0x8

// typical beep value
#define NORMAL_BEEP 0x14
#define BEEP_TIME1 100
#define BEEP_TIME2 80
#define REC_WAIT_TIME 100


BYTE key_state;
BYTE sys_state;
BYTE last_stroke;
BYTE key_code;
BYTE key_timer;
BYTE beep_timer;

// wait a while to enter sleep
BYTE sleep_timer;

// KEY is defined by get_key
BYTE get_key(void)
{
	if(!(IO&IO_PLAY))
		return KEY_CODE_PLAY;
	if(!(IO&IO_PLAYREC))
		return KEY_CODE_PLAYREC;
	if(!(IO&IO_REC))
		return KEY_CODE_REC;
	//if(!(IO&IO_PLAYREC2))
		//return KEY_CODE_PLAYREC2;
	return 0;
}

void init(void)
{
	// add init job here
	IO=0xFF; // all high
	IODIR=0xc0;
	IOWK=0; // deep sleep mode no use wk
	sleep_timer=KEY_WAIT;
	API_USE_ERC;
	// for EMI of ULAW, OFFSETL set to 2
	// this will induce some noise.. but is for emi only
	//OFFSETL=2;
	//RCCON=9; // use eosc
	
	api_timer_on(TMR_RLD);
}

void key_machine(void)
{
	BYTE k;	// following is key machine
	k=get_key();
	switch(key_state)
	{
		case KEYS_NOKEY:
			if(!key_code && k)
			{
				last_stroke=k;
				key_state=KEYS_DEB;
				key_timer=KEY_WAIT;
			}
			break;
		case KEYS_DEB:
			if(k!=last_stroke)
			{
				key_state=KEYS_NOKEY;
				break;
			}
			if(!--key_timer)
			{
				key_code=last_stroke;
				key_state=KEYS_WAITRELEASE;
			}
			break;
		case KEYS_WAITRELEASE:
			if(!k)
				key_state=KEYS_NOKEY;
			break;
			
	};
}

void timer_routine(void)
{
	if(!TOV)
		return ;
	TOV=0;
	if(sleep_timer)
		sleep_timer--;
	if(beep_timer)
		beep_timer--;
	// add timer jobs here
	key_machine();

}

BYTE enter_play_mode(BYTE seg)
{
	BYTE try_play=0;
	api_set_vol(API_PAGV_DEFAULT,0x78);
	switch(seg)
	{
		case 0:
			try_play=API_PSTARTH(P0);
			break;
		case 1:					
			try_play=API_PSTARTH(P1);
			break;
		case 2:
			try_play= API_PSTARTH_NOSAT(R3);
			break;
		case 3:
			try_play= API_PSTARTL(R3);
			break;
	}
	if(try_play)
		sys_state=SYS_PLAY;
	return try_play; // return the result
}
void wait_beep(BYTE count)
{
	beep_timer=count;
	while(beep_timer)
	{
		timer_routine();
		if(key_state)
			api_enter_stdby_mode(0 ,0,0); // use tmr wk
		else
			api_enter_stdby_mode(IO_KEY_ALL,0,0); //use tmr+io wk

	}
}

BYTE callbackchk(void)
{
	// when start recording,
	// it checks if need abort here
	// we use only DMA wake up
	api_enter_stdby_mode(0,0,1);
	if(IO&IO_REC)
		return 1;
	return 0;
}

void enter_rec_mode(void)
{
	api_beep_start(NORMAL_BEEP);
	wait_beep(BEEP_TIME1);
	api_beep_stop();
	// after beep, we check if key released
	if(IO&IO_REC)
		return;
	api_rec_prepare_alc(
		API_AD_OSR128,  // sample rate <12K use 128 is fine
		0xf0, // analog gain
		0xf8, // we change to timer wk
		0x10,
		API_EN5K_ON // 5k ON means small gain
		); // if there is prepare, it shall be stop
	wait_beep(REC_WAIT_TIME); // wait settle down
	if(IO&IO_REC)
	{
		api_rec_stop_alc(0); // if key released , we stop
		return;	
	}
	if(!api_rec_start_alc(0x6 // do dc can
					, 0xff // digital gain 0x80~0xff
					,R3_ULAW // Recording segment #3 defined by spidata.h
					, R3_STARTPAGE,R3_ENDPAGE
					,callbackchk)) // callback means a function to check if finish
	{
		api_rec_stop_alc(0); // return 0 means stopped
		return;		
	}
	sys_state=SYS_REC;
	
		
}
void enter_idle_mode(void)
{
	api_play_stop();

	if(sys_state==SYS_REC) // stop from recording
	{
		api_rec_stop_alc(1); // it will add endcode here
	
		api_beep_start(NORMAL_BEEP);
		wait_beep(BEEP_TIME2);
		api_beep_stop();
		wait_beep(BEEP_TIME2);
		api_beep_start(NORMAL_BEEP);
		wait_beep(BEEP_TIME2);
		api_beep_stop();
	}
	sys_state=SYS_IDLE;
	sleep_timer=KEY_WAIT;
}
BYTE countled;
void sys_play(void)
{
	BYTE result =api_play_job(); 
	if(!result)
		enter_idle_mode();
	else if(result==2)
	{
		/*
		if(++countled==3)
		{
			countled=0;
			IO^=0x80;
		}
		*/
		if(PWRH)
			IO&=0x7F;
		else
			IO|=0x80;
	}else
	{
		if(key_state==KEYS_NOKEY)
		{// if no key press, timer off
		  // use IO,DMA to wake up						
			api_enter_stdby_mode(IO_KEY_ALL, 0, 1);
		}else
		{ // otherwise use timer wake up
			api_enter_stdby_mode(0,0,0);
		}
	}

}

void sys_rec(void)
{
	if(IO&IO_REC)
	{
		enter_idle_mode();
		return;
	}
	if(!api_rec_job_alc())
		enter_idle_mode();
	else
	{
		if(IO&IO_REC)
			enter_idle_mode();
		else
			api_enter_stdby_mode(0,0,0);// use timer wk, adjust 
					// gain!!
	}
	
}

#define TAG (*((BYTE*)0x8100))

main()
{
resetit:
	ULAWC=ULAWC_DEFAULT;
	init();
	if(!(init_io_state&IO_CAP) )
	{
		//enter_play_mode(0);
		API_SPI_ERASE((USHORT)R2_STARTPAGE); // first time we erase!!
	}
	while(1)
	{
		timer_routine();
		if(key_code)
		{
			if(sys_state!=SYS_IDLE)
				enter_idle_mode();
			else
			switch(key_code)
			{
				case KEY_CODE_REC:
					enter_rec_mode();
					break;
				case KEY_CODE_PLAY:
				
					API_SPI_READ_PAGE((USHORT)R2_STARTPAGE, 1);// read prev data to 0x100
					if(TAG==0xff)
					{
						TAG=0;
						API_SPI_WRITE_PAGE((USHORT)R2_STARTPAGE,1); // write it
						enter_play_mode(0);
					}else
					{
						enter_play_mode(1);
					}
					
					break;
				case KEY_CODE_PLAYREC:
					enter_play_mode(2);
					break;
				//case KEY_CODE_PLAYREC2:
					//enter_play_mode(3);
					//break;
			}
			key_code=0;
		}
		
		if(sys_state==SYS_REC)
			sys_rec();
		else if(sys_state==SYS_PLAY)
			sys_play();
		else if(!sleep_timer && !key_state)
		{
			//IODIR=0x80;
			IODIR=0;
			IO=0;
			IOR=0xff;
			
			IO|=0x80;
			if(IO==0xff)
			{
				//api_enter_dsleep_mode(); // this will reset
				api_normal_sleep(IO_KEY_ALL,0,1);
			}
				/*
				{
					ADCON=0;
					LVDCON=0x20; //LPASS
					LVRCON|=8;
					LVRCON|=0x18;
					IOWKDR=0;
					IOWK=0x07;
					SYSC=4;
					SYSC=0;
					SYSC=1;
					IO=0x80;
					SYSC=4;
					SYSC=6;
				}
				*/

			
		}
		else
		{
			if(key_state)
				api_enter_stdby_mode(0 ,0,0); // use tmr wk
			else
				api_enter_stdby_mode(IO_KEY_ALL,0,0); //use tmr+io wk
			if(!TOV)
				key_machine(); // wake up by IO, we get keycode first
		}
	}
}
