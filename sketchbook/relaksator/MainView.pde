public static class MainView extends View
{
  private Collada collada = null;
  private ColladaScene scene = null; 
  private Float angle = 0.0;
  
  public MainView(PApplet pApplet) throws Exception
  {
    super(pApplet);
    collada = new Collada(pApplet,pApplet.loadXML("test2.dae"));
    scene = collada.getScene();    
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
  
  public void draw() throws Exception
  {
    pApplet.pushStyle();
    pApplet.pushMatrix();    
    pApplet.background(0,0,0);
    pApplet.lights();    
    pApplet.translate(pApplet.width/2, pApplet.height/2, 0);
    pApplet.rotate(angle);
    
    /*if(pApplet.width/pApplet.height < 2/3)
    {
      pApplet.scale(pApplet.width*3/2); 
    }
    else
    {
      pApplet.scale(pApplet.height);
    }*/
    //pApplet.scale(10);
    scene.draw();
    pApplet.popMatrix();
    pApplet.popStyle();    
  }
}
