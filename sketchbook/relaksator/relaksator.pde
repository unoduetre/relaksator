/* 
  UWAGA! Aktualnie projekt nic nie wyświetla, gdyż pracuję nad importem plików w formacie Collada.
  Działa natomiast menu.
  Jeszcze trochę mi zostało pracy przy tym imporcie Collady, ale jak już to zrobię, to będzie też od razu
  zestaw klas odpowiadających różnym obiektom 3D, których użyję jako frameworka dla reszty programu...
*/


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

public String sketchRenderer() 
{
  return P3D; 
}

public void setup()
{
  exception = null;
  try
  {
    //orientation(PORTRAIT);
    ketaiGesture = new KetaiGesture(this);
    controlP5 = new ControlP5(this);
    mainView = new MainView(this);
    menuView = new MenuView(this, controlP5);
    matchingView = new MatchingView(this);
  
    currentView = mainView;
    smooth();
    noStroke();
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
    currentView.draw();
  }
  else
  {
    background(0,0,0);
    fill(255,255,255);
    textAlign(LEFT, TOP);
    ByteArrayOutputStream stream = new ByteArrayOutputStream();
    exception.printStackTrace(new PrintStream(stream));
    text(stream.toString(), 0, 0, width, height);
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

public void mousePressed()
{
  if(exception != null){return;}
  oldMousePosition = new PVector(mouseX, mouseY);
}

public void mouseReleased()
{
  if(exception != null){return;}
  oldMousePosition = null;
}

public void mouseDragged()
{
  if(exception != null){return;}
  if(oldMousePosition != null)
  {
    PVector currentMousePosition = new PVector(mouseX, mouseY);
    PVector mousePositionDifference = PVector.sub(currentMousePosition, oldMousePosition);
    
    if(currentView == mainView)
    {
      ((MainView)currentView).addAngle((float)mousePositionDifference.x/10);
    }
    
    oldMousePosition = currentMousePosition;
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
    menuView.captureFaceAction();
  }
}

public void quitAction()
{
  if(currentView == menuView)
  {
    menuView.quitAction();
  }
}

