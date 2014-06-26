/*
  Użyte biblioteki:
    ControlP5
    Ketai
    papaya
*/

import java.io.ByteArrayOutputStream;
import java.io.PrintStream;

import android.view.MotionEvent;
import ketai.ui.KetaiGesture;
import controlP5.ControlP5;

private KetaiGesture ketaiGesture;
private MainView mainView;
private MenuView menuView;
private MatchingView matchingView;
private View currentView;
private ControlP5 controlP5;
private PVector oldMousePosition;
private Exception exception;
private float[][] defaultMatrix = { 
  {1.0, 0.0, 0.0, 0.0},
  {0.0, 1.0, 0.0, 0.0},
  {0.0, 0.0, 1.0, 0.0},
  {0.0, 0.0, 0.0, 1.0}
};

public String sketchRenderer() 
{
  return P3D; 
}

public void applyDefaultMatrix()
{
  resetMatrix();
  applyMatrix(
    defaultMatrix[0][0], defaultMatrix[0][1], defaultMatrix[0][2], defaultMatrix[0][3],
    defaultMatrix[1][0], defaultMatrix[1][1], defaultMatrix[1][2], defaultMatrix[1][3],
    defaultMatrix[2][0], defaultMatrix[2][1], defaultMatrix[2][2], defaultMatrix[2][3],
    defaultMatrix[3][0], defaultMatrix[3][1], defaultMatrix[3][2], defaultMatrix[3][3]
  );
}

public void setup()
{
  exception = null;
  try
  {
    //orientation(PORTRAIT);
    Collada collada = new Collada(this, this.loadXML("model.dae"), null);
    ketaiGesture = new KetaiGesture(this);
    controlP5 = new ControlP5(this);
    mainView = new MainView(this, collada);
    menuView = new MenuView(this, collada, controlP5);
    matchingView = new MatchingView(this, collada);
    defaultMatrix[0][3] = -width / 2;
    defaultMatrix[1][3] = -height / 2;
    defaultMatrix[2][3] = -630.4665;
  
    currentView = mainView;
    textureMode(NORMAL);
    imageMode(CORNERS);
    ellipseMode(CENTER);    
    
    smooth();
    strokeWeight(1);
    noStroke();
    //stroke(0,0,255);
    fill(255,255,255);
    //noFill();
    frameRate(60);
  }
  catch(Exception e)
  {
    exception = e;
    noLoop();
  }
}

public void draw()
{
  if(exception == null)
  {
    try
    {
      currentView.draw();
      //println(frameRate);
    }
    catch(Exception e)
    { 
      exception = e;
      draw();
      noLoop();
    }
  }
  else
  {
    applyDefaultMatrix();
    background(0,0,0);
    noStroke();
    fill(255,255,255);    
    textFont(createFont("SansSerif",10));
    textAlign(LEFT, TOP);
    ByteArrayOutputStream stream = new ByteArrayOutputStream();
    exception.printStackTrace(new PrintStream(stream));
    text(stream.toString(), 0, 0, width, height);
    println(stream.toString());
  }
}

private void switchToView(View view)
{
  currentView.hide();
  currentView = view;
  currentView.show();
}

public boolean surfaceTouchEvent(MotionEvent event) 
{
  super.surfaceTouchEvent(event);
  return ketaiGesture.surfaceTouchEvent(event);
  
}

public void onTap(float x, float y)
{
  if(exception != null){return;}
  try
  {
    currentView.onTap(new PVector(x, y));
  }
  catch(Exception e)
  { 
    exception = e;
    draw();
    noLoop();
  }   
}

public void onFlick(float endX, float endY, float startX, float startY, float v)
{
  if(exception != null){return;}
  try
  {
    currentView.onFlick(new PVector(endX, endY), new PVector(startX, startY), v);
  }
  catch(Exception e)
  { 
    exception = e;
    draw();
    noLoop();
  }   
}

public void onPinch(float x, float y, float r)
{
  if(exception != null){return;}
  try
  {
    currentView.onPinch(new PVector(x, y), r);
  }
  catch(Exception e)
  { 
    exception = e;
    draw();
    noLoop();
  }     
}

public void onRotate(float x, float y, float a)
{
  if(exception != null){return;}
  try
  {
    currentView.onRotate(new PVector(x, y), a);
  }
  catch(Exception e)
  { 
    exception = e;
    draw();
    noLoop();
  }     
}

public void mousePressed()
{
  if(exception != null){return;}
  try
  {
    currentView.mousePressed(new PVector(mouseX, mouseY));
  }
  catch(Exception e)
  { 
    exception = e;
    draw();
    noLoop();
  }  
}

public void mouseReleased()
{
  if(exception != null){return;}
  try
  {
    currentView.mouseReleased(new PVector(mouseX, mouseY));
  }
  catch(Exception e)
  { 
    exception = e;
    draw();
    noLoop();
  }
}

public void mouseDragged()
{
  if(exception != null){return;}
  try
  {
    currentView.mouseDragged(new PVector(mouseX, mouseY));    
  }
  catch(Exception e)
  { 
    exception = e;
    draw();
    noLoop();
  }
}

public void keyPressed()
{
  if(exception != null){return;}
  if(key == CODED)
  {
    switch(keyCode)
    {
      case MENU:
        if(currentView == mainView)
        {
          switchToView(menuView);
        }
        else
        {
          switchToView(mainView);
        }
      break;
    }
  }
}

public void captureFaceAction()
{
  if(currentView == menuView)
  {
    switchToView(matchingView);
  }
}

public void quitAction()
{
  if(currentView == menuView)
  {
    menuView.quitAction();
  }
}

