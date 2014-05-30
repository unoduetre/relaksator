public class MainView extends View
{
  private Head head = null;
  private Float angle = 0.0;
  
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
  
  public Float getAngle()
  {
    return angle;
  }
  
  public void setAngle(Float angle)
  {
    this.angle = angle - floor(angle / TWO_PI) * TWO_PI;
  }
  
  public void addAngle(Float angle)
  {
    setAngle(this.angle+angle);
  }
  
  public void draw()
  {
    pushStyle();
    background(0,0,0);
    lights();    
    pushMatrix();
    translate(0.5*pApplet.width, 0.6*pApplet.height, 0); // gdzie umieścić nos :-D
    rotate(angle);
    if(pApplet.width/pApplet.height < 2/3)
    {
      scale(pApplet.width*3/2); 
    }
    else
    {
      scale(pApplet.height);
    }
    head.draw();    
    popMatrix();
    popStyle();    
  }
}
