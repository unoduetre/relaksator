Head head = null;

public String sketchRenderer() 
{
  return P3D; 
}

void setup()
{
  head = new Head(this, width, height);
  orientation(PORTRAIT);  
  smooth();
  noStroke();
  background(255,0,0);
}

void draw()
{
  lights();  
  pushMatrix();
  translate(0.5*width, 0.6*height, 0); // gdzie umieścić nos :-D
  if(width/height < 2/3)
  {
   scale(width * 0.144); 
  }
  else
  {
    scale(height * 0.096);
  }
  head.draw();    
  popMatrix();
}

