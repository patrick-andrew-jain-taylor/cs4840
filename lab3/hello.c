/*
 * Userspace program that communicates with the led_vga device driver
 * primarily through ioctls
 *
 * Stephen A. Edwards
 * Columbia University
 
 		Peter Xu, Patrick Taylor
 */

#include <stdio.h>
#include "vga_led.h"
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <string.h>
#include <unistd.h>
#include <time.h>
#include <stdlib.h>
//#include <math.h>

int vga_led_fd;
typedef int bool;

#define true 1
#define false 0

#define CENTER_X	320
#define CENTER_Y	240

#define TOP_BND		40
#define BOT_BND		440
#define RIGHT_BND	600
#define LEFT_BND	40

/* Read and print the segment values */
void print_segment_info() {
  vga_led_arg_t vla;
  int i;

  for (i = 0 ; i < VGA_LED_DIGITS ; i++) {
    vla.digit = i;
    if (ioctl(vga_led_fd, VGA_LED_READ_DIGIT, &vla)) {
      perror("ioctl(VGA_LED_READ_DIGIT) failed");
      return;
    }
    printf("%02x ", vla.segments);
  }
  printf("\n");
}

/* Write the contents of the array to the display */
void write_segments(const unsigned char segs[8])
{
  vga_led_arg_t vla;
  int i;
  for (i = 0 ; i < VGA_LED_DIGITS ; i++) {
    vla.digit = i;
    vla.segments = segs[i];
    if (ioctl(vga_led_fd, VGA_LED_WRITE_DIGIT, &vla)) {
      perror("ioctl(VGA_LED_WRITE_DIGIT) failed");
      return;
    }
  }
}

/* Center coords for circle */
void write_coords(unsigned int x, unsigned int y) {
	circ_center cc;
	cc.cx = x;
	cc.cy = y;
	
	if(ioctl(vga_led_fd, VGA_LED_WRITE_CENTER, &cc)) {
		perror("ioctl(VGA_LED_WRITE_CENTER) failed");
		return;
	}
}

int main()
{
  vga_led_arg_t vla;
  int i;
  static const char filename[] = "/dev/vga_led";

  static unsigned char message[8] = { 0x39, 0x6D, 0x79, 0x79,
				      0x66, 0x7F, 0x66, 0x3F };
	
	int cx = CENTER_X;
	int cy = CENTER_Y;
	//int cx = 400;
	//int cy = 400;
	
	int vx, vy;
	bool collision;
	
  printf("VGA LED Userspace program started\n");

  if ( (vga_led_fd = open(filename, O_RDWR)) == -1) {
    fprintf(stderr, "could not open %s\n", filename);
    return -1;
  }

  printf("initial state: ");
  
  /*
  	Algorithm:
  		start at center and generate random point (rx,ry) which defines the vector, v, to travel along
  		vx = rx - cx;
  		vy = ry - cy;
  		
  		while(true)	{
	  		theta = angle(v) + offset, check quadrant for value of offset
	  		dx = 1*cos(theta)
	  		dy = 1*sin(theta)
  			
  			while(!collision)	{
	  			cx += dx
	  			cy += dy
	  			
	  			check collision
	  		}
	  		
  			// rotate v 90 degrees
  			tmp = vx;
  			vx = -vy + cx;
  			vy = vx + cy;
  		}
  */
  /*
 	srand(time(NULL));
  vx = (rand() % 640) - cx;
  vy = (rand() % 480) - cy;
  collision = false;
  
  while(true) {
  	theta = atan2((double)vy, (double) vx);
  	dx = 5*cos(theta);
  	dy = 5*sin(theta);
  	collision = false;
  	
  	while(!collision) {
  		cx += dx;
  		cy += dy;
  		write_coords(cx, cy);
  		
  		if(cx >= RIGHT_BND || cx >= LEFT_BND || cy >= TOP_BND || cy >= BOT_BND) {
  			collision = true;
  		}
  		usleep(5000);
  	}
  	
  	tmp = vx;
  	vx = -vy + cx;
  	vy = vx + cy;
  }
  */
  
  vx = 1;
  vy = 1;
  
  while(true) {
  	cx += vx;
  	cy += vy;
  	write_coords(cx, cy);
  	
  	if(cx == RIGHT_BND || cx == LEFT_BND)
  		vx = -vx;
  	if(cy == TOP_BND || cy == BOT_BND)
  		vy = -vy;
  		
  	usleep(7000);
  }

  printf("current state: ");
	  
  printf("VGA LED Userspace program terminating\n");
  return 0;
}
