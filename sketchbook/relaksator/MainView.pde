public static class MainView extends View
{
  protected ColladaScene scene = null; 
  protected Float angle = 0.0;
  
  public MainView(PApplet pApplet, Collada collada) throws Exception
  {
    super(pApplet, collada);

    scene = collada.getScene();    
  }
  
  public Collada getCollada()
  {
    return collada;
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
    pApplet.applyMatrix(
       1.0,  0.0,  0.0,  0.0,
       0.0, -1.0,  0.0,  0.0,
       0.0,  0.0,  1.0,  0.0,
       0.0,  0.0,  0.0,  1.0
    );
    pApplet.rotate(angle);
    
    if(pApplet.width/pApplet.height < 2/3)
    {
      pApplet.scale(0.01*pApplet.width*3/2); 
    }
    else
    {
      pApplet.scale(0.01*pApplet.height);
    }
    collada.run();
    scene.draw();
    pApplet.popMatrix();
    pApplet.popStyle();    
  }
  
  public void mousePressed(PVector mousePosition) throws Exception
  {
    Long startTime = System.currentTimeMillis();
    ((ColladaAnimation)collada.getById("makowa-anim")).start(startTime);
    ((ColladaAnimation)collada.getById("szyja-anim")).start(startTime);
    ((ColladaAnimation)collada.getById("krengoslup-anim")).start(startTime);
  }

  public void mouseReleased(PVector mousePosition) throws Exception
  {
    ((ColladaAnimation)collada.getById("makowa-anim")).stop();
    ((ColladaAnimation)collada.getById("szyja-anim")).stop();
    ((ColladaAnimation)collada.getById("krengoslup-anim")).stop();
  }  
}
