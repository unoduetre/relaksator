import android.view.MotionEvent;

import ketai.ui.*;

KetaiGesture gesture;
float Size = 10;
float Angle = 0;
PImage img;
ArrayList<Thing> things = new ArrayList<Thing>();

void setup()
{
  orientation(LANDSCAPE);
  gesture = new KetaiGesture(this);
  img = loadImage("toci.jpg");
  textSize(32);
  textAlign(CENTER);
  imageMode(CENTER);
}

void draw()
{
  background(128);
  pushMatrix();
  translate(width/2, height/2);
  rotate(Angle);
  image(img, 0, 0, Size, Size);
  popMatrix();
  
  //if we have things lets reverse through them 
  //  so we can delete dead ones and draw live ones
  if (things.size() > 0)
    for (int i = things.size()-1; i >= 0; i--)
    {
      Thing t = things.get(i);
      if (t.isDead())
        things.remove(t);
      else
        t.draw();
    }
}

public boolean surfaceTouchEvent(MotionEvent event) {
  super.surfaceTouchEvent(event);
  return gesture.surfaceTouchEvent(event);
}

