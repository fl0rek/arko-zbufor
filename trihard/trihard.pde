int x0, y0, lx, rx, y1;
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

  lx = 50;
  rx = 100;
  y1 = 150;
  
  int ld = lx >= x0 ? 1 : -1;
  int rd = rx >= x0 ? 1 : -1;

  int ldx = abs(lx - x0);
  int rdx = abs(rx - x0);

  int dy = (y1 - y0);

  int lD = 2*ldx - dy;
  int rD = 2*rdx - dy;
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
  int yspan = y1 - y0;
  for(int y = y0+1; y <= y1; y++) {
    int lc = ((y - y1) *c0 + (y0 - y) *c1)/yspan;
    int rc = ((y - y1) *c0 + (y0 - y) *c2)/yspan;

    strokeLine(lx, rx, y, lc, rc);
    
    lD += 2*ldx;
    while(lD > 0) {
      lx += ld;
      lD -= 2*dy;
    }
    
    rD += 2*rdx;
    while(rD > 0) {
      rx += rd;
      rD -= 2*dy;
    }
  }
}