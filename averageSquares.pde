//------------------------------------------------------
// dan@marginallyclever.com 2021-03-10
//------------------------------------------------------

class Box {
  public int x0,y0;
  public int x1,y1;
  public color average;
  public long error;
  
  public Box(int x0,int y0,int x1,int y1) {
    this.x0=x0;
    this.y0=y0;
    this.x1=x1;
    this.y1=y1;
  }
  
  public void draw() {
    fill(average);
    stroke(0);
    rect(x0,y0,x1-x0,y1-y0);
  }
};

ArrayList<Box> boxes = new ArrayList<Box>();

// set true to start paused.  click the mouse in the screen to pause/unpause.
boolean paused=true;

PImage img;
boolean ready;


// run once on start.
void setup() {
  // make the window.  must be (h*2,h+20)
  size(1600,820);

  ready=false;
  selectInput("Select an image file","inputSelected");
}


void inputSelected(File selection) {
  if(selection == null) {
    exit();
    return;
  }
  
  // load the image
  img = loadImage(selection.getAbsolutePath());
  
  // crop image to square
  if(img.height<img.width) {
    img = img.get(0,0,img.height, img.height);
  } else {
    img = img.get(0,0,img.width, img.width);
  }
  
  // resize to fill window
  img.resize(width/2,width/2);

  image(img, width/2, 0,width/2,height);
  img.loadPixels();
  
  Box b = new Box(0,0,img.width,img.height);
  updateBox(b);
  boxes.add(b);
  
  ready=true;
}


void mouseReleased() {
  paused = paused ? false : true;
}


void draw() {
  if(!ready) return;
  
  if(boxes.size()==0) {
    noLoop();
  }

  image(img, width/2, 0,width/2,height);
    
  if(paused) return;

  // find box with biggest error term
  Box worstBox=boxes.get(0);
  for(int i=1;i<boxes.size();++i) {
    Box b = boxes.get(i);
    if(worstBox.error<b.error) {
      worstBox=b;
    }
  }
  // replace the box with four smaller boxes 
  boxes.remove(worstBox);
  int x0=worstBox.x0;
  int y0=worstBox.y0;
  int x2=worstBox.x1;
  int y2=worstBox.y1;
  int x1=(x0+x2)/2;
  int y1=(y0+y2)/2;
  
  if(x2==x0 && y2==x0) 
    return;
  
  Box [] b4 = new Box[4];
  b4[0]=new Box(x0,y0,x1,y1);  // nw
  b4[1]=new Box(x1,y0,x2,y1);  // ne
  b4[2]=new Box(x0,y1,x1,y2);  // sw
  b4[3]=new Box(x1,y1,x2,y2);  // se
  
  for( Box bn : b4 ) {
    updateBox(bn);
    boxes.add(bn);
  }
}


void updateBox(Box b) {
  // get the average color of the box
  int w = img.width;
  float rSum=0;
  float gSum=0;
  float bSum=0;
  float c=0;
  for(int y=b.y0;y<b.y1;++y) {
    for(int x=b.x0;x<b.x1;++x) {
      color p=img.pixels[y*w+x];
      c++;
      rSum += red(p);
      gSum += green(p);
      bSum += blue(p);
    }
  }
  rSum/=c;
  gSum/=c;
  bSum/=c;
  b.average = color(rSum,gSum,bSum);
  
  // from the average, find the error.
  long error=0;
  for(int y=b.y0;y<b.y1;++y) {
    for(int x=b.x0;x<b.x1;++x) {
      color p=img.pixels[y*w+x];
      float dr = rSum - red(p);
      float dg = gSum - green(p);
      float db = bSum - blue(p);
      error += sqrt(dr*dr + dg*dg + db*db);
    }
  }
  b.error = error;
  // update the screen
  b.draw();
}
