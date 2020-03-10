BOOT_DRIVE_ADDR 		equ 0x501
DAP_LOAD_SUPPORTED_ADDR	equ 0x502
SECTORS_PER_TRACK_ADDR	equ 0x503
HEADS_PER_CYLINDER_ADDR	equ 0x504
PDPT_ADDR       		equ 0x1000
PD_ADDR         		equ 0x2000

PRINT_STRING_ADDR		equ 0x510
CLR_SCR_ADDR            equ 0x518
KBD_GETCH               equ 0x520


KBD_ENC_INP_BUFF        equ 0x60
KBD_ENC_CMD_REGS        equ 0x60

KBD_CTL_STA_REGS        equ 0x64
KBD_CTL_CMD_REGS        equ 0x64


KYBRD_CTRL_STATS_MASK_OUT_BUF	equ	1
KYBRD_CTRL_STATS_MASK_IN_BUF	equ	2
KYBRD_CTRL_STATS_MASK_SYSTEM    equ	4
KYBRD_CTRL_STATS_MASK_CMD_DATA	equ	8
KYBRD_CTRL_STATS_MASK_LOCKED	equ	0x10
KYBRD_CTRL_STATS_MASK_AUX_BUF	equ	0x20
KYBRD_CTRL_STATS_MASK_TIMEOUT	equ	0x40
KYBRD_CTRL_STATS_MASK_PARITY	equ	0x80


KEY_UNKNOWN equ 0
KEY_ESCAPE equ 1
KEY_1 equ 2
KEY_2 equ 3
KEY_3 equ 4
KEY_4 equ 5
KEY_5 equ 6
KEY_6 equ 7
KEY_7 equ 8
KEY_8 equ 9
KEY_9 equ 0xa
KEY_0 equ 0xb
KEY_MINUS equ 0xc
KEY_EQUAL equ 0xd
KEY_BACKSPACE equ 0xe
KEY_TAB equ 0xf
KEY_Q equ 0x10
KEY_W equ 0x11
KEY_E equ 0x12
KEY_R equ 0x13
KEY_T equ 0x14
KEY_Y equ 0x15
KEY_U equ 0x16
KEY_I equ 0x17
KEY_O equ 0x18
KEY_P equ 0x19
KEY_LEFTBRACKET equ 0x1a 
KEY_RIGHTBRACKET equ 0x1b 
KEY_RETURN equ 0x1c
KEY_LCTRL equ 0x1d
KEY_A equ 0x1e
KEY_S equ 0x1f
KEY_D equ 0x20
KEY_F equ 0x21
KEY_G equ 0x22
KEY_H equ 0x23
KEY_J equ 0x24
KEY_K equ 0x25
KEY_L equ 0x26
KEY_SEMICOLON equ 0x27
KEY_QUOTE equ 0x28
KEY_GRAVE equ 0x29
KEY_LSHIFT equ 0x2a
KEY_BACKSLASH equ 0x2b
KEY_Z equ 0x2c
KEY_X equ 0x2d
KEY_C equ 0x2e
KEY_V equ 0x2f
KEY_B equ 0x30
KEY_N equ 0x31
KEY_M equ 0x32
KEY_COMMA equ 0x33
KEY_DOT equ 0x34
KEY_SLASH equ 0x35
KEY_RSHIFT equ 0x36
KEY_KP_ASTERISK equ 0x37 
KEY_RALT equ 0x38
KEY_SPACE equ 0x39
KEY_CAPSLOCK equ 0x3a
KEY_F1 equ 0x3b
KEY_F2 equ 0x3c
KEY_F3 equ 0x3d
KEY_F4 equ 0x3e
KEY_F5 equ 0x3f
KEY_F6 equ 0x40
KEY_F7 equ 0x41
KEY_F8 equ 0x42
KEY_F9 equ 0x43
KEY_F10 equ 0x44
KEY_KP_NUMLOCK equ 0x45
KEY_SCROLLLOCK equ 0x46
KEY_HOME equ 0x47
KEY_KP_8 equ 0x48
KEY_PAGEUP equ 0x49
KEY_KP_2 equ 0x50
KEY_KP_3 equ 0x51
KEY_KP_0 equ 0x52
KEY_KP_DECIMAL equ 0x53
KEY_UNKNOWN2 equ 0x54
KEY_UNKNOWN3 equ 0x55
KEY_UNKNOWN4 equ 0x56
KEY_F11 equ 0x57
