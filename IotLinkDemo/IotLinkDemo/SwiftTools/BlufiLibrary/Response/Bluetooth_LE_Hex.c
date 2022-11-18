#include<stdio.h>
#include<stdlib.h>
#include<string.h>

typedef enum {
    CMD_ACK = 0x00,
    CMD_SET_SEC_MODE,
    CMD_SET_OP_MODE,
    CMD_CONNECT_WIFI,
    CMD_DISCONNECT_WIFI,
    CMD_GET_WIFI_STATUS,
    CMD_DEAUTHENTICATE,
    CMD_GET_VERSION,
    CMD_CLOSE_CONNECTION,
    CMD_WIFI_SCAN,
    CMD_DATA_GET_PREPARE,
    CMD_WIFI_DATA_GET,
    CMD_PROV_STOP,
    CMD_WIFI_STATE_GET,

#if defined(CONFIG_ZIGBEE_PROV)
    CMD_ZB_SCAN=0x20,
    CMD_ZB_JOIN,
    CMD_ZB_GET_INSTALLCODE,
    CMD_ZB_RESET,
#endif

} cmd_id_t;

typedef enum {
    DATA_ACK = 0x00,
    DATA_STA_WIFI_BSSID,
    DATA_STA_WIFI_SSID,
    DATA_STA_WIFI_PASSWORD,
    DATA_SOFTAP_WIFI_SSID,
    DATA_SOFTAP_WIFI_PASSWORD,
    DATA_SOFTAP_MAX_CONNECTION_COUNT,
    DATA_SOFTAP_AUTH_MODE,
    DATA_SOFTAP_CHANNEL,
    DATA_USERNAME,
    DATA_CA_CERTIFICATION,
    DATA_CLIENT_CERTIFICATION,
    DATA_SERVER_CERTIFICATION,
    DATA_CLIENT_PRIVATE_KEY,
    DATA_SERVER_PRIVATE_KEY,
    DATA_WIFI_CONNECTION_STATE,
    DATA_VERSION,
    DATA_WIFI_LIST,
    DATA_ERROR,
    DATA_CUSTOM_DATA,

    DATA_ARK_APP_INFO_TOKEN,
    DATA_ARK_APP_INFO_USER,

#if defined(CONFIG_ZIGBEE_PROV)
    DATA_ZB_LINKKEY = 0x20,
    DATA_ZB_PANID,
    DATA_ZB_INSTALLCODE,
    DATA_ZB_SCAN_INFO,
#endif

} data_id_t;


// 命令指令用
typedef struct _bl_bt_proto_cmd{
	unsigned char ctrl; // 通訊的控制
	unsigned char seq; // seq no. 由 0 開始，每次+1
	unsigned char frag_ctrl[2]; // short (2 bytes) 目前僅有 第 15 個 bit 有用，用於表示資料結束
	unsigned char total_len[2]; // 實際要傳遞資料的長度，此長度若大於 mtu 長度，則會要求分割，拆成多個 packet 傳送
	unsigned char len; // 由下一個 bytes 起算，要傳遞指令的長度，在 cmd 裡固定為 14: 5 (enc) + 4 (mac) + 1 (type) + 4 (cmd data)
    unsigned char enc[5]; // encrypt 資料，目前無作用
    unsigned char mac[4]; // 目前無作用
	unsigned char type; // 命令指令的參數，參考 cmd_id_t
	//接於此之後，為 4 bytes 的指令參數
} bl_bt_proto_cmd_t;

// 資料指令用
typedef struct _bl_bt_proto_data{
	unsigned char ctrl; // 通訊的控制
	unsigned char seq; // seq no. 由 0 開始，每次+1
	unsigned char frag_ctrl[2]; // short (2 bytes) 目前僅有 第 15 個 bit 有用，用於表示資料結束
	unsigned char total_len[2]; // 實際要傳遞資料的長度，此長度若大於 mtu 長度，則會要求分割，拆成多個 packet 傳送
	unsigned char len; // 由下一個 bytes 起算，要傳遞資料的長度，為 data_len + 5 (enc) + 4 (mac) + 1 (data_len) + 1 (type)
    unsigned char enc[5]; // encrypt 資料，目前無作用
    unsigned char mac[4]; // 目前無作用
	unsigned char data_len; // 此次傳遞的資料長度，若 total_len 大於 mtu，資料會要求切割成多塊傳送，此表示被切割後的長度
	unsigned char type; // 資料指令的參數，參考 data_id_t
	// 接於此之後，則為 data_len 長度 (bytes) 的資料 (payload)
} bl_bt_proto_data_t;


