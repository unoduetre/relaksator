

public String sketchRenderer() 
{
  return P3D; 
}

void setup()
{

  //orientation(PORTRAIT);  
  smooth();
  noStroke();
}

void draw()
{
  background(0,0,0);
  lights();  
  pushMatrix();
  translate(0.5*width, 0.6*height, 0); // gdzie umieścić nos :-D
  float scaler = 15;
  if(width/height < 2/3)
  {
   scale(width/(scaler*2/3)); 
  }
  else
  {
    scale(height/scaler);
  }
  head.draw();    
  popMatrix();
}

