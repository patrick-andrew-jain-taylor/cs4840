#include "fbputchar.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <unistd.h>
#include "usbkeyboard.h"
#include <pthread.h>


#define SERVER_HOST "192.168.1.1"
#define SERVER_PORT 42000

#define BUFFER_SIZE 128
#define MSG_BUFSIZE 258
#define BLINK_COUNT 40000000
#define ALPHA_START 93

typedef int bool;
#define true 1
#define false 0

/*
 * References:
 *
 * http://beej.us/guide/bgnet/output/html/singlepage/bgnet.html
 * http://www.thegeekstuff.com/2011/12/c-socket-programming/
 * 
 */

int sockfd; /* Socket file descriptor */

struct libusb_device_handle *keyboard;
uint8_t endpoint_address;

pthread_t network_thread;
void *network_thread_f(void *);

//Thread for cursor
pthread_t cursor_thread;
void *cursor_thread_f(void *);

//Cursor row and col coordinates and blink counters
int cr, cc, bctr;
bool blink;

//Message Buffer
char msg[MSG_BUFSIZE];
int msgcidx;
int msglen;

static char clookup[];

int main()
{
  int err, col;
	
  struct sockaddr_in serv_addr;

  struct usb_keyboard_packet packet;
  int transferred;
  char keystate[12];
  	
	//Initialize cursor values
	cr = 46;
	cc = 0;
	bctr = 0;
	blink = false;
	
	msgcidx = 0;
	msglen = 0;

  if ((err = fbopen()) != 0) {
    fprintf(stderr, "Error: Could not open framebuffer: %d\n", err);
    exit(1);
  }
	
	//Clear screen. Find more efficient way to do this if there's time.
	int row;
	for(row=0; row < 48; row++) {
		for(col = 0; col < 128; col++) {
			fbputchar(' ', row, col);
		}
	}

  /* Draw rows of asterisks across the top and bottom of the screen */
  for (col = 0 ; col < 128 ; col++) {
    fbputchar('*', 0, col);
    fbputchar('_', 45, col);
  }

  fbputs("Hello CSEE 4840 World!", 4, 10);

  /* Open the keyboard */
  if ( (keyboard = openkeyboard(&endpoint_address)) == NULL ) {
    fprintf(stderr, "Did not find a keyboard\n");
    exit(1);
  }
    
  /* Create a TCP communications socket */
  if ( (sockfd = socket(AF_INET, SOCK_STREAM, 0)) < 0 ) {
    fprintf(stderr, "Error: Could not create socket\n");
    exit(1);
  }

  /* Get the server address */
  memset(&serv_addr, 0, sizeof(serv_addr));
  serv_addr.sin_family = AF_INET;
  serv_addr.sin_port = htons(SERVER_PORT);
  if ( inet_pton(AF_INET, SERVER_HOST, &serv_addr.sin_addr) <= 0) {
    fprintf(stderr, "Error: Could not convert host IP \"%s\"\n", SERVER_HOST);
    exit(1);
  }

  /* Connect the socket to the server */
  if ( connect(sockfd, (struct sockaddr *) &serv_addr, sizeof(serv_addr)) < 0) {
    fprintf(stderr, "Error: connect() failed.  Is the server running?\n");
    exit(1);
  }

  /* Start the network thread */
  pthread_create(&network_thread, NULL, network_thread_f, NULL);

	//Start cursor thread
	pthread_create(&cursor_thread, NULL, cursor_thread_f, NULL);

  /* Look for and handle keypresses */
  for (;;) { 
    libusb_interrupt_transfer(keyboard, endpoint_address,
			      (unsigned char *) &packet, sizeof(packet),
			      &transferred, 0);
    if (transferred == sizeof(packet)) {
      sprintf(keystate, "%02x %02x %02x", packet.modifiers, packet.keycode[0],
	      packet.keycode[1]);


      if(packet.keycode[0] == 0x2a) { //Backspace pressed?
				if(msgcidx > 0 && msglen > 0) {
					msgcidx--;
					msglen--;
				}
				fbputchar(' ', cr, cc);
        if(cc > 0) {
          cc--;
          fbputchar(' ', cr, cc);
        }
      }
			else if(packet.keycode[0] == 0x50){ //Left Arrow pressed?
				if (msgcidx == msglen)
					fbputchar(' ', cr, cc);
				else {
					fbputchar(msg[msgcidx], cr, cc);
				}

				if (cc == 0 && cr == 47 ){
					cc = 127;
					cr = 46;
					msgcidx--;
				}
				else if (cc == 0 && cr == 46){
				}
				else {
					msgcidx--;
					cc--;
				}
			}
			else if(packet.keycode[0] == 0x4f){ //Right Arrow pressed?
					if (msgcidx < msglen){
						fbputchar(msg[msgcidx], cr, cc);
						if (cr == 46 && cc == 127){
							cc = 0;
							cr = 47;
							msgcidx++;
						}
						else if (cr == 47 && cc == 127){
						}
						else{
							msgcidx++;
							cc++;
						}
				}
			}
      else if(packet.keycode[0] >= 0x04 && packet.keycode[0] <= 0x38) { //Alphanumeric keys and symbols
				/*
				if (packet.keycode[0] == 0x29) { // ESC pressed?
						break;
				}	
				*/
				
				if(packet.keycode[0] == 0x28) { //Enter pressed?
					printf("%s \n", strcat(msg, "\n"));
					write(sockfd, strcat(msg, "\n"), msglen+1);
					msglen = 0;
					msgcidx = 0;
					memset(msg, '\0', MSG_BUFSIZE);
					
					//Clear the message area. Make more efficient later.
					int r, c;
					for(r = 46; r < 48; r++) {
						for(c = 0; c < 127; c++) {
							fbputchar(' ', r, c);
						}
					}

					cr = 46;
					cc = 0;
				}
				else {
					uint8_t shift = 0x00;        
					if(packet.modifiers == 0x02 || packet.modifiers == 0x20) {
						shift = 0x35;
					} 
					
					if(msgcidx < 257) {
						msg[msgcidx] = clookup[packet.keycode[0] - 0x04 + shift]; 
						fbputchar(clookup[packet.keycode[0] - 0x04 + shift], cr, cc);
						msgcidx++;
						msglen++;
					}

					if(cc > 127) {
						cc = 0;
						cr++;
					}
					else {
						cc++;
					}

				printf("%s %c\n", keystate, (char) (ALPHA_START + (packet.keycode[0])));
				fbputs(keystate, 6, 0);

				}


			}

    }	
  }
	
  /* Terminate the network thread */
  pthread_cancel(network_thread);
	pthread_cancel(cursor_thread)
	;
  /* Wait for the network thread to finish */
  pthread_join(network_thread, NULL);
	pthread_join(cursor_thread, NULL);

  return 0;
}