char* getSSidData(){
    
    int fd;
    unsigned char buf[256];
    char *ssid = "NXIOT";
    char *spsk = "88888888";
    bl_bt_proto_data_t bt_data;
    char *send_data = (char *)&bt_data;
    unsigned short data_len = 0;
    bl_bt_proto_cmd_t bt_cmd;
    char *send_cmd = (char *)&bt_cmd;
    unsigned short cmd_len = 0;
    short frag_ctrl = 0;
    char *my_cmd = "1234";
    ssize_t ret_size;

    // 準備傳遞 ssid 的資料指令
    memset(&bt_data, 0, sizeof(bt_data));
    data_len = strlen(ssid);
    bt_data.ctrl = (1<<2) | (1<<4) | (1<<7); // 用於 資料指令
    bt_data.seq = 0;
    bt_data.frag_ctrl[0] = 0;
    bt_data.frag_ctrl[1] = 0;
    bt_data.total_len[0] = data_len&0xFF;
    bt_data.total_len[1] = (data_len>>8)&0xFF;
    bt_data.len = data_len + 5 + 4 + 1 + 1;
    for ( int i = 0 ; i < sizeof(bt_data.enc) ; i++ ) { // 預設
        bt_data.enc[0] = 1;
    }
    for ( int i = 0 ; i < sizeof(bt_data.mac) ; i++ ) { // 預設
        bt_data.mac[0] = 2;
    }
    bt_data.data_len = data_len;
    bt_data.type = DATA_STA_WIFI_SSID; // 0x02

    printf("%lu", sizeof(bt_data));
    
    for (int i = 0 ; i < sizeof(bt_data) ; i++ ) {
        printf("%02X", send_data[i]);
        printf("\r\n");
    }
    for ( int i = 0 ; i < strlen(ssid) ; i++ ) {
        printf("%02X", ssid[i]);
    }
    char *a1[] = {bt_data.ctrl};
    char *a[] = {bt_data.ctrl,bt_data.seq,bt_data.frag_ctrl,bt_data.total_len,bt_data.len,bt_data.enc,bt_data.mac,bt_data.data_len,bt_data.type};
    
    return  send_data;
}

int testabc() {
	int fd;
	unsigned char buf[256];
	char *ssid = "BL808";
	char *spsk = "12345678";
	bl_bt_proto_data_t bt_data;
	char *send_data = (char *)&bt_data;
	unsigned short data_len = 0;
	bl_bt_proto_cmd_t bt_cmd;
	char *send_cmd = (char *)&bt_cmd;
	unsigned short cmd_len = 0;
	short frag_ctrl = 0;
	char *my_cmd = "1234";
	ssize_t ret_size;

	// 準備傳遞 ssid 的資料指令
	memset(&bt_data, 0, sizeof(bt_data));
	data_len = strlen(ssid);
	bt_data.ctrl = (1<<2) | (1<<4) | (1<<7); // 用於 資料指令
	bt_data.seq = 0;
	bt_data.frag_ctrl[0] = 0;
	bt_data.frag_ctrl[1] = 0;
	bt_data.total_len[0] = data_len&0xFF;
	bt_data.total_len[1] = (data_len>>8)&0xFF;
	bt_data.len = data_len + 5 + 4 + 1 + 1;
	for ( int i = 0 ; i < sizeof(bt_data.enc) ; i++ ) { // 預設
		bt_data.enc[0] = 1;
	}
	for ( int i = 0 ; i < sizeof(bt_data.mac) ; i++ ) { // 預設
		bt_data.mac[0] = 2;
	}
	bt_data.data_len = data_len;
	bt_data.type = DATA_STA_WIFI_SSID; // 0x02

	for (int i = 0 ; i < sizeof(bt_data) ; i++ ) {
		printf("%02X", send_data[i]);
	}
	for ( int i = 0 ; i < strlen(ssid) ; i++ ) {
		printf("%02X", ssid[i]);
	}
	printf("\r\n");

	// 準備傳遞 password 的資料指令
	memset(&bt_data, 0, sizeof(bt_data));
	data_len = strlen(spsk);
	bt_data.ctrl = (1<<2) | (1<<4) | (1<<7);
	bt_data.seq = 1;
	bt_data.frag_ctrl[0] = 0;
	bt_data.frag_ctrl[1] = 0;
	bt_data.total_len[0] = data_len&0xFF;
	bt_data.total_len[1] = (data_len>>8)&0xFF;
	bt_data.len = data_len + 5 + 4 + 1 + 1;
	for ( int i = 0 ; i < sizeof(bt_data.enc) ; i++ ) {
		bt_data.enc[0] = 1;
	}
	for ( int i = 0 ; i < sizeof(bt_data.mac) ; i++ ) {
		bt_data.mac[0] = 2;
	}
	bt_data.data_len = data_len;
	bt_data.type = DATA_SOFTAP_WIFI_PASSWORD; // 0x03

	for (int i = 0 ; i < sizeof(bt_data) ; i++ ) {
		printf("%02X", send_data[i]);
	}
	for ( int i = 0 ; i < strlen(spsk) ; i++ ) {
		printf("%02X", spsk[i]);
	}

	printf("\r\n");

	// 準備傳遞 連線 wifi 的命令指令
	memset(&bt_cmd, 0, sizeof(bt_cmd));
	bt_cmd.seq = 2;
	data_len = 4;
	frag_ctrl = 1<<15; // 第 15 個 bit 要設為 1
	bt_cmd.frag_ctrl[0] = frag_ctrl&0xFF;
	bt_cmd.frag_ctrl[1] = (frag_ctrl>>8)&0xFF;
	bt_cmd.total_len[0] = data_len&0xFF;
	bt_cmd.total_len[1] = (data_len>>8)&0xFF;
	bt_cmd.len = 14;
	for ( int i = 0 ; i < sizeof(bt_data.enc) ; i++ )
		bt_cmd.enc[i] = 1;
	for ( int i = 0 ; i < sizeof(bt_data.mac) ; i++ )
		bt_cmd.mac[i] = 2;

	bt_cmd.type = CMD_CONNECT_WIFI; // 0x03
	for ( int i = 0 ; i < sizeof(bt_cmd) ; i++ )
		printf("%02X", send_cmd[i]);
	for ( int i = 0 ; i < strlen(my_cmd) ; i++ )
		printf("%02X", my_cmd[i]);
	printf("\r\n");

	return 0;
}
