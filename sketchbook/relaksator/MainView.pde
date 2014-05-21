public class MainView extends View
{
  private Head head = null;
  
  public MainView(PApplet pApplet)
  {
    super(pApplet);
    head = new Head(pApplet);    
  }
  
  public void show()
  {
  }
  
  public void hide()
  {
  }
  
  public void draw()
  {
    pushStyle();
    background(0,0,0);
    lights();    
    pushMatrix();
    translate(0.5*pApplet.width, 0.6*pApplet.height, 0); // gdzie umieścić nos :-D
    Float scaler = 15.0;
    if(pApplet.width/pApplet.height < 2/3)
    {
      scale(pApplet.width/(scaler*2/3)); 
    }
    else
    {
      scale(pApplet.height/scaler);
    }
    head.draw();    
    popMatrix();
    popStyle();    
  }
}
