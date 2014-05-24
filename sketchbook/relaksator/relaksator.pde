import android.view.MotionEvent;
import ketai.ui.KetaiGesture;
import controlP5.ControlP5;

private KetaiGesture ketaiGesture;
private MainView mainView;
private MenuView menuView;
private MatchingView matchingView;
private View currentView;
private ControlP5 controlP5;

public String sketchRenderer() 
{
  return P3D; 
}

public void setup()
{
  orientation(PORTRAIT);
  ketaiGesture = new KetaiGesture(this);
  controlP5 = new ControlP5(this);
  mainView = new MainView(this);
  menuView = new MenuView(this, controlP5);
  matchingView = new MatchingView(this);
  
  currentView = mainView;
  smooth();
  noStroke();
}

public void draw()
{
  currentView.draw();
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

public void keyPressed()
{
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

