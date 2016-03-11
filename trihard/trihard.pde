int x0, y0, lx, rx, y1, y_low, x_low;
int c0, c1, c2;

void setup() {
  size(320, 240);
  noSmooth();
}

void strokeLine(int lx, int rx, int y, int lc, int rc) {
  int dx = abs(rx - lx);
  for(int x = lx; x <= rx; x++) {
    if(dx == 0)
      stroke(lc);
    else
      stroke(((rx - x) *rc + (x - lx) *lc)/dx);
    point(x, y);
  }
}

void draw() {
  background( 255);
  x0 = 50;
  y0 = 50;

  c0 = 50;
  c1 = 100;
  c2 = 150;

  lx = 30;
  rx = 100;
  y1 = 120;
  
  y_low = 170;

  if(y1 < y0  || y_low < y1) {
    println("u wot m8");
    return;
  }

  int ld = lx >= x0 ? 1 : -1;
  int rd = rx >= x0 ? 1 : -1;

  int ldx = abs(lx - x0);
  int rdx = abs(rx - x0);

  //int dy = (y1 - y0);
  boolean swap_left = false;
  
  int ldy;
  int rdy;
  if(swap_left) {
    ldy = (y1 - y0);
    rdy = (y_low - y0);
  } else {
    rdy = (y1 - y0);
    ldy = (y_low - y0);
  }

  int lD = 2*ldx - ldy;
  int rD = 2*rdx - rdy;
  stroke(0);
  point(x0, y0);
  point(lx, y1);
  point(rx, y1);
  
  lx = rx = x0;
  
  if(lD > 0) {
    lx += rd;
    lD -= 2*ldx;
  }
  if(rD > 0) {
    rx += ld;
    rD -= 2*rdx;
  }
  boolean swapped = false;
  //int yspan = y1 - y0;
  for(int y = y0+1; y <= y_low; y++) {
    int lc = 1; //((y - y1) *c0 + (y0 - y) *c1)/yspan;
    int rc = 1; //((y - y1) *c0 + (y0 - y) *c2)/yspan;

    if(y >= y1 && !swapped) {
      if(swap_left) {
          ldx = abs(lx - rx);
          ldy = (y_low - y1);
          ld = lx >= rx ? -1 : 1;
          //lD = 2*ldx - dy;
          println("l");  
      } else {
          rdx = abs(rx - lx);
          rdy = (y_low - y1);
          rd = rx >= lx ? -1 : 1;
          println("r");
      }

      swapped = true;
    }
    
    strokeLine(lx, rx, y, lc, rc);
    
    lD += 2*ldx;
    while(lD > 0) {
      lx += ld;
      lD -= 2*ldy;
    }
    
    rD += 2*rdx;
    while(rD > 0) {
      rx += rd;
      rD -= 2*rdy;
    }
  }
}