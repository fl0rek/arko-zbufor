int x0, y0, olx, orx, y1, y_low, x_low;
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
      stroke(((rx - x) *lc + (x - lx) *rc)/dx);
    point(x, y);
  }
}

void draw() {
  background( 255);
  x0 = 50;
  y0 = 21;

  c0 = 0;
  c1 = 0;
  c2 = 0;

  olx = 30;
  orx = 100;
  y1 = 50;
  
  y_low = 170;

  if(y1 < y0  || y_low < y1) {
    println("u wot m8");
    return;
  }

  int ld = olx >= x0 ? 1 : -1;
  int rd = orx >= x0 ? 1 : -1;

  int ldx = abs(olx - x0);
  int rdx = abs(orx - x0);

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
  point(olx, y1);
  point(orx, y1);
  
  int lx, rx;
  lx = rx = x0;
  
  //check lD
  while(lD > 0) {
    lx += rd;
    lD -= 2*ldx;
  }
  
  //check lD
  while(rD > 0) {
    rx += ld;
    rD -= 2*rdx;
  }
  boolean swapped = false;

  
  int yspan_short, yspan_long;
  yspan_short = y1 - y0;
  yspan_long = y_low - y0;
  
  for(int y = y0; y <= y_low; y++) {
    int lc, rc;

    if(y == y1 && !swapped ) {
      if(swap_left) {
          ldx = (orx - olx);
          ldy = (y_low - y1);
          //ld = lx >= rx ? -1 : 1;
          ld = -1;
          //lD = 2*ldx - dy;
          println("l");  
      } else {
          rdx = (orx - olx);
          rdy = (y_low - y1);
          rd = -1;
          //rd = rx >= lx ? -1 : 1;
          println("r");
      }
      yspan_short = y_low - y1;
      println(rdx + " : " + rdy);
      swapped = true;
    }
    
    if(swap_left) {
      if(!swapped) {
        lc = ((y - y0) *c1 + (y1 - y) *c0)/yspan_short;
      } else {
        lc = ((y - y1) *c2 + (y_low - y) *c1)/yspan_short;
      }
      rc = ((y - y0) *c2 + (y_low - y) *c0)/yspan_long;
    } else {
      if(!swapped) {
        rc = ((y - y0) *c1 + (y1 - y) *c0)/yspan_short;
      } else {
        rc = ((y - y1) *c2 + (y_low - y) *c1)/yspan_short;
      }
      lc = ((y - y0) *c2 + (y_low - y) *c0)/yspan_long;
    }
    strokeLine(lx, rx, y, lc, rc);
    
    lD += 2*ldx;
    //check lD
    while(lD > 0) {
      lx += ld;
      lD -= 2*ldy;
    }
    
    rD += 2*rdx;
    //check lD
    while(rD > 0) {
      rx += rd;
      rD -= 2*rdy;
    }
  }
}