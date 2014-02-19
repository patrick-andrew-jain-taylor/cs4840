#include "fbputchar.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <unistd.h>
#include "usbkeyboard.h"
#include <pthread.h>

//#define IPADDR(a,b,c,d) (htonl(((a)<<24)|((b)<<16)|((c)<<8)|(d)))
//#define SERVER_HOST IPADDR(192,168,1,1)
//#define SERVER_PORT htons(42000)

#define SERVER_HOST "192.168.1.1"
#define SERVER_PORT 42000

#define BUFFER_SIZE 128
#define MSG_BUFSIZE 255
#define BLINK_COUNT 40000000
#define SLEEP_WAIT 200000000
#define ALPHA_START 93
#define FST_BOUND 122
#define SND_BOUND 127

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
void clearScreen(int r);

//Cursor row and col coordinates and blink counters
int cr, cc, bctr;
bool blink;

//Message Buffer
char msg[MSG_BUFSIZE];
int msgcidx;
int msglen;

//Cursor for receive region
int rcr, rcc;

static char clookup[];

static char emptyLine[128]; //empty string to clear a line on the screen for writing

int main()
{
  int err, col;
	
  struct sockaddr_in serv_addr;
  
  struct usb_keyboard_packet packet;
  int transferred;
  char keystate[12];
  
  //serv_addr = {AF_INET, SERVER_PORT, {SERVER_HOST} };

	//Initialize cursor values
	cr = 46;
	cc = 0;
	bctr = 0;
	blink = false;
	
	msgcidx = 0;
	msglen = 0;

  rcr = 9;
  rcc = 0;
  
  memset(emptyLine, ' ', 128); //Set variable to an empty line

  if ((err = fbopen()) != 0) {
    fprintf(stderr, "Error: Could not open framebuffer: %d\n", err);
    exit(1);
  }
  
  //Clear screen contents from previous session
  clearScreen(48);

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
  
  /*
    Display Welcome Message for a few seconds.
    After message disappears, set "receive" region cursor to the top 
  */
  int wait;
  for(wait = 0; wait < SLEEP_WAIT; wait++){
  }
  clearScreen(45);
  rcr = 0;

  /* Look for and handle keypresses */
  for (;;) { 
    libusb_interrupt_transfer(keyboard, endpoint_address,
			      (unsigned char *) &packet, sizeof(packet),
			      &transferred, 0);
    if (transferred == sizeof(packet)) {
      sprintf(keystate, "%02x %02x %02x", packet.modifiers, packet.keycode[0],
	      packet.keycode[1]);


      if(packet.keycode[0] == 0x2a) { //Backspace pressed?
      	if(msgcidx < msglen && msgcidx != 0) {
      		char *p = msg+msgcidx;
      		char *end = msg+msgcidx-1;
      		
      		msgcidx--;
      		msglen--;
      		
      		while(*p) {
      			*(p-1) = *p;
      			++p;
      			
      		}
      		*(p-1) = '\0';
      		
      		if(cr == 47 && cc == 0) {
      			//reset cursor to end of first line
      			cr = 46;
      			cc = 126;
      			
      			//print remainder of string on the second line
      			fbputs(end+1, 47, 0);
      			fbputchar(' ', 47, strlen(end)-1);
      		}
      		else if(msglen > 126 && msgcidx < 127) {
      			int size1 = 128 - msgcidx;
						char end1[size1];
						strncpy(end1, msg+msgcidx, size1-1);
						end1[size1] = '\0';
						
						char *end2 = msg + 127;
						cc--;
						
						/*
							Split the multiline message into two end parts, end1 and end2 
							put end1 on first line and end2 on the second line
						*/
						fbputs(end1, cr, cc);
						fbputs(end2, 47, 0);
						fbputchar(' ', 47, strlen(end2));
      		}
      		else {
      			cc--;
	      		fbputs(end, cr, cc);      		
	      		fbputchar(' ', cr, cc+strlen(end));
      		}      		
					
      	} // end of 'if(msgcidx < msglen && msgcidx != 0)'
      	else {
					if(msgcidx > 0 && msglen > 0) {
						msgcidx--;
						msglen--;
					}
					
					if(cr == 47 && cc == 0) {
						//		printf("bkspce\n");
						cr = 46;
						cc = 126;
						fbputchar(' ', cr, cc);
					}
					else {
						fbputchar(' ', cr, cc);
		        if(cc > 0) {
		          cc--;
		          fbputchar(' ', cr, cc);
		        }
		      }
	      }
      }
			else if(packet.keycode[0] == 0x50){ //Left Arrow pressed?
				if (msgcidx == msglen)
					fbputchar(' ', cr, cc);
				else {
					fbputchar(msg[msgcidx], cr, cc);
				}

				if (cc == 0 && cr == 47 ){
					cc = 126;
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
						if (cr == 46 && cc == 126){
							cc = 0;
							cr = 47;
							msgcidx++;
						}
						else if (cr == 47 && cc == 126){
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
					printf("%s rcr:%d, rcc:%d, msglen:%d, msgcidx:%d\n", msg, rcr, rcc, msglen, msgcidx);
          memset(msg+msglen, '\0', MSG_BUFSIZE - msglen); 
          write(sockfd, msg, msglen);
          fbputs(emptyLine, rcr, rcc);
          fbputs("<Me> ", rcr, 0);
          
          //Wrap long messages sent by us to the next row 
          if(msglen > FST_BOUND) {
            char firstlineBuf[FST_BOUND+1];
            char *secondline = msg + FST_BOUND;
            strncpy(firstlineBuf, msg, FST_BOUND);
            firstlineBuf[FST_BOUND+1] = '\0';
            fbputs(firstlineBuf, rcr++, 5);

            if(msglen > FST_BOUND + SND_BOUND) {
              char secondlineBuf[SND_BOUND+1];
              char *thirdline = msg + FST_BOUND + SND_BOUND;
              strncpy(secondlineBuf, secondline, SND_BOUND);
              fbputs(secondlineBuf, rcr++, 0);
              fbputs(thirdline, rcr, 0);
            }
            else {
              fbputs(secondline, rcr, 0);             
            }
          }
          else
            fbputs(msg, rcr, 5);

          rcr++;
          if(rcr > 44) {
            rcr = 0;
            clearScreen(45);  
          }
        
          msglen = 0;
					msgcidx = 0;
					memset(msg, '\0', MSG_BUFSIZE);
					
					//Clear the message area. Make more efficient later.
					int r;
					for(r = 46; r < 48; r++)
						fbputs(emptyLine, r, 0);

					cr = 46;
					cc = 0;
				}
				else if(msglen < MSG_BUFSIZE - 1) {
					uint8_t shift = 0x00;        
					if(packet.modifiers == 0x02 || packet.modifiers == 0x20)
						shift = 0x35; 
					            printf("hehe\n");
					if(msgcidx < MSG_BUFSIZE-1) {
						msg[msgcidx] = clookup[packet.keycode[0] - 0x04 + shift]; 
						fbputchar(clookup[packet.keycode[0] - 0x04 + shift], cr, cc);
						msgcidx++; 
            if(msgcidx == msglen + 1)
              msglen++;
					}

          cc++;
					if(cc > 126) {
						cc = 0;
						if(++cr == 48) {
              cr = 47;
              cc = 126;
            }
					}

				  printf("%s %c, msgcidx: %d, msglen: %d, cr:%d, cc:%d\n", keystate, (char) (ALPHA_START + (packet.keycode[0])), 
            msgcidx, msglen, cr, cc);
				}
			}
    }	
  }
	
  /* Terminate the network thread */
  pthread_cancel(network_thread);
	pthread_cancel(cursor_thread);
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
    fbputs(recvBuf, rcr, rcc);
  
    rcr++;
    if(rcr > 44) {
      rcr = 0; 
      clearScreen(45);
    }
  }

  return NULL;
}

void *cursor_thread_f(void *ignored) {

	//Cursor thread does not terminate after ESC is pressed. Should fix this later
	for(;;) {

		if(bctr == BLINK_COUNT) {
			if(blink == false) {
				fbputchar('_', cr, cc);
				blink = true;
			}
			else {
				char c = ' ';
				if(msgcidx < msglen)
          c = msg[msgcidx];
        else if(msgcidx == MSG_BUFSIZE-1)
          c = msg[msgcidx-1];

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

void clearScreen(int r) {
	//Clear screen. Find more efficient way to do this if there's time.
	int row;
	for(row=0; row < r; row++)
    fbputs(emptyLine, row, 0);
}

static char clookup[] = {
	'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's',
	't', 'u', 'v', 'w', 'x', 'y', 'z', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0','\0', '\0',
	'\0', '\0', ' ', '-', '=', '[', ']', '\\', '\0', ';', '\'', '`', ',', '.', '/', 
	'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S',
	'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '\0', '\0',
	'\0', '\0', ' ', '_', '+', '{', '}', '|', '\0', ':', '\"', '~', '<', '>', '?'};