void *network_thread_f(void *ignored)
{
  char recvBuf[BUFFER_SIZE];
  int n;
  /* Receive data */
  while ( (n = read(sockfd, &recvBuf, BUFFER_SIZE - 1)) > 0 ) {
    recvBuf[n] = '\0';
    printf("%s", recvBuf);
    fbputs(recvBuf, 8, 0);
  }

  return NULL;
}

void *cursor_thread_f(void *ignored) {

	//Cursor thread does not terminate after ESC is pressed. Should fix this later
	for(;;) {
		if(bctr == BLINK_COUNT) {
			if(blink == false) {
				fbputchar('|', cr, cc);
				blink = true;
			}
			else {
				char c = ' ';
				if(msgcidx < msglen)
					c = msg[msgcidx];
				fbputchar(c, cr, cc);
				blink = false;
			}
			bctr = 0;
		}
		else {
			bctr++;
		}
	}
	
	//Needed this in order to allow main thread to continue, why?
	return NULL;
}

static char clookup[] = {
	'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's',
	't', 'u', 'v', 'w', 'x', 'y', 'z', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0','\0', '\0',
	'\0', '\0', ' ', '-', '=', '[', ']', '\\', '\0', ';', '\'', '`', ',', '.', '/', 
	'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S',
	'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '\0', '\0',
	'\0', '\0', ' ', '_', '+', '{', '}', '|', '\0', ':', '\"', '~', '<', '>', '?'};
