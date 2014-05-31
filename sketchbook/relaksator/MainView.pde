public static class MainView extends View
{
  private Head head = null;
  private Float angle = 0.0;
  
  public MainView(PApplet pApplet) throws Exception
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
    pApplet.pushStyle();
    pApplet.background(0,0,0);
    pApplet.lights();    
    pApplet.pushMatrix();
    pApplet.translate(0.5*pApplet.width, 0.6*pApplet.height, 0); // gdzie umieścić nos :-D
    pApplet.rotate(angle);
    if(pApplet.width/pApplet.height < 2/3)
    {
      pApplet.scale(pApplet.width*3/2); 
    }
    else
    {
      pApplet.scale(pApplet.height);
    }
    head.draw();    
    pApplet.popMatrix();
    pApplet.popStyle();    
  }
}
